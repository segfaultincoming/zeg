const std = @import("std");
const tcp = @import("tcp_server");

const InPackets = @import("packets/in/main.zig").Packets;
const OutPackets = @import("packets/out/main.zig");
const ConnectServer = @import("connect_server.zig").ConnectServer;

const Server = tcp.server(
    ConnectServer,
    InPackets,
    .{ .handshake = handshake },
);

pub fn start() !void {
    const server = Server.create("ConnectServer", "192.168.0.182", 44405) catch |err| {
        std.debug.print("[ConnectServer] Couldn't bind to a socket. {}", .{err});
        return;
    };
    defer server.close();

    const connect_server = ConnectServer.init() catch |err| {
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
        Server.Context{ .server = &connect_server },
        &pool,
    );
}

fn handshake(stream: std.net.Stream) []const u8 {
    _ = stream;

    return OutPackets.Hello.init().to_client() catch |err| {
        std.debug.print("[ConnectServer] Error while creating handshake: {}\n", .{err});
        return &[_]u8{};
    };
}
