const std = @import("std");
const tcp = @import("tcp_server");

const Context = @import("context.zig").Context;
const ConnectServer = @import("connect_server.zig").ConnectServer;

pub fn start() !void {
    const server = tcp.Server.create("192.168.0.182", 44405) catch |err| {
        std.debug.print("Couldn't bind to a socket. {}", .{err});
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

    while (true) {
        var client_addr: std.net.Address = undefined;

        const client = server.accept(&client_addr) catch |err| {
            std.debug.print("error accept: {}\n", .{err});
            return;
        };

        std.debug.print("{} connected\n", .{client_addr});

        const context = Context{
            .client_address = client_addr,
            .connect_server = connect_server,
            .player = null,
        };

        try pool.spawn(ConnectServer.handle_packets, .{ client, context });
    }
}
