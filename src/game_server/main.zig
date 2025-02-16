const std = @import("std");
const tcp = @import("tcp_server");

const Context = @import("context.zig").Context;
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

    while (true) {
        var client_addr: std.net.Address = undefined;

        const client = server.accept(&client_addr) catch |err| {
            std.debug.print("[GameServer] error accept: {}\n", .{err});
            return;
        };

        std.debug.print("[GameServer] {} connected\n", .{client_addr});

        const context = Context{
            .client_address = client_addr,
            .game_server = game_server,
            .player = null,
        };

        try pool.spawn(GameServer.handle_packets, .{ client, context });
    }
}
