const std = @import("std");
const Game = @import("game");
const utils = @import("packets").utils;
const PacketType = @import("packets").types.PacketType;

pub const CharacterListResponse = struct {
    header: PacketType = PacketType.C1,
    code: u8 = 0xf1,
    sub_code: u8 = 0x00,

    account: Game.Account,

    pub fn init(account: Game.Account) CharacterListResponse {
        return CharacterListResponse{
            .account = account,
        };
    }

    pub fn to_client(self: *const CharacterListResponse) ![]const u8 {
        return self.account.get_characters();
    }
};
