const std = @import("std");
const utils = @import("packets").utils;
const PacketType = @import("packets").types.PacketType;

pub const LoginShow = struct {
    header: PacketType = PacketType.C1,
    code: u8 = 0xf1,
    sub_code: u8 = 0x00,

    pub fn init() LoginShow {
        return LoginShow{};
    }

    pub fn to_client(self: *const LoginShow) ![]const u8 {
        const playerId = &[2]u8{ 0x02, 0x00 };
        const success = &[1]u8{0x01};
        const version = &[5]u8{ 0x31, 0x30, 0x34, 0x30, 0x34 };

        return utils.create_packet(
            self.header,
            self.code,
            self.sub_code,
            &.{success, playerId, version},
        );
    }
};
