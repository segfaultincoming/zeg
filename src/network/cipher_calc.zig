const std = @import("std");
const print = std.debug.print;
const allocator = std.heap.page_allocator;
const keys = @import("keys.zig");

const bits_per_byte: u32 = 8;
const bits_per_value: u32 = bits_per_byte * 2 + 2;

pub const CipherBlocks = struct {
    encrypted: u8,
    decrypted: u8,
    unmasked: u8,
};

pub const CipherVersion = enum(u16) { New, Old };

pub fn split_into_blocks(packet: []const u8, size: usize) ![][]u8 {
    const blocks = try allocator.alloc([]u8, packet.len / size);

    for (blocks, 0..) |*chunk, i| {
        const start = i * size;
        const end = start + size;
        chunk.* = try allocator.alloc(u8, size);
        std.mem.copyForwards(u8, chunk.*, packet[start..end]);
    }

    return blocks;
}

pub fn block_alloc(T: type, size: usize) ![]T {
    return try allocator.alloc(T, size);
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

pub fn get_block_sizes(version: CipherVersion) CipherBlocks {
    return switch (version) {
        CipherVersion.New => CipherBlocks{ .decrypted = 8, .encrypted = 11, .unmasked = 4 },
        else => CipherBlocks{ .decrypted = 32, .encrypted = 38, .unmasked = 16 },
    };
}

// Returns 4 bits
pub fn get_byte_offset(idx: usize) u4 {
    return @intCast(get_bit_index(idx) / bits_per_byte);
}

// Max % is 9
pub fn get_bit_offset(idx: usize) u4 {
    return @intCast(get_bit_index(idx) % bits_per_byte);
}

// Returns 8 bits
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

pub fn print_blocks(blocks: [][]u8) void {
    for (blocks) |block| {
        print_bytes(block);
    }
}

pub fn print_bytes(bytes: []const u8) void {
    std.debug.print("\n", .{});
    std.debug.print("---------------------------------------------------\n", .{});
    std.debug.print("BYTES BYTES ({d})\n", .{bytes.len});
    std.debug.print("---------------------------------------------------\n", .{});
    var chunk_idx: u32 = 0;
    for (bytes, 1..) |byte, i| {
        std.debug.print("0x{x:0>2} ", .{byte});
        if (i % 8 == 0) {
            print(" [{d}]\n", .{chunk_idx});
            chunk_idx += 1;
        }
    }
    if (bytes.len % 8 != 0) {
        std.debug.print("[{d}]\n", .{chunk_idx});
    }
    std.debug.print("--------------------------------------------------\n", .{});
}

pub fn reverse_endianness(x: u64) u64 {
    return (x & 0xFF000000) >> 24 |
        (x & 0x00FF0000) >> 8 |
        (x & 0x0000FF00) << 8 |
        (x & 0x000000FF) << 24;
}
