const std = @import("std");
const allocator = std.heap.page_allocator;

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
