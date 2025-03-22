
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

    pub fn process(game_server: *const gs.GameServer, payload: []const u8) !PacketResponse {
        const username = payload[0..10];

        _ = username;
        _ = game_server;

        return PacketResponse{
            .code = .Success,
            .packet = null,
        };
    }
};
