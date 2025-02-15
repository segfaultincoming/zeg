const std = @import("std");
const servers = @import("servers/main.zig");
const Context = @import("context.zig").Context;
const handler = @import("./packets/handler.zig").handle_packets;

pub const ConnectServer = struct {
    server_list: servers.ServerList,

    pub fn init() !ConnectServer {
        return ConnectServer{
            .server_list = try servers.get_server_list(),
        };
    }

    pub fn handle_packets(client: std.posix.socket_t, context: Context) void {
        handler(client, context) catch |err| {
            std.debug.print("ERR: Handle packets returned error: {}\n", .{err});
        };
    }
};
