const std = @import("std");
const packets = @import("../packets/main.zig");
const InPackets = @import("./packets/in/main.zig").Packets;
const OutPackets = @import("./packets/out/main.zig").Packets;
const logger = @import("logger.zig");

const posix = std.posix;
const net = std.net;
const allocator = std.heap.page_allocator;

pub fn start() !void {
    const server_addr = try net.Address.parseIp("192.168.0.182", 44405);
    const socket = try posix.socket(server_addr.any.family, posix.SOCK.STREAM, posix.IPPROTO.TCP);
    defer posix.close(socket);

    std.debug.print("Server listening on {}\n", .{server_addr});

    try posix.setsockopt(
        socket,
        posix.SOL.SOCKET,
        posix.SO.REUSEADDR,
        &std.mem.toBytes(@as(c_int, 1)),
    );
    try posix.bind(socket, &server_addr.any, server_addr.getOsSockLen());
    try posix.listen(socket, 128);

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
            continue;
        };

        std.debug.print("{} connected\n", .{client_addr});

        // Sendind a Hello packet to the client will tell the game to start sending packets to the server
        try OutPackets.write(
            client,
            OutPackets{ .hello = .init() },
        );

        var buffer: [256]u8 = undefined;
        const read = posix.read(client, &buffer) catch |err| {
            std.debug.print("Client disconnected {}. Reason: {}\n", .{ client_addr, err });
            continue;
        };

        if (read == 0) {
            continue;
        }

        const bytes: []const u8 = buffer[0..read];
        const packet = try packets.parse(bytes);
        const response = try packets.handle(InPackets, packet);

        // NOTE: Debugging purposes
        logger.log_bytes(bytes, logger.LogType.RECEIVE);

        switch (response.code) {
            .Fail => std.debug.print("Package handling failed!\n", .{}),
            .Success => std.debug.print("Package handling succeeded\n", .{}),
        }
    }
}
