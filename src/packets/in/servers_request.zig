const std = @import("std");
const PacketType= @import("../types.zig").PacketType;

pub const ServersRequest = packed struct {
    header: PacketType = PacketType.C1,
    size: u8 = 0x04,
    code: u8 = 0xf4,
    sub_code: u8 = 0x06,

    pub fn init() ServersRequest {
        return ServersRequest{};
    }

    pub fn response() void {
        std.debug.print("Sending response from ServersRequest.\n", .{});
    }
};
