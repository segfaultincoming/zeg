const std = @import("std");
const Hello = @import("hello.zig").Hello;

pub const Packets = union{
    hello: Hello,

    pub fn to_client(self: *const Packets) []const u8 {
        const bytes: [*]const u8 = @ptrCast(self);
        return bytes[0..@sizeOf(Packets)];
    }
};

test Packets {
    const packet = Packets{.hello = .init()};
    const expected = [4]u8{0xc1, 0x04, 0x00, 0x01};
    try std.testing.expect(std.mem.eql(u8, &expected, packet.to_client()));
}