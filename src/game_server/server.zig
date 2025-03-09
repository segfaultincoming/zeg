const std = @import("std");
const tcp = @import("tcp_server");

const InPackets = @import("packets/in/main.zig").Packets;
const OutPackets = @import("packets/out/main.zig");
const GameServer = @import("game_server.zig").GameServer;

const Server = tcp.server(
    GameServer,
    InPackets,
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

fn handshake(stream: std.net.Stream) []const u8 {
    _ = stream;

    return OutPackets.LoginShow.init().to_client() catch |err| {
        std.debug.print("[GameServer] Error while creating handshake: {}\n", .{err});
        return &[_]u8{};
    };
}

fn disconnect(player_id: u64) void {
    std.debug.print("[GameServer] Disconnecting 0x{x}\n", .{player_id});
    GameServer.remove(player_id);
}