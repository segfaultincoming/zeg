const mocks = @import("mocks/character.zig");
const Character = @import("character.zig").Character;
const pack = @import("appearance_packing.zig");
const std = @import("std");

pub fn copy(buf: []u8, value: u8) void {
    std.mem.copyForwards(u8, buf, &[1]u8{value});
}

pub const Appearance = struct {
    character: Character,

    pub fn to_client(self: *const Appearance) ![18] u8 {
        const character = self.character;
        var result = [_]u8{0} ** 18;

        const class_pose = @as(u8, @intFromEnum(character.class)) << 4 | @intFromEnum(character.pose);
        copy(result[0..1], class_pose);

        const item_ids_lower = pack.pack_item_ids_lower(character);
        copy(result[1..2], item_ids_lower[0]);
        copy(result[2..3], item_ids_lower[1]);
        copy(result[3..4], item_ids_lower[2]);
        copy(result[4..5], item_ids_lower[3]);
        copy(result[5..6], item_ids_lower[4]);

        const item_levels = pack.pack_levels(character);
        copy(result[6..7], item_levels[0]);
        copy(result[7..8], item_levels[1]);
        copy(result[8..9], item_levels[2]);

        const item_ids_middle: u8 = pack.pack_item_ids_middle(character);
        copy(result[9..10], item_ids_middle);

        const exc_and_dinorant_flags: u8 = pack.pack_item_exc(character);
        copy(result[10..11], exc_and_dinorant_flags);

        const ancient_flags: u8 = pack.pack_item_ancient(character);
        copy(result[11..12], ancient_flags);

        const left_hand_group: u8 = pack.pack_left_hand(character);
        copy(result[12..13], left_hand_group);

        const item_ids_higher = pack.pack_item_ids_higher(character);
        copy(result[13..14], item_ids_higher[0]);
        copy(result[14..15], item_ids_higher[1]);
        copy(result[15..16], item_ids_higher[2]);

        const wings_pet = pack.pack_wings_pet_flag(character);
        copy(result[16..17], wings_pet[0]);
        copy(result[16..17], wings_pet[1]);

        return result;
    }
};

test Appearance {
    const character = mocks.get_characters_mock()[0];
    const appearance = Appearance{ .character = character };
    const result = try appearance.to_client();
    const expected = [18]u8{
        0x30, 0x00, 0x05, 0x66, 0x66, 0x6b,
        0xdb, 0x6d, 0xb0, 0x03, 0xfe, 0x00,
        0x04, 0x00, 0x00, 0x00, 0x00, 0x00,
    };

    try std.testing.expect(std.mem.eql(u8, &result, &expected));
}
