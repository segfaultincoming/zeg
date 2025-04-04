const std = @import("std");
const alloc = @import("cipher_structure.zig").block_alloc;
const keys = @import("keys.zig");

pub fn decrypt_xor3(packet: []const u8) ![]u8 {
    return encrypt_xor2(packet);
}

pub fn encrypt_xor2(packet: []const u8) ![]u8 {
    const result = try alloc(u8, packet.len);

    for (packet, 0..) |value, i| {
        result[i] = value ^ keys.xor3_keys[i % 3];
    }

    return result;
}

pub fn decrypt_xor32(packet: []u8, offset: u32) []u8 {
    var i = packet.len - 1;

    while (i > offset) {
        packet[i] = packet[i] ^ packet[i - 1] ^ keys.xor32_keys[i % 32];
        i -= 1;
    }

    return packet;
}

pub fn get_checksum(block: []u64) u64 {
    var checksum: u64 = keys.checksum_xor_key;
    for (0..block.len) |i| {
        checksum ^= block[i];
    }
    return checksum;
}

pub fn get_block_size(block_suffix: [2]u8) u8 {
    return block_suffix[0] ^ block_suffix[1] ^ keys.block_size_xor_key;
}

test decrypt_xor32 {
    var encrypted = [_]u8{
        193, 14,  243, 24, 116, 50,  132,
        83,  170, 169, 88, 208, 221, 186,
    };
    const decrypted = decrypt_xor32(encrypted[0..], 2);
    const expected = [_]u8{
        193, 14, 243, 21, 116, 101, 115,
        116, 51, 48,  48, 68,  107, 0,
    };

    try std.testing.expect(std.mem.eql(u8, decrypted, &expected));
}
