const std = @import("std");
const keys = @import("keys.zig");

const bits_per_byte: u32 = 8;
const bits_per_value: u32 = bits_per_byte * 2 + 2;

pub const CipherBlocks = struct {
    encrypted: u8,
    decrypted: u8,
    unmasked: u8,
};

pub const CipherVersion = enum(u16) { New, Old };

pub fn get_block_sizes(version: CipherVersion) CipherBlocks {
    return switch (version) {
        CipherVersion.New => CipherBlocks{ .decrypted = 8, .encrypted = 11, .unmasked = 4 },
        else => CipherBlocks{ .decrypted = 32, .encrypted = 38, .unmasked = 16 },
    };
}

pub fn get_byte_offset(idx: usize) u4 {
    return @intCast(get_bit_index(idx) / bits_per_byte);
}

pub fn get_bit_offset(idx: usize) u4 {
    return @intCast(get_bit_index(idx) % bits_per_byte);
}

pub fn get_first_bit_mask(idx: usize) u9 {
    const bit_offset = get_bit_offset(idx);
    const mask: u9 = 0xFF;
    return (mask >> bit_offset);
}

pub fn get_remainder_bit_mask(idx: usize) u32 {
    const mask: u32 = 0xFF;
    const first_shift_offset: u5 = @intCast(6 - get_bit_offset(idx));
    const second_shift_offset: u5 = @intCast(8 - get_bit_offset(idx));
    return (mask << first_shift_offset & mask) - (mask << second_shift_offset & mask);
}

pub fn get_bit_index(idx: usize) u8 {
    const idx_u32: u4 = @intCast(idx);
    return @intCast(idx_u32 * bits_per_value);
}

pub fn get_max_decrypted_size(packet: []const u8, block_size: CipherBlocks) u32 {
    const content_size = get_payload_size(packet);
    return content_size * block_size.decrypted / block_size.encrypted + get_header_size(packet);
}

pub fn get_payload_size(packet: []const u8) u32 {
    return get_size(packet) - get_header_size(packet);
}

pub fn get_content_size(packet: []const u8, counter: u32, decrypted: bool) u32 {
    var content_size = get_payload_size(packet);

    if (counter > 0 and decrypted) {
        content_size += 1;
    }

    return content_size;
}

pub fn get_header_size(packet: []const u8) u32 {
    return switch (packet[0]) {
        0xC1, 0xC3 => 2,
        0xC2, 0xC4 => 3,
        else => 0,
    };
}

pub fn get_size(packet: []const u8) u32 {
    return switch (packet[0]) {
        0xC1, 0xC3 => packet[1],
        0xC2, 0xC4 => @as(u32, packet[1]) << 8 | packet[2],
        else => 0,
    };
}

pub fn reverse_endianness(x: u64) u64 {
    return (x & 0xFF000000) >> 24 |
        (x & 0x00FF0000) >> 8 |
        (x & 0x0000FF00) << 8 |
        (x & 0x000000FF) << 24;
}
