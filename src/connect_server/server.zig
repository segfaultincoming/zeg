const std = @import("std");
const Server = @import("utils.zig").Server;
const Context = @import("context.zig").Context;
const ConnectServer = @import("connect_server.zig").ConnectServer;
const handle_packets = @import("./packets/handler.zig").handle_packets;

const posix = std.posix;
const net = std.net;

pub fn start() !void {
    const server = Server.create("192.168.0.182", 44405) catch |err| {
        std.debug.print("Couldn't bind to a socket. {}", .{err});
        return;
    };
    defer posix.close(server.socket);

    const connect_server = ConnectServer.init() catch |err| {
        return err;
    };

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var pool: std.Thread.Pool = undefined;

    try std.Thread.Pool.init(&pool, .{
        .allocator = allocator,
        .n_jobs = 128,
    });

    while (true) {
        var client_addr: net.Address = undefined;

        const client = server.accept(
            &client_addr,
            posix.SOCK.NONBLOCK,
        ) catch |err| {
            std.debug.print("error accept: {}\n", .{err});
            return;
        };

        std.debug.print("{} connected\n", .{client_addr});

        const context = Context{
            .client_address = client_addr,
            .connect_server = connect_server,
            .player = null,
        };

        try pool.spawn(handle_packets, .{ client, context });
    }
}
