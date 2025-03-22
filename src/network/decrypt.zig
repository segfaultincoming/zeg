const std = @import("std");
const keys = @import("keys.zig");
const cipher = @import("cipher_calc.zig");
const cipher_structure = @import("cipher_structure.zig");
const xor = @import("xor_decrypt.zig");

pub const DecryptError = error{ ContentSizeMismatch, ChecksumMismatch, InvalidBlockSize };

pub fn decrypt(packet: []const u8, decrypt_keys: keys.Keys, decrypt_c1_c2: bool) ![]const u8 {
    const header_size = cipher.get_header_size(packet);

    switch (packet[0]) {
        0xC1, 0xC2 => {
            if (decrypt_c1_c2) {
                return xor.decrypt_xor32(@constCast(packet), header_size);
            }

            return packet;
        },
        else => {},
    }

    // TODO: Counter is uknown to me right now. Works by only setting it here, though...
    // Right now it just takes 1 from the header_size, accounting for the CipherVersion.New
    const counter: u32 = 1;
    const header = packet[0..3];

    const content_size = cipher.get_content_size(packet, counter, false);
    const block_size = cipher_structure.get_block_sizes(cipher_structure.CipherVersion.New);

    if (content_size % block_size.encrypted != 0) {
        return error.ContentSizeMismatch;
    }

    const max_size = cipher.get_max_decrypted_size(packet, block_size);
    const payload_offset = header_size - counter;

    const encrypted_packet = packet[header_size..];
    var output = try cipher_structure.block_alloc(u8, max_size);
    const encrypted_blocks = try cipher_structure.split_into_blocks(encrypted_packet, block_size.encrypted);

    var block_offset: u32 = 0;

    for (encrypted_blocks) |encrypted_block| {
        const unmasked_block = try cipher_structure.block_alloc(u64, block_size.unmasked);
        const decrypted_block = try cipher_structure.block_alloc(u64, block_size.decrypted);

        // Unmask the blocks
        {
            for (unmasked_block, 0..) |*value, i| {
                value.* = 0;

                const byte_offset = cipher.get_byte_offset(i);
                const bit_offset = cipher.get_bit_offset(i);
                const first_mask = cipher.get_first_bit_mask(i);

                const first_offset: u6 = @as(u5, 24) + bit_offset;
                value.* += @as(u64, encrypted_block[byte_offset] & first_mask) << first_offset;

                const second_offset: u6 = @as(u5, 16) + bit_offset;
                value.* += @as(u64, encrypted_block[byte_offset + 1]) << second_offset;

                const final_offset: u5 = @intCast(8 + bit_offset);
                const final_mask: u32 = 0xFF;
                const final_mask_offset: u5 = @intCast(8 - bit_offset);
                value.* += @as(u64, encrypted_block[byte_offset + 2] & final_mask << final_mask_offset) << final_offset;
                value.* = cipher.reverse_endianness(value.*);

                const remainder_mask = cipher.get_remainder_bit_mask(i);
                const remainder: u32 = @intCast(encrypted_block[byte_offset + 2] & remainder_mask);
                const remainder_adjust: u5 = @intCast(6 - bit_offset);
                value.* += (remainder << 16) >> remainder_adjust;
            }
        }

        // Decrypt the blocks with the XOR keys
        {
            var i = unmasked_block.len - 1;

            while (i > 0) {
                unmasked_block[i - 1] ^= decrypt_keys.xor_key[i - 1] ^ (unmasked_block[i] & 0xFFFF);
                i -= 1;
            }
        }

        // Decrypt the blocks with the XOR, Modulus and Decrypt keys
        {
            for (0..unmasked_block.len) |i| {
                var result = decrypt_keys.xor_key[i] ^ unmasked_block[i] * decrypt_keys.key[i] % decrypt_keys.modulus_key[i];

                if (i > 0) {
                    result ^= unmasked_block[i - 1] & 0xFFFF;
                }

                decrypted_block[2 * i] = result & 0xFF; // Lower byte
                decrypted_block[2 * i + 1] = (result >> 8) & 0xFF; // Higher byte
            }
        }

        const block_suffix: [2]u8 = .{ encrypted_block[encrypted_block.len - 2], encrypted_block[encrypted_block.len - 1] };
        const computed_block_size = xor.get_block_size(block_suffix);

        // Verify the decryption
        {
            if (computed_block_size > decrypted_block.len) {
                return error.InvalidBlockSize;
            }

            const checksum: u64 = xor.get_checksum(decrypted_block);

            if (block_suffix[1] != checksum) {
                return error.ChecksumMismatch;
            }
        }

        // Copy to output
        {
            const offset = payload_offset + block_offset;
            const output_slice = output[offset .. offset + block_size.decrypted];

            block_offset += computed_block_size;

            for (output_slice, 0..) |*value, i| {
                value.* = if (i < decrypted_block.len) @intCast(decrypted_block[i]) else 0;
            }
        }
    }

    // Format packet header
    {
        output[0] = header[0];
        output = output[0 .. block_offset + header_size - counter];

        switch (output[0]) {
            0xC2, 0xC4 => {
                output[1] = @intCast((output.len & 0xFF00) >> 8);
                output[2] = @intCast(output.len & 0x00FF);
            },
            else => {
                output[1] = @intCast(output.len);
            },
        }
    }

    return xor.decrypt_xor32(output, header_size);
}

test decrypt {
    const encrypted = [_]u8{
        195, 90,  190, 36,  23,  232, 33,  50,  210, 237, 20,  177, 132, 248, 68,
        13,  224, 226, 67,  1,   208, 117, 123, 78,  226, 100, 76,  187, 203, 122,
        160, 178, 101, 28,  41,  15,  71,  126, 84,  195, 188, 64,  53,  57,  167,
        146, 220, 162, 25,  103, 151, 62,  145, 132, 76,  134, 179, 108, 81,  32,
        17,  208, 125, 112, 115, 8,   125, 72,  195, 199, 29,  110, 99,  59,  33,
        206, 13,  27,  46,  211, 192, 41,  220, 86,  149, 242, 181, 44,  228, 218,
    };

    const actual = try decrypt(encrypted[0..], @import("keys.zig").server_keys, false);
    const expected = [_]u8{
        195, 60,  241, 1,   205, 253, 152, 252, 207, 171, 252, 207, 171, 252, 205,
        253, 152, 252, 207, 171, 252, 207, 171, 252, 207, 171, 252, 207, 171, 252,
        207, 171, 252, 207, 93,  116, 201, 66,  49,  48,  52,  48,  52,  107, 49,
        80,  107, 50,  106, 99,  69,  84,  52,  56,  109, 120, 76,  51,  98,  0,
    };

    try std.testing.expectEqual(expected.len, actual.len);
    try std.testing.expect(std.mem.eql(u8, expected[0..], actual));
}
