const std = @import("std");
const allocator = std.heap.page_allocator;

pub const CipherBlocks = struct {
    encrypted: u8,
    decrypted: u8,
    unmasked: u8,
};

pub const CipherVersion = enum(u16) { New, Old };

pub fn get_block_sizes(version: CipherVersion) CipherBlocks {
    return switch (version) {
        CipherVersion.New => CipherBlocks{
            .decrypted = 8,
            .encrypted = 11,
            .unmasked = 4
        },
        else => CipherBlocks{
            .decrypted = 32,
            .encrypted = 38,
            .unmasked = 16
        },
    };
}

pub fn split_into_blocks(packet: []const u8, size: usize) ![][]u8 {
    const blocks = try block_alloc([]u8, packet.len / size);

    for (blocks, 0..) |*chunk, i| {
        const start = i * size;
        const end = start + size;
        chunk.* = try block_alloc(u8, size);
        std.mem.copyForwards(u8, chunk.*, packet[start..end]);
    }

    return blocks;
}

pub fn block_alloc(T: type, size: usize) ![]T {
    return try allocator.alloc(T, size);
}
