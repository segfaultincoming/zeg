const std = @import("std");
const packets = @import("packets");
const utils = @import("utils.zig");
const Logger = @import("logger.zig").Logger;

const posix = std.posix;
const net = std.net;

pub const Options = struct {
    handshake: fn (stream: net.Stream) []const u8,
};

pub fn server(comptime T: type, comptime InPackets: type, options: Options) type {
    return struct {
        const Self = @This();

        name: []const u8,
        socket: posix.socket_t,
        logger: Logger,

        pub const Context = struct {
            server: *const T,
        };

        pub fn create(name: []const u8, address: []const u8, port: u16) !Self {
            const server_addr = try net.Address.parseIp(address, port);
            const socket = try posix.socket(
                server_addr.any.family,
                posix.SOCK.STREAM,
                posix.IPPROTO.TCP,
            );
            const logger = Logger{ .name = name };

            logger.info("Self listening on {}", .{ server_addr });

            try posix.setsockopt(socket, posix.SOL.SOCKET, posix.SO.REUSEADDR, &std.mem.toBytes(@as(c_int, 1)));
            try posix.bind(socket, &server_addr.any, server_addr.getOsSockLen());
            try posix.listen(socket, 128);

            return Self{
                .socket = socket,
                .name = name,
                .logger = logger,
            };
        }

        pub fn listen(self: *const Self, context: Context, pool: *std.Thread.Pool) !void {
            while (true) {
                var client_addr: net.Address = undefined;
                const client = self.accept(&client_addr) catch |err| {
                    self.logger.info("Failed to accept: {}", .{ err });
                    return;
                };
                self.logger.info("{} connected", .{ client_addr });
                try pool.spawn(handle_packets_internal, .{ self, client, context });
            }
        }

        pub fn accept(self: *const Self, address: *net.Address) !posix.socket_t {
            var address_length: posix.socklen_t = @sizeOf(net.Address);

            return try posix.accept(self.socket, &address.any, &address_length, posix.SOCK.NONBLOCK);
        }

        pub fn close(self: *const Self) void {
            posix.close(self.socket);
        }

        fn handle_packets_internal(self: *const Self, client: posix.socket_t, context: Context) void {
            handle_packets(self, client, context) catch |err| {
                self.logger.info("Packets handler failed: {}", .{ err });
            };
        }

        fn handle_packets(self: *const Self, client: posix.socket_t, context: Context) !void {
            defer posix.close(client);

            const stream = net.Stream{ .handle = client };
            const logger = self.logger;
            const client_address = try utils.get_client_address(client);
            const handshake_data = options.handshake(stream);

            stream.writeAll(handshake_data) catch |err| {
                logger.info("Error while sending handshake: {}", .{ err });
                return;
            };

            while (true) {
                var buffer: [256]u8 = undefined;

                // TODO: Do we (or when we'd) need message boundary?
                // 1. Read header type 0xC1...C4
                // 2. Read size (next 1 or 2 bytes)
                // 3. Read *size* more bytes
                const read = stream.read(&buffer) catch |err| {
                    logger.info("Client disconnected {} ({})", .{ client_address, err });
                    break;
                };

                if (read == 0 or read > buffer.len) {
                    continue;
                }

                const bytes = buffer[0..read];
                const packet = try packets.parse(bytes);

                logger.info(
                    "Packet received: 0x{x:0>2} 0x{x:0>2} 0x{x:0>2} 0x{x:0>2}",
                    .{ @intFromEnum(packet.type), packet.size, packet.code, packet.sub_code },
                );

                const response = packets.handle(
                    InPackets,
                    context.server,
                    packet,
                ) catch |err| {
                    logger.info(
                        "Couldn't handle packet({any}): 0x{x:0>2} 0x{x:0>2} 0x{x:0>2} 0x{x:0>2}",
                        .{ err, @intFromEnum(packet.type), packet.size, packet.code, packet.sub_code },
                    );
                    continue;
                };

                switch (response.code) {
                    .Fail => logger.info("Package handling failed!", .{}),
                    .Success => logger.info("Package handling succeeded.", .{}),
                }

                if (response.packet) |response_packet| {
                    try stream.writeAll(response_packet);
                    logger.info("Packet sent: {x:0>2}", .{ response_packet });
                }
            }
        }
    };
}
