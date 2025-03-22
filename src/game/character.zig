const std = @import("std");
const Appearance = @import("appearance.zig").Appearance;
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
    Member = 0,
    BattleMaster = 32,
    Guildmaster = 128,
    None = 255,
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
    level: u16,

    // Stance
    pose: Pose,
    slot: u8,

    // Status
    item_block: bool,
    status: Status,
    guild_role: GuildRole,

    // Items
    left_hand: ?Weapon,
    right_hand: ?Weapon,
    helm: ?Armor,
    armor: ?Armor,
    pants: ?Armor,
    gloves: ?Armor,
    boots: ?Armor,
    wings: ?Wings,
    pet: ?Pet,

    pub fn get_appearance(self: *const Character) ![18]u8 {
        const appearance = Appearance{ .character = self.* };
        return try appearance.to_client();
    }
};
