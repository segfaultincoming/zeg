const std = @import("std");
const tcp = @import("tcp_server");

const Context = @import("context.zig").Context;
const ConnectServer = @import("connect_server.zig").ConnectServer;
const handler = @import("./packets/handler.zig").handle_packets;

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
            .create_context = create_context,
            .handle_packets = handle_packets,
        },
        &pool,
    );
}

fn create_context(self: *const tcp.Context, client_addr: std.net.Address) *const anyopaque {
    return &Context{
        .client_address = client_addr,
        .connect_server = @ptrCast(@alignCast(self.server)),
        .player = null,
    };
}

fn handle_packets(server: *const tcp.Server, client: std.posix.socket_t, context: *const anyopaque) void {
    const server_context: *const Context = @ptrCast(@alignCast(context));

    handler(client, server_context) catch |err| {
        std.debug.print("[{s}] ERR: Handle packets returned error: {}\n", .{ server.name, err });
    };
}
