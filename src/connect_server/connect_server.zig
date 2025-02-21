const std = @import("std");
const config = @import("config.zig");
const Context = @import("context.zig").Context;
const handler = @import("./packets/handler.zig").handle_packets;

pub const ConnectServer = struct {
    server_list: config.Servers,

    pub fn init() !ConnectServer {
        return ConnectServer{
            .server_list = try config.get_server_list(),
        };
    }
};
