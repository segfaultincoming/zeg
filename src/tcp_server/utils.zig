const std = @import("std");

pub fn get_client_address(client: std.posix.socket_t) !std.net.Address {
    var sockaddr: std.posix.sockaddr = undefined;
    var sockaddr_len: u32 = @sizeOf(std.posix.sockaddr);
    try std.posix.getpeername(client, &sockaddr, &sockaddr_len);

    return std.net.Address.initPosix(@alignCast(&sockaddr));
}
