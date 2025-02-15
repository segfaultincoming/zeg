const std = @import("std");
const allocator = std.heap.page_allocator;

pub fn split_into_bytes(comptime T: type, value: T) ![]const u8 {
    const size = @sizeOf(T);
    var buffer = try block_alloc(u8, size);
    std.mem.writeInt(T, buffer[0..size], value, .big);
    return buffer[0..];
}

pub fn write_into_bytes(comptime T: type, value: T, buffer: [@sizeOf(T)]u8) void {
    std.mem.writeInt(T, buffer, value, .big);
}

pub fn block_alloc(T: type, size: usize) ![]T {
    return try allocator.alloc(T, size);
}