const std = @import("std");
const ConnectServer = @import("connect_server.zig").ConnectServer;

pub const Context = struct {
    client_address: std.net.Address,
    connect_server: *const ConnectServer,
    player: ?Player,
};

pub const Player = struct {
    username: [:0] u8,
};