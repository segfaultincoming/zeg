const std = @import("std");
const utils = @import("packets").utils;
const PacketType = @import("packets").types.PacketType;

pub const CharacterFocused = struct {
    header: PacketType = PacketType.C1,
    code: u8 = 0xf3,
    sub_code: u8 = 0x15,

    character_name: []const u8,

    pub fn init(character_name: []const u8) CharacterFocused {
        return CharacterFocused{
            .character_name = character_name,
        };
    }

    pub fn to_client(self: *const CharacterFocused) ![]const u8 {
        return utils.create_packet(
            self.header,
            self.code,
            self.sub_code,
            // For *some* reason the required packet length is 15, not 14 - pad it with 0x00.
            &.{self.character_name, &.{0x00}},
        );
    }
};
