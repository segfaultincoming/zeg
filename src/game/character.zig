const std = @import("std");
const item = @import("item.zig");
const Pet = item.Pet;
const Weapon = item.Wearable;
const Armor = item.Wearable;
const Wings = item.Wings;

pub const Class = enum(u4) {
    DarkWizard = 0,
    Todo = 3,
};

pub const Pose = enum(u4) {
    Standing = 0,
    // Unused = 1,
    Sitting = 2,
    Leaning = 3,
    Hanging = 4,
};

pub const GuildRole = enum(u8) {
    None = 0,
    Member = 1,
};

pub const Status = enum(u8) {
    Normal = 0,
    Blocked = 1,
    GameMaster = 32,
};

pub const Character = struct {
    // General
    name: [:0]const u8,
    class: Class,
    level: [2]u8,

    // Stance
    pose: Pose,
    slot: u8,

    // Status
    status: Status,
    guild_role: GuildRole,

    // Items
    left_hand: Weapon,
    right_hand: Weapon,
    helm: Armor,
    armor: Armor,
    pants: Armor,
    gloves: Armor,
    boots: Armor,
    wings: Wings,
    pet: Pet,
};
