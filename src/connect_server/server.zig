const std = @import("std");
const posix = std.posix;
const net = std.net;
const allocator = std.heap.page_allocator;

const Packet = @import("../packets/out/packets.zig").Packet;
const PacketType = @import("../packets/types.zig").PacketType;
const ServerRequest = @import("../packets/in/servers_request.zig").ServersRequest;
const logger = @import("logger.zig");

pub fn start() !void {
    const server_addr = try net.Address.parseIp("192.168.0.182", 44405);
    const socket = try posix.socket(server_addr.any.family, posix.SOCK.STREAM, posix.IPPROTO.TCP);
    defer posix.close(socket);

    std.debug.print("Server listening on {}\n", .{server_addr});

    try posix.setsockopt(socket, posix.SOL.SOCKET, posix.SO.REUSEADDR, &std.mem.toBytes(@as(c_int, 1)));
    try posix.bind(socket, &server_addr.any, server_addr.getOsSockLen());
    try posix.listen(socket, 128);

    while (true) {
        var client_addr: net.Address = undefined;
        var client_addr_len: posix.socklen_t = @sizeOf(net.Address);

        const client = posix.accept(socket, &client_addr.any, &client_addr_len, posix.SOCK.NONBLOCK) catch |err| {
            std.debug.print("error accept: {}\n", .{err});
            continue;
        };

        std.debug.print("{} connected\n", .{client_addr});
        try sendHello(client);

        var buffer: [128]u8 = undefined;
        const read = posix.read(client, &buffer) catch |err| {
            std.debug.print("Client disconnected {}. Reason: {}\n", .{ client_addr, err });
            continue;
        };

        if (read == 0) {
            continue;
        }

        const packet: []const u8 = buffer[0..read];
        const header: PacketType = @enumFromInt(packet[0]);

        logger.log_bytes(packet, logger.LogType.RECEIVE);

        switch (header) {
            PacketType.C1 => {
                const code = packet[2];
                const sub_code = packet[3];

                switch (code) {
                    0xf4 => {
                        switch (sub_code) {
                            0x06 => ServerRequest.response(),
                            else => continue
                        }
                    },
                    else => continue
                }

            },
            PacketType.C2 => {},
            PacketType.C3 => {},
            PacketType.C4 => {},
        }
    }
}

fn sendHello(socket: posix.socket_t) !void {
    const hello_data = Packet{ .hello = .init() };
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