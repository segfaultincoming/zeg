const std = @import("std");
const posix = std.posix;
const net = std.net;
const allocator = std.heap.page_allocator;

const hello = @import("../packets/out/hello.zig").hello;

pub fn start() !void {
    const server_addr = try std.net.Address.parseIp("192.168.0.182", 44405);
    const socket = try posix.socket(
        server_addr.any.family, 
        posix.SOCK.STREAM, 
        posix.IPPROTO.TCP);
    defer posix.close(socket);

    std.debug.print("Server listening on {}\n", .{server_addr});

    try posix.setsockopt(socket, posix.SOL.SOCKET, posix.SO.REUSEADDR, &std.mem.toBytes(@as(c_int, 1)));
    try posix.bind(socket, &server_addr.any, server_addr.getOsSockLen());
    try posix.listen(socket, 128);

    while (true) {
        var client_addr: net.Address = undefined;
        var client_addr_len: posix.socklen_t = @sizeOf(net.Address);

        const client = posix.accept(
            socket, 
            &client_addr.any, 
            &client_addr_len, 
            posix.SOCK.NONBLOCK) 
            catch |err| {
                std.debug.print("error accept: {}\n", .{err});
                continue;
            };

        std.debug.print("{} connected\n", .{client_addr});
        try sendHello(client);

        var buffer: [128]u8 = undefined;
        const read = posix.read(client, &buffer) catch |err| {
            std.debug.print("Client disconnected {}\n{}\n", .{client_addr, err});
            continue;
        };

        if (read == 0) {
            continue;
        }

        const packet = buffer[0..read];
        log_bytes_recv(packet);
    }
}

fn sendHello(socket: posix.socket_t) !void {
    const hello_data = hello.init();
    try write(socket, &hello_data.to_client());
}

fn write(socket: posix.socket_t, buffer: []const u8) !void {
    var pos: usize = 0;

    log_bytes_write(buffer);

    while (pos < buffer.len) {
        const written = try posix.write(socket, buffer[pos..]);
        if (written == 0) {
            return error.Closed;
        }
        pos += written;
    }
}

fn log_bytes_recv(packet: []u8) void {
    std.debug.print("RECEIVED: ", .{});
    for (packet) |value| {
        std.debug.print("0x{x:0>2} ", .{value});
    }
    std.debug.print("\n", .{});
}

fn log_bytes_write(buffer: []const u8) void {
    std.debug.print("SENDING: ", .{});
    for (buffer) |value| {
        std.debug.print("0x{x:0>2} ", .{value});
    }
    std.debug.print("\n", .{});

}