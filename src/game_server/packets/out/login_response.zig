const std = @import("std");
const packets = @import("packets");

const utils = packets.utils;
const PacketType = packets.types.PacketType;
const Enums = @import("../../main.zig").Enums;

pub const LoginResponse = struct {
    header: PacketType = PacketType.C1,
    code: u8 = 0xF1,
    sub_code: u8 = 0x01,
    login_result: Enums.LoginResult,

    pub fn init(login_result: Enums.LoginResult) LoginResponse {
        return LoginResponse{
            .header = PacketType.C1,
            .code = 0xF1,
            .sub_code = 0x01,
            .login_result = login_result,
        };
    }

    /// TODO:
    /// 1. This is repeated in all out packets. Maybe extract it to helper?
    /// 2. Maybe stick to unions, so that the function can be defined on the union level?
    /// ```zig
    /// fn to_client(self: *const anyopaque, data: []const []const u8) {
    ///    // ...
    /// }
    /// ```
    pub fn to_client(self: *const LoginResponse) ![]const u8 {
        return try utils.create_packet(
            self.header,
            self.code,
            self.sub_code,
            &.{&[1]u8{@intFromEnum(self.login_result)}},
        );
    }
};
