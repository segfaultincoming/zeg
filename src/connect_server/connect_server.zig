const std = @import("std");
const config = @import("config.zig");

pub const ConnectServer = struct {
    player_id: u64,
    server_list: config.Servers,

    pub fn init(player_id: u64) ConnectServer {
        return ConnectServer{
            .player_id = player_id,
            .server_list = config.get_server_list() catch |err| {
                std.debug.print("[ConntectServer] Failed to create server list: {}\n", .{err});
                unreachable;
            },
        };
    }
};
