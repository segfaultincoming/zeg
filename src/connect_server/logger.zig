const std = @import("std");

pub const LogType = enum(u4) {
    SEND,
    RECEIVE,
    RESPONSE,
};

pub fn log_bytes(packet: []const u8, log_type: LogType) void {
    std.debug.print("{s}: {x:0>2}\n", .{@tagName(log_type), packet});
}
