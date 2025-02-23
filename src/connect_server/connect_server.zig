const std = @import("std");
const config = @import("config.zig");

pub const ConnectServer = struct {
    server_list: config.Servers,

    pub fn init() !ConnectServer {
        return ConnectServer{
            .server_list = try config.get_server_list(),
        };
    }
};
