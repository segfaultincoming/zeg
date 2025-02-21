const std = @import("std");
const packets = @import("packets");
const posix = std.posix;
const net = std.net;

pub const Context = struct {
    server: *const anyopaque,
    create_context: *const fn (self: *const Context, client_addr: net.Address) *const anyopaque,
    handle_packets: *const fn (server: *const Server, client: posix.socket_t, context: *const anyopaque) void,
};

pub const Server = struct {
    name: []const u8,
    socket: posix.socket_t,

    pub fn create(name: []const u8, address: []const u8, port: u16) !Server {
        const server_addr = try net.Address.parseIp(address, port);
        const socket = try posix.socket(
            server_addr.any.family,
            posix.SOCK.STREAM,
            posix.IPPROTO.TCP,
        );

        std.debug.print("[{s}] Server listening on {}\n", .{ name, server_addr });

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

        return Server{
            .socket = socket,
            .name = name,
        };
    }

    pub fn listen(self: *const Server, context: Context, pool: *std.Thread.Pool) !void {
        while (true) {
            var client_addr: std.net.Address = undefined;
            const client = self.accept(&client_addr) catch |err| {
                std.debug.print("[{s}] error accept: {}\n", .{ self.name, err });
                return;
            };
            std.debug.print("[{s}] {} connected\n", .{ self.name, client_addr });
            try pool.spawn(handle_packets, .{ self, client, client_addr, context });
        }
    }

    pub fn accept(self: *const Server, address: *net.Address) !posix.socket_t {
        var address_length: posix.socklen_t = @sizeOf(net.Address);

        return try posix.accept(
            self.socket,
            &address.any,
            &address_length,
            posix.SOCK.NONBLOCK,
        );
    }

    pub fn close(self: *const Server) void {
        posix.close(self.socket);
    }

    fn handle_packets(
        server: *const Server,
        client: posix.socket_t,
        client_addr: net.Address,
        context: Context,
    ) void {
        context.handle_packets(
            server,
            client,
            context.create_context(&context, client_addr),
        );
    }
};
