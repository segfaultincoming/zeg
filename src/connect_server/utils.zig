const std = @import("std");
const posix = std.posix;
const net = std.net;

pub const Server = struct {
    socket: posix.socket_t,

    pub fn create(address: []const u8, port: u16) !Server {
        const server_addr = try net.Address.parseIp(address, port);
        const socket = try posix.socket(
            server_addr.any.family,
            posix.SOCK.STREAM,
            posix.IPPROTO.TCP,
        );

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

        return Server{ .socket = socket };
    }

    pub fn accept(self: *const Server, address: *net.Address, flags: u32) !posix.socket_t {
        var address_length: posix.socklen_t = @sizeOf(net.Address);

        return try posix.accept(
            self.socket,
            &address.any,
            &address_length,
            flags,
        );
    }
};
