const std = @import("std");
const decrypt = @import("network").xor.decrypt_xor3;
const types = @import("packets").types;
const gs = @import("../../main.zig");

const PacketType = types.PacketType;
const PacketResponse = types.PacketResponse;

pub const LoginRequest = struct {
    pub const header: PacketType = PacketType.C1;
    pub const code: u8 = 0xf3;
    pub const sub_code: u8 = 0x0d;

    pub fn process(game_server: *const gs.GameServer, payload: []const u8) !PacketResponse {
        const response = gs.OutPackets.LoginResponse.init(login_result);
        const response_data = try response.to_client();

        _ = game_server;

        return PacketResponse{
            .code = .Success,
            .packet = response_data,
        };
    }
};
