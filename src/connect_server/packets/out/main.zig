const std = @import("std");
const posix = std.posix;
const logger = @import("../../logger.zig");

pub const Hello = @import("hello.zig").Hello;
pub const Servers = @import("servers.zig").Servers;

pub fn write(client: posix.socket_t, bytes: []const u8) !void {
    // TODO: Should I try to invoke to_client() here?
    // const bytes = packet.to_client();

    logger.log_bytes(bytes, logger.LogType.SEND);

    var pos: usize = 0;
    while (pos < bytes.len) {
        const written = try posix.write(client, bytes[pos..]);
        if (written == 0) {
            return error.Closed;
        }
        pos += written;
    }
}

//     pub fn to_client(self: *const Packets) []const u8 {
//         const bytes: [*]const u8 = @ptrCast(self);
//         return bytes[0..@sizeOf(Packets)];
//     }

// test Packets {
//     const packet = Packets{ .hello = .init() };
//     const expected = [4]u8{ 0xc1, 0x04, 0x00, 0x01 };
//     try std.testing.expect(std.mem.eql(u8, &expected, packet.to_client()));
// }
