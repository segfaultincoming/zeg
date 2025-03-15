const Game = @import("../main.zig");

pub fn get_characters_mock() []const Game.Character {
    const character_1 = Game.Character{
        // General
        .name = "RaFa",
        .class = .Todo,
        .level = 300,

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
            .id = 0x00,
            .group = 0x00,
            .level = 0x0D,
        },
        .right_hand = .{
            .ancient = false,
            .excellent = true,
            .id = 0x05,
            .group = 0x00,
            .level = 0x0D,
        },
        .helm = .{
            .ancient = false,
            .excellent = true,
            .id = 0x06,
            .group = 0x07,
            .level = 0x0D,
        },
        .armor = .{
            .ancient = false,
            .excellent = true,
            .id = 0x06,
            .group = 0x08,
            .level = 0x0D,
        },
        .pants = .{
            .ancient = false,
            .excellent = true,
            .id = 0x06,
            .group = 0x09,
            .level = 0x0D,
        },
        .gloves = .{
            .ancient = false,
            .excellent = true,
            .id = 0x06,
            .group = 0x0A,
            .level = 0x0D,
        },
        .boots = .{
            .ancient = false,
            .excellent = true,
            .id = 0x06,
            .group = 0x0B,
            .level = 0x0D,
        },
        // .pet = null,
        .pet = .{
            .type = .Fenrir,
            .flag = .None,
        },
        .wings = .{
            .type = .WingsOfDragon,
            .small = false,
        },
    };

    return &[_]Game.Character {character_1};
}