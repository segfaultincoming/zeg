const std = @import("std");
const connect_server = @import("connect_server/main.zig");
const game_server = @import("game_server/main.zig");

pub fn main() !void {
    const cs = try std.Thread.spawn(.{}, connect_server.start, .{});
    const gs = try std.Thread.spawn(.{}, game_server.start, .{});
    cs.join();
    gs.join();
}
