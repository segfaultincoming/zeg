const std = @import("std");
const ConnectServer = @import("connect_server.zig").ConnectServer;
const handle_packets = @import("./packets/handler.zig").handle_packets;

const posix = std.posix;
const net = std.net;

pub fn start() !void {
    const server_addr = try net.Address.parseIp("192.168.0.182", 44405);
    const socket = try posix.socket(
        server_addr.any.family,
        posix.SOCK.STREAM,
        posix.IPPROTO.TCP,
    );
    defer posix.close(socket);

    std.debug.print("Server listening on {}\n", .{server_addr});

    try posix.setsockopt(
        socket,
        posix.SOL.SOCKET,
        posix.SO.REUSEADDR,
        &std.mem.toBytes(@as(c_int, 1)),
    );
    try posix.bind(
        socket,
        &server_addr.any,
        server_addr.getOsSockLen(),
    );
    try posix.listen(socket, 128);

    const connect_server = ConnectServer.init() catch |err| {
        return err;
    };

    while (true) {
        var client_addr: net.Address = undefined;
        var client_addr_len: posix.socklen_t = @sizeOf(net.Address);

        const client = posix.accept(
            socket,
            &client_addr.any,
            &client_addr_len,
            posix.SOCK.NONBLOCK,
        ) catch |err| {
            std.debug.print("error accept: {}\n", .{err});
            return;
        };

        std.debug.print("{} connected\n", .{client_addr});

        try handle_packets(
            connect_server,
            client,
            client_addr,
        );
    }
}
