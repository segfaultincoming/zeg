const std = @import("std");
const tcp = @import("tcp_server");

const InPackets = @import("packets/in/main.zig").Packets;
const OutPackets = @import("packets/out/main.zig");
const ConnectServer = @import("connect_server.zig").ConnectServer;

pub fn start() !void {
    const server = tcp.Server.create("ConnectServer", "192.168.0.182", 44405) catch |err| {
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
        tcp.Context{
            .server = &connect_server,
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
    const hello = OutPackets.Hello.init();
    const hello_data = hello.to_client() catch |err| {
        std.debug.print("Couldn't generate handshake: {}\n", .{err});
        return;
    };

    stream.writeAll(hello_data) catch |err| {
        std.debug.print("Couldn't send handshake: {}\n", .{err});
    };
}
