const std = @import("std");
const packets = @import("packets");
const InPackets = @import("in/main.zig").Packets;
const OutPackets = @import("out/main.zig");
const Context = @import("../context.zig").Context;

pub fn handle_packets(client: std.posix.socket_t, context: Context) !void {
    defer std.posix.close(client);

    const stream = std.net.Stream{ .handle = client };

    // Sending a Hello packet to the client will tell the game to start sending packets to the server
    const hello = OutPackets.Hello.init();
    const hello_data = try hello.to_client();
    try stream.writeAll(hello_data);

    while (true) {
        var buffer: [256]u8 = undefined;

        // TODO: Do we (or when we'd) need message boundary?
        // 1. Read header type 0xC1...C4
        // 2. Read size (next 1 or 2 bytes)
        // 3. Read *size* more bytes
        const read = stream.read(&buffer) catch |err| {
            std.debug.print(
                "[ConnectServer] Client disconnected {} ({})\n",
                .{ context.client_address, err },
            );
            break;
        };

        if (read == 0 or read > buffer.len) {
            continue;
        }

        const bytes = buffer[0..read];
        const packet = try packets.parse(bytes);

        std.debug.print(
            "[ConnectServer] Packet received: 0x{x:0>2} 0x{x:0>2} 0x{x:0>2} 0x{x:0>2}\n",
            .{ @intFromEnum(packet.type), packet.size, packet.code, packet.sub_code },
        );

        const response = packets.handle(
            InPackets,
            &context.connect_server,
            packet,
        ) catch |err| {
            std.debug.print(
                "[ConnectServer] Couldn't handle packet({any}): 0x{x:0>2} 0x{x:0>2} 0x{x:0>2} 0x{x:0>2}\n",
                .{ err, @intFromEnum(packet.type), packet.size, packet.code, packet.sub_code },
            );
            continue;
        };

        switch (response.code) {
            .Fail => std.debug.print("[ConnectServer] Package handling failed!\n", .{}),
            .Success => std.debug.print("[ConnectServer] Package handling succeeded.\n", .{}),
        }

        if (response.packet) |response_packet| {
            try stream.writeAll(response_packet);
            std.debug.print("[ConnectServer] Packet sent: {x:0>2}\n", .{response_packet});
        }
    }
}
