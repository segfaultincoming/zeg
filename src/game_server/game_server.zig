const std = @import("std");
const Context = @import("context.zig").Context;
const handler = @import("./packets/handler.zig").handle_packets;

pub const GameServer = struct {
    pub fn init() !GameServer {
        return GameServer{};
    }

    pub fn handle_packets(client: std.posix.socket_t, context: Context) void {
        handler(client, context) catch |err| {
            std.debug.print("[GameServer] ERR: Handle packets returned error: {}\n", .{err});
        };
    }
};
