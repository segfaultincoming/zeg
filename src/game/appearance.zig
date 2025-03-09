const Character = @import("character.zig").Character;
const std = @import("std");
const allocator = std.heap.page_allocator;
const copyForwards = std.mem.copyForwards;

pub fn copy(buf: []u8, value: u8) void {
    std.mem.copyForwards(u8, buf, &[1]u8{value});
}

pub fn pack_pets(character: Character) [2]u2 {
    return switch (character.pet.type) {
        .GuardianAngel => .{0b00, 0b11},
        .Imp => .{0b01, 0b11},
        .Unicorn => .{0b10, 0b11},
        else => .{0b11, 0b11},
    };
}

pub fn pack_wings(character: Character) [2]u4 {
    return switch (character.wings.type) {
        .WingsOfElf => .{ 0b0100, 0b0001 },
        .WingsOfHeaven => .{ 0b0100, 0b0010 },
        .WingsOfSatan => .{ 0b0100, 0b0011 },
        .WingsOfMistery => .{ 0b0100, 0b0100 },
        .WingsOfSpirit => .{ 0b1000, 0b0001 },
        .WingsOfSoul => .{ 0b1000, 0b0010 },
        .WingsOfDragon => .{ 0b1000, 0b0011 },
        .WingsOfDarkness => .{ 0b1000, 0b0100 },
        .CapeOfLord => .{ 0b1000, 0b0101 },
        .WingsOfDespair => .{ 0b1000, 0b0110 },
        .CapeOfFighter => .{ 0b1000, 0b0111 },
        .WingOfStorm => .{ 0b1100, 0b0001 },
        .WingOfEternal => .{ 0b1100, 0b0010 },
        .WingOfIllusion => .{ 0b1100, 0b0011 },
        .WingOfRuin => .{ 0b1100, 0b0100 },
        .CapeOfEmperor => .{ 0b1100, 0b0101 },
        .WingOfDimension => .{ 0b1100, 0b0110 },
        .CapeOfOverrule => .{ 0b1100, 0b0111 },
        .None => .{ 0b0000, 0b0000 },
    };
}

pub fn pack_levels(character: Character) [3]u8 {
    const levels: [8]u3 = .{
        @intCast((character.left_hand.level - 1) / 2),
        @intCast((character.right_hand.level - 1) / 2),
        @intCast((character.helm.level - 1) / 2),
        @intCast((character.armor.level - 1) / 2),
        @intCast((character.pants.level - 1) / 2),
        @intCast((character.gloves.level - 1) / 2),
        @intCast((character.boots.level - 1) / 2),
        @intCast(0),
    };

    var bytes: u24 = 0;
    var offset: u5 = 21;

    for (levels) |level| {
        bytes = bytes | @as(u24, level) << offset;

        if (offset != 0) {
            offset = offset - 3;
        }
    }

    return .{
        @intCast((bytes & 0xFF0000) >> 16),
        @intCast((bytes & 0x00FF00) >> 8),
        @intCast(bytes & 0x0000FF),
    };
}

pub const Appearance = struct {
    character: Character,

    pub fn to_client(self: *const Appearance) ![]const u8 {
        const character = self.character;
        const result = try allocator.alloc(u8, 18);
        for (result) |*value| value.* = 0;

        const class_pose = @as(u8, @intFromEnum(character.class)) << 4 | @intFromEnum(character.pose);
        copy(result[0..1], class_pose);
        copy(result[1..2], character.left_hand.idx);
        copy(result[2..3], character.right_hand.idx);

        const helm_armor_idx = character.helm.idx << 4 | (character.armor.idx & 0x0F);
        copy(result[3..4], helm_armor_idx);

        const pants_gloves_idx = character.pants.idx << 4 | (character.gloves.idx & 0x0F);
        copy(result[4..5], pants_gloves_idx);

        const pet = pack_pets(character);
        const wings= pack_wings(character);

        const boots_wings_pets = character.boots.idx << 4 | wings[0] | pet[0];
        copy(result[5..6], boots_wings_pets);

        const item_levels = pack_levels(character);
        copy(result[6..7], item_levels[0]);
        copy(result[7..8], item_levels[1]);
        copy(result[8..9], item_levels[2]);

        const item_idxs: u8 = (character.helm.idx >> 4 << 7)
            | (character.armor.idx >> 4 << 6)
            | (character.pants.idx >> 4 << 5)
            | (character.gloves.idx >> 4 << 4)
            | (character.boots.idx >> 4 << 3)
            | wings[1];
        copy(result[9..10], item_idxs);

        std.debug.print("{b:0>8}\n", .{item_idxs});

        // std.debug.print("ORIG {b:0>8}\n", .{character.helm.idx << 4});
        // std.debug.print("ORIG {b:0>8}\n", .{character.armor.idx & 0x0f});

        std.debug.print("{x:0>2}", .{result});

        const fake_response = [2]u8{ 0xff, 0xf0 };
        return fake_response[0..];
    }
};

test Appearance {
    const character = Character{
        // General
        .name = "RaFa",
        .class = .Todo,
        .level = [2]u8{ 0x0, 0xFF },

        // Stance
        .slot = 0,
        .pose = .Standing,

        // Status
        .status = .GameMaster,
        .guild_role = .Member,

        // Items
        .left_hand = .{
            .ancient = false,
            .excellent = true,
            .idx = 0x00,
            .group = 0x00,
            .level = 0x0D,
        },
        .right_hand = .{
            .ancient = false,
            .excellent = true,
            .idx = 0x05,
            .group = 0x00,
            .level = 0x0D,
        },
        .helm = .{
            .ancient = false,
            .excellent = true,
            .idx = 0x06,
            .group = 0x07,
            .level = 0x0D,
        },
        .armor = .{
            .ancient = false,
            .excellent = true,
            .idx = 0x06,
            .group = 0x08,
            .level = 0x0D,
        },
        .pants = .{
            .ancient = false,
            .excellent = true,
            .idx = 0x06,
            .group = 0x09,
            .level = 0x0D,
        },
        .gloves = .{
            .ancient = false,
            .excellent = true,
            .idx = 0x06,
            .group = 0x0A,
            .level = 0x0D,
        },
        .boots = .{
            .ancient = false,
            .excellent = true,
            .idx = 0x06,
            .group = 0x0B,
            .level = 0x0D,
        },
        .pet = .{
            .type = .Fenrir,
            .flag = .GoldFenrir,
        },
        .wings = .{
            .type = .WingsOfDragon,
            .small = false,
        },
    };

    const appearance = Appearance{
        .character = character,
    };

    _ = try appearance.to_client();
}
