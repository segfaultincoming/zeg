const std = @import("std");
const decrypt = @import("network").xor.decrypt_xor3;
const types = @import("packets").types;
const gs = @import("../../main.zig");

const PacketType = types.PacketType;
const PacketResponse = types.PacketResponse;

pub const LoginRequest = struct {
    pub const header: PacketType = PacketType.C3;
    pub const code: u8 = 0xf1;
    pub const sub_code: u8 = 0x01;

    pub fn process(game_server: *const gs.GameServer, payload: []const u8) !PacketResponse {
        const username = try decrypt(payload[0..10]);
        const password = try decrypt(payload[10..20]);
        // const tick_count_dec = try decrypt(payload[20..24]);
        // const tick_count = std.mem.readInt(u32, tick_count_dec[0..4], .big);
        // const version = try decrypt(payload[24..29]);
        // const serial = try decrypt(payload[29..45]);

        var login_result: gs.Enums.LoginResult = .Okay;

        // NOTE: This is for testing purposes. rafa/123456
        const username_temp = [10]u8 { 0x72, 0x61, 0x66, 0x61, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 };
        const password_temp = [10]u8 { 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x0, 0x0, 0x0, 0x0 };
        const username_matched = std.mem.eql(u8, username, username_temp[0..]);
        const password_matched = std.mem.eql(u8, password, password_temp[0..]);

        if (!username_matched or !password_matched) {
            login_result = .AccountInvalid;
        }

        const response = gs.OutPackets.LoginResponse.init(login_result);
        const response_data = try response.to_client();

        _ = game_server;

        return PacketResponse{
            .code = .Success,
            .packet = response_data,
        };
    }
};
