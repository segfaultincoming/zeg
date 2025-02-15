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
        try sendHello(client);

        var buffer: [256]u8 = undefined;
        const read = posix.read(client, &buffer) catch |err| {
            std.debug.print("Client disconnected {}. Reason: {}\n", .{ client_addr, err });
            continue;
        };

        if (read == 0) {
            continue;
        }

        const bytes: []const u8 = buffer[0..read];
        logger.log_bytes(bytes, logger.LogType.RECEIVE);
        const packet = try packets.parse(bytes);
        const response = try packets.handle(InPackets, packet);

        switch (response) {
            .Fail => std.debug.print("Package handling failed!", .{}),
            .Success => std.debug.print("Package handling succeeded", .{}),
        }
    }
}

// TODO: This shouldn't a function here
fn sendHello(socket: posix.socket_t) !void {
    const hello_data = OutPackets{ .hello = .init() };
    try write(socket, hello_data.to_client());
}

fn write(socket: posix.socket_t, packet: []const u8) !void {
    var pos: usize = 0;

    logger.log_bytes(packet, logger.LogType.SEND);

    while (pos < packet.len) {
        const written = try posix.write(socket, packet[pos..]);
        if (written == 0) {
            return error.Closed;
        }
        pos += written;
    }
}
