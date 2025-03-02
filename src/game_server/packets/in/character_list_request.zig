const std = @import("std");
const decrypt = @import("network").xor.decrypt_xor3;
const types = @import("packets").types;
const gs = @import("../../main.zig");

const PacketType = types.PacketType;
const PacketResponse = types.PacketResponse;

pub const CharacterListRequest = struct {
    pub const header: PacketType = PacketType.C1;
    pub const code: u8 = 0xf3;
    pub const sub_code: u8 = 0x0d;

    pub fn process(game_server: *const gs.GameServer, payload: []const u8) !PacketResponse {
        _ = payload;
        _ = game_server;

        const response = gs.OutPackets.CharacterListResponse.init();
        const response_data = try response.to_client();

        return PacketResponse{
            .code = .Success,
            .packet = response_data,
        };
    }
};
