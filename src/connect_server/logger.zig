const std = @import("std");

pub const LogType = enum(u4) {
    SEND,
    RECEIVE
};

pub fn log_bytes(packet: []const u8, log_type: LogType) void {
    std.debug.print("{s}: ", .{@tagName(log_type)});
    for (packet) |value| {
        std.debug.print("0x{x:0>2} ", .{value});
    }
    std.debug.print("\n", .{});
}
