const std = @import("std");
const ConnectServer = @import("connect_server.zig").ConnectServer;

pub const Context = struct {
    connect_server: ConnectServer,
    player: ?Player,
};

pub const Player = struct {
    username: [:0] u8,
};