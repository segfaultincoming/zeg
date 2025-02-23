const std = @import("std");
const tcp = @import("tcp_server");

const InPackets = @import("packets/in/main.zig").Packets;
const OutPackets = @import("packets/out/main.zig");
const GameServer = @import("game_server.zig").GameServer;

pub fn start() !void {
    const server = tcp.Server.create("GameServer", "192.168.0.182", 55901) catch |err| {
        std.debug.print("[GameServer] Couldn't bind to a socket. {}", .{err});
        return;
    };
    defer server.close();

    const game_server = GameServer.init() catch |err| {
        return err;
    };

    var pool: std.Thread.Pool = undefined;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    try std.Thread.Pool.init(&pool, .{
        .allocator = gpa.allocator(),
        .n_jobs = 128,
    });
    defer std.Thread.Pool.deinit(&pool);

    try server.listen(
        tcp.Context{
            .server = &game_server,
            // .handshake = handshake,
            // .create_context = create_context,
            .handle_packets = handle_packets,
        },
        &pool,
    );
}

fn handle_packets(server: *const tcp.Server, client: std.posix.socket_t, context: tcp.Context) void {
    tcp.handler(
        InPackets,
        server,
        client,
        context,
        .{ .init = handshake },
    ) catch |err| {
        std.debug.print("[{s}] ERR: Handle packets returned error: {}\n", .{ server.name, err });
    };
}

fn handshake(stream: std.net.Stream) void {
    const show_login = OutPackets.LoginShow.init();
    const show_login_data = show_login.to_client() catch |err| {
        std.debug.print("[GameServer] Error while creating handshake: {}\n", .{err});
        return;
    };

    stream.writeAll(show_login_data) catch |err| {
        std.debug.print("[GameServer] Error while sending handshake: {}\n", .{err});
    };
}
