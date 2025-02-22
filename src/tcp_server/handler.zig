const std = @import("std");
const packets = @import("packets");

const tcp = @import("./server.zig");
const utils = @import("./utils.zig");

pub const Options = struct {
    init: *const fn (stream: std.net.Stream) void,
};

pub fn handle_packets(
    comptime InPackets: type,
    server: *const tcp.Server,
    client: std.posix.socket_t,
    context: tcp.Context,
    options: Options,
) !void {
    defer std.posix.close(client);

    const stream = std.net.Stream{ .handle = client };
    const client_address = try utils.get_client_address(client);

    options.init(stream);

    while (true) {
        var buffer: [256]u8 = undefined;

        // TODO: Do we (or when we'd) need message boundary?
        // 1. Read header type 0xC1...C4
        // 2. Read size (next 1 or 2 bytes)
        // 3. Read *size* more bytes
        const read = stream.read(&buffer) catch |err| {
            std.debug.print(
                "[{s}] Client disconnected {} ({})\n",
                .{ server.name, client_address, err },
            );
            break;
        };

        if (read == 0 or read > buffer.len) {
            continue;
        }

        const bytes = buffer[0..read];
        const packet = try packets.parse(bytes);

        std.debug.print(
            "[{s}] Packet received: 0x{x:0>2} 0x{x:0>2} 0x{x:0>2} 0x{x:0>2}\n",
            .{ server.name, @intFromEnum(packet.type), packet.size, packet.code, packet.sub_code },
        );

        const response = packets.handle(
            InPackets,
            context.server,
            packet,
        ) catch |err| {
            std.debug.print(
                "[{s}] Couldn't handle packet({any}): 0x{x:0>2} 0x{x:0>2} 0x{x:0>2} 0x{x:0>2}\n",
                .{ server.name, err, @intFromEnum(packet.type), packet.size, packet.code, packet.sub_code },
            );
            continue;
        };

        switch (response.code) {
            .Fail => std.debug.print("[{s}] Package handling failed!\n", .{server.name}),
            .Success => std.debug.print("[{s}] Package handling succeeded.\n", .{server.name}),
        }

        if (response.packet) |response_packet| {
            try stream.writeAll(response_packet);
            std.debug.print("[{s}] Packet sent: {x:0>2}\n", .{ server.name, response_packet });
        }
    }
}
