const std = @import("std");
const network = @import("network");
const PacketType = @import("types.zig").PacketType;

const mem = std.mem;
const Endian = std.builtin.Endian;
const allocator = std.heap.page_allocator;

pub fn split_into_bytes(comptime T: type, value: T, endian: Endian) ![]const u8 {
    const size = @sizeOf(T);
    var buffer = try block_alloc(u8, size);
    mem.writeInt(T, buffer[0..size], value, endian);
    return buffer[0..];
}

pub fn write_into_bytes(comptime T: type, value: T, buffer: [@sizeOf(T)]u8) void {
    mem.writeInt(T, buffer, value, .big);
}

pub fn block_alloc(T: type, size: usize) ![]T {
    return try allocator.alloc(T, size);
}

pub fn create_packet(
    packet_type: PacketType,
    code: u8,
    sub_code: u8,
    data: []const []const u8,
) ![]const u8 {
    const payload = try std.mem.concat(allocator, u8, data);
    const header = try create_header(packet_type, payload.len, code, sub_code);
    return try std.mem.concat(allocator, u8, &.{ header, payload });
}

pub fn create_header(
    packet_type: PacketType,
    payload_size: usize,
    code: u8,
    sub_code: u8,
) ![]const u8 {
    const length_size = get_length_size(packet_type);
    const header_size: usize = 3 + length_size;
    const size = payload_size + header_size;

    var header = try block_alloc(u8, header_size);

    header[0] = @intFromEnum(packet_type);

    switch (length_size) {
        1 => header[1] = @intCast(size),
        2 => std.mem.copyForwards(
            u8,
            header[1 .. length_size + 1],
            try split_into_bytes(u16, @intCast(size), .big),
        ),
        else => unreachable,
    }

    header[length_size + 1] = code;
    header[length_size + 2] = sub_code;

    return header;
}

pub fn get_length_size(packet_type: PacketType) usize {
    return switch (packet_type) {
        .C1, .C3 => 1,
        .C2, .C4 => 2,
    };
}
