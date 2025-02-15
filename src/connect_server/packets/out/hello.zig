const std = @import("std");
const PacketType= @import("../../../packets/types.zig").PacketType;

pub const Hello = extern struct {
    header: PacketType = PacketType.C1,
    size: u8 = 0x04,
    code: u8 = 0x00,
    sub_code: u8 = 0x01,

    pub fn init() Hello {
        return Hello{};
    }
};

