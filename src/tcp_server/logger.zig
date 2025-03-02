const std = @import("std");
const print = std.debug.print;

pub const Logger = struct {
    name: []const u8,

    pub fn info(self: *const Logger, comptime msg: []const u8, args: anytype) void {
        std.debug.print("[{s}] " ++ msg ++ "\n", .{self.name} ++ args);
    }
};
