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
        const account = self.account;
        const characters = account.characters;
        const allocator = std.heap.page_allocator;
        var characters_data = try allocator.alloc(u8, characters.len * 34);

        for (characters, 0..) |character, idx| {
            const offset = idx * 34;
            const character_data = characters_data[offset..offset + 34];
            const slot = character_data[0..1];
            const name = character_data[1..11];
            const uknown = character_data[11..12];
            const level = character_data[12..14];
            const status = character_data[14..15];
            const appearance = character_data[15..33];
            const guild_position = character_data[33..34];

            const character_status = @intFromEnum(character.status) | (@as(u8, @intFromBool(character.item_block)) << 4);
            const level_bytes = try utils.split_into_bytes(u16, character.level, .little);

            var name_buffer: [10]u8 = [_]u8{0} ** 10;
            std.mem.copyForwards(u8, name_buffer[0..character.name.len], character.name);

            slot.* = .{character.slot};
            name.* = name_buffer;
            uknown.* = .{0x00};
            level.* = level_bytes[0..2].*;
            status.* = .{character_status};
            appearance.* = try character.get_appearance();
            guild_position.* = .{@intFromEnum(character.guild_role)};
        }

        return utils.create_packet(
            self.header,
            self.code,
            self.sub_code,
            &.{
                &.{
                    0x00,
                    account.move_count,
                    @intCast(characters.len),
                    @intFromBool(account.vault_extended),
                },
                characters_data
            },
        );
    }
};

test CharacterListResponse {
    const account = Game.Account.init(@constCast("rafa"));
    const packet = CharacterListResponse.init(account);
    const result = try packet.to_client();

    try std.testing.expect(std.mem.eql(u8, result, &[_]u8{
        0xc1, 0x2a, 0xf3, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00,
        0x52, 0x61, 0x46, 0x61, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x2c, 0x01, 0x00, 0x30, 0x00, 0x05, 0x66,
        0x66, 0x6b, 0xdb, 0x6d, 0xb0, 0x03, 0xfe, 0x00, 0x04,
        0x00, 0x00, 0x00, 0x00, 0x00, 0xff,
    }));
}
