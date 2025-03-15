const std = @import("std");
const Game = @import("game");
const utils = @import("packets").utils;
const PacketType = @import("packets").types.PacketType;

pub const CharacterListResponse = struct {
    header: PacketType = PacketType.C1,
    code: u8 = 0xf3,
    sub_code: u8 = 0x00,

    account: Game.Account,

    pub fn init(account: Game.Account) CharacterListResponse {
        return CharacterListResponse{
            .account = account,
        };
    }

    pub fn to_client(self: *const CharacterListResponse) ![]const u8 {
        const characters = self.account.characters;
        const allocator = std.heap.page_allocator;
        var characters_data = try allocator.alloc([34]u8, characters.len);

        // | Index   | Length | Data Type         | Value | Description       |
        // | ------- | ------ | ----------------- | ----- | ----------------- |
        // | 0       | 1      | Byte              |       | SlotIndex         |
        // | 1       | 10     | String            |       | Name              |
        // | 12      | 2      | ShortLittleEndian |       | Level             |

        // | 14      | 4 bit  | CharacterStatus   |       | Status            |
        // | 14 << 4 | 1 bit  | Boolean           |       | IsItemBlockActive |
        // | 15      | 18     | Binary            |       | Appearance        |
        // | 33      | 1      | GuildMemberRole   |       | GuildPosition     |

        for (characters, 0..) |character, idx| {
            const slot = characters_data[idx][0..1];
            const name = characters_data[idx][1..11];
            const uknown = characters_data[idx][11..12];
            const level = characters_data[idx][12..14];
            const status = characters_data[idx][14..15];
            const appearance = characters_data[idx][15..33];
            const guild_position = characters_data[idx][33..34];

            const level_bytes = try utils.split_into_bytes(u16, character.level, .little);

            slot.* = .{character.slot};
            name.* = .{0xFF} ** 10;
            uknown.* = .{0x00};
            level.* = level_bytes[0..2].*;
            status.* = .{0x77};
            appearance.* = try character.get_appearance();
            guild_position.* = .{@intFromEnum(character.guild_role)};
        }

        return utils.create_packet(
            self.header,
            self.code,
            self.sub_code,
            &.{
                &.{0x00, 0x00, @intCast(characters.len), 0x00},
                &characters_data[0],
            },
        );
    }
};

test CharacterListResponse {
    const account = Game.Account.init(@constCast("rafa"));
    const packet = CharacterListResponse.init(account);

    std.debug.print("{x:0>2}", .{try packet.to_client()});
}
