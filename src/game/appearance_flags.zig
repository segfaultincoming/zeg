const Character = @import("character.zig").Character;

pub fn get_pet_flag(character: Character) u2 {
    const pet_type = if (character.pet) |pet| pet.type else .None;
    return switch (pet_type) {
        .GuardianAngel => 0b00,
        .Imp => 0b01,
        .Unicorn => 0b10,
        else => 0b11,
    };
}

pub fn get_extra_pet_flag(character: Character) u8 {
    const pet_type = if (character.pet) |pet| pet.type else .None;
    return switch (pet_type) {
        .PetPanda => 0b1110_0000,
        .PetUnicorn => 0b1010_0000,
        .Skeleton => 0b0110_0000,
        .Rudolph => 0b1000_0000,
        .SpiritOfGuardian => 0b0100_0000,
        .Demon => 0b0010_0000,
        else => 0b0,
    };
}

pub fn get_small_wings_flags(character: Character) [2]u8 {
    if (character.wings == null) return .{0, 0};
    return switch (character.wings.?.type) {
        .CapeOfLord => .{0b1100, 0b0010_0000},
        .WingsOfMistery => .{0b1100, 0b0100_0000},
        .WingsOfElf => .{0b1100, 0b0110_0000},
        .WingsOfHeaven => .{0b1100, 0b1000_0000},
        .WingsOfSatan => .{0b1100, 0b1010_0000},
        .CloakOfWarrior => .{0b1100, 0b1100_0000},
        else => .{0b0, 0b0},
    };
}

pub fn get_wings_flag(character: Character) [2]u4 {
    if (character.wings == null) return .{0, 0};
    return switch (character.wings.?.type) {
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
        else => .{ 0b0, 0b0 },
    };
}
