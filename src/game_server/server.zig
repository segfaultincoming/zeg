const std = @import("std");
const tcp = @import("tcp_server");

const Packets = @import("packets/in/main.zig").Packets;
const Handshake = @import("packets/out/main.zig").LoginShow;
const GameServer = @import("game_server.zig").GameServer;

const Server = tcp.server(
    GameServer,
    Packets,
    .{
        .handshake = handshake,
        .disconnect = disconnect
    },
);

pub fn start() !void {
    const server = Server.create("GameServer", "192.168.0.182", 55901) catch |err| {
        std.debug.print("[GameServer] Couldn't bind to a socket. {}", .{err});
        return;
    };
    defer server.close();

    var pool: std.Thread.Pool = undefined;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    try std.Thread.Pool.init(&pool, .{
        .allocator = gpa.allocator(),
        .n_jobs = 128,
    });
    defer std.Thread.Pool.deinit(&pool);

    try server.listen(&pool);
}

fn handshake(_: std.net.Stream) []const u8 {
    return Handshake.init().to_client() catch |err| {
        std.debug.print("[GameServer] Error while creating handshake: {}\n", .{err});
        return &[_]u8{};
    };
}

fn disconnect(player_id: tcp.ConnectionId) void {
    std.debug.print("[GameServer] Disconnecting 0x{x}\n", .{player_id});
    GameServer.remove(player_id);
}