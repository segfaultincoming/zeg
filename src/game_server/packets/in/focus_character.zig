const std = @import("std");
const types = @import("packets").types;
const Game = @import("game");
const gs = @import("../../main.zig");

const PacketType = types.PacketType;
const PacketResponse = types.PacketResponse;

pub const FocusCharacter = struct {
    pub const header: PacketType = PacketType.C1;
    pub const code: u8 = 0xf3;
    pub const sub_code: u8 = 0x15;

    pub fn process(_: *const gs.GameServer, payload: []const u8) !PacketResponse {
        const character_name = payload[0..10];
        const response = gs.OutPackets.CharacterFocused.init(character_name);
        const response_data = try response.to_client();

        return PacketResponse{
            .code = .Success,
            .packet = response_data,
        };
    }
};
