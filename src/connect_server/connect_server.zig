const std = @import("std");
const ConnectionId = @import("tcp_server").ConnectionId;
const config = @import("config.zig");

pub const ConnectServer = struct {
    connection_id: ConnectionId,
    server_list: config.Servers,

    pub fn init(connection_id: ConnectionId) ConnectServer {
        return ConnectServer{
            .connection_id = connection_id,
            .server_list = config.get_server_list() catch |err| {
                std.debug.print("[ConntectServer] Failed to create server list: {}\n", .{err});
                unreachable;
            },
        };
    }
};
