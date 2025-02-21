const std = @import("std");
const GameServer = @import("game_server.zig").GameServer;

pub const Context = struct {
    client_address: std.net.Address,
    game_server: *const GameServer,
    player: ?Player,
};

pub const Player = struct {
    username: [:0]u8,
};
