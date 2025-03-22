const std = @import("std");
const types = @import("packets").types;
const gs = @import("../../main.zig");

const PacketType = types.PacketType;
const PacketResponse = types.PacketResponse;
const CharacterListResponse = gs.OutPackets.CharacterListResponse;

pub const CharacterListRequest = struct {
    pub const header: PacketType = PacketType.C1;
    pub const code: u8 = 0xf3;
    pub const sub_code: u8 = 0x00;

    pub fn process(game_server: *const gs.GameServer, _: []const u8) !PacketResponse {
        const account = game_server.get_account() catch |err| {
            std.debug.print("[GameServer] Failed to retrieve account: {}\n", .{err});
            return PacketResponse{
                .code = .Fail,
                .packet = null,
            };
        };
        const response = CharacterListResponse.init(account);
        const response_data = try response.to_client();

        return PacketResponse{
            .code = .Success,
            .packet = response_data,
        };
    }
};
