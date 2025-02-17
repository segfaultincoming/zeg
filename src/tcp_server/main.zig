const std = @import("std");
const posix = std.posix;
const net = std.net;

pub const Server = struct {
    socket: posix.socket_t,
    name: []const u8,

    pub fn create(name: []const u8, address: []const u8, port: u16) !Server {
        const server_addr = try net.Address.parseIp(address, port);
        const socket = try posix.socket(
            server_addr.any.family,
            posix.SOCK.STREAM,
            posix.IPPROTO.TCP,
        );

        std.debug.print("[{s}] Server listening on {}\n", .{name, server_addr});

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

        return Server{ .socket = socket, .name = name };
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
};
