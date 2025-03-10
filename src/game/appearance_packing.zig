/// Dear Reader,
/// 
/// Apologies in advance if reviewing this file gives your eyes a hard time. I've done my utmost to encapsulate
/// WebZen's bit packing logic here, sparing us the pain of revisiting it in the future.
/// Remember to rest your eyes and recharge—some eye drops and a good break work wonders.
/// 
/// Treat yourself to a well-earned beverage, you’ve definitely earned it!
/// 
/// Best regards,
/// segfaultincoming

const Character = @import("character.zig").Character;
const flags = @import("appearance_flags.zig");

pub fn pack_item_ids_lower(character: Character) [5]u8 {
    const pet = flags.get_pet_flag(character);
    const wings = flags.get_wings_flag(character);

    const left_hand_id = if (character.left_hand == null) 0 else character.left_hand.?.id;
    const right_hand_id = if (character.right_hand == null) 0 else character.right_hand.?.id;
    const helm_id = if (character.helm == null) 0 else character.helm.?.id;
    const armor_id = if (character.armor == null) 0 else character.armor.?.id;
    const pants_id = if (character.pants == null) 0 else character.pants.?.id;
    const gloves_id = if (character.gloves == null) 0 else character.gloves.?.id;
    const boots_id = if (character.boots == null) 0 else character.boots.?.id;

    return .{
        left_hand_id,
        right_hand_id,
        helm_id << 4 | (armor_id & 0x0F),
        pants_id << 4 | (gloves_id & 0x0F),
        boots_id << 4 | wings[0] | pet,
    };
}

pub fn pack_item_ids_middle(character: Character) u8 {
    const wings = flags.get_wings_flag(character);
    const helm_id = if (character.helm == null) 0 else character.helm.?.id;
    const armor_id = if (character.armor == null) 0 else character.armor.?.id;
    const pants_id = if (character.pants == null) 0 else character.pants.?.id;
    const gloves_id = if (character.gloves == null) 0 else character.gloves.?.id;
    const boots_id = if (character.boots == null) 0 else character.boots.?.id;

    return (helm_id >> 4 << 7) | (armor_id >> 4 << 6) | (pants_id >> 4 << 5)
        | (gloves_id >> 4 << 4) | (boots_id >> 4 << 3) | wings[1];
}

pub fn pack_item_ids_higher(character: Character) [3]u8 {
    const right_hand_group = if (character.right_hand == null) 0b111 else character.right_hand.?.group;
    const helm_id = if (character.helm == null) 0b1111 else character.helm.?.id;
    const armor_id = if (character.armor == null) 0b1111 else character.armor.?.id;
    const pants_id = if (character.pants == null) 0b1111 else character.pants.?.id;
    const gloves_id = if (character.gloves == null) 0b1111 else character.gloves.?.id;
    const boots_id = if (character.boots == null) 0b1111 else character.boots.?.id;

    return .{
        right_hand_group & 0b111 << 5 | 0 << 4 | helm_id >> 5,
        armor_id >> 5 << 4 | pants_id >> 5,
        gloves_id >> 5 << 4 | boots_id >> 5,
    };
}

pub fn pack_item_exc(character: Character) u8 {
    const helm_exc = if (character.helm == null) false else character.helm.?.excellent;
    const armor_exc = if (character.armor == null) false else character.armor.?.excellent;
    const pants_exc = if (character.pants == null) false else character.pants.?.excellent;
    const gloves_exc = if (character.gloves == null) false else character.gloves.?.excellent;
    const boots_exc = if (character.boots == null) false else character.boots.?.excellent;
    const left_hand_exc = if (character.left_hand == null) false else character.left_hand.?.excellent;
    const right_hand_exc = if (character.right_hand == null) false else character.right_hand.?.excellent;
    const dinorant_flag = if (character.pet == null) false else character.pet.?.type == .Dinorant;

    return @as(u8, @intFromBool(helm_exc)) << 7
        | @as(u8, @intFromBool(armor_exc)) << 6
        | @as(u8, @intFromBool(pants_exc)) << 5
        | @as(u8, @intFromBool(gloves_exc)) << 4
        | @as(u8, @intFromBool(boots_exc)) << 3
        | @as(u8, @intFromBool(left_hand_exc)) << 2
        | @as(u8, @intFromBool(right_hand_exc)) << 1
        | @as(u8, @intFromBool(dinorant_flag));
}

pub fn pack_item_ancient(character: Character) u8 {
    const helm_ancient = if (character.helm == null) false else character.helm.?.ancient;
    const armor_ancient = if (character.armor == null) false else character.armor.?.ancient;
    const pants_ancient = if (character.pants == null) false else character.pants.?.ancient;
    const gloves_ancient = if (character.gloves == null) false else character.gloves.?.ancient;
    const boots_ancient = if (character.boots == null) false else character.boots.?.ancient;
    const left_ancient = if (character.left_hand == null) false else character.left_hand.?.ancient;
    const right_ancient = if (character.right_hand == null) false else character.right_hand.?.ancient;

    const ancient_flags: u8 = @as(u8, @intFromBool(helm_ancient)) << 7
        | @as(u8, @intFromBool(armor_ancient)) << 6
        | @as(u8, @intFromBool(pants_ancient)) << 5
        | @as(u8, @intFromBool(gloves_ancient)) << 4
        | @as(u8, @intFromBool(boots_ancient)) << 3
        | @as(u8, @intFromBool(left_ancient)) << 2
        | @as(u8, @intFromBool(right_ancient)) << 1;
    const is_full_ancient = ancient_flags ^ 0xFF == 1;

    return ancient_flags | @intFromBool(is_full_ancient);
}

pub fn pack_levels(character: Character) [3]u8 {
    const left_level = if (character.left_hand == null) 0 else (character.left_hand.?.level - 1) / 2;
    const right_level = if (character.right_hand == null) 0 else (character.right_hand.?.level - 1) / 2;
    const helm_level = if (character.helm == null) 0 else (character.helm.?.level - 1) / 2;
    const armor_level = if (character.armor == null) 0 else (character.armor.?.level - 1) / 2;
    const pants_level = if (character.pants == null) 0 else (character.pants.?.level - 1) / 2;
    const gloves_level = if (character.gloves == null) 0 else (character.gloves.?.level - 1) / 2;
    const boots_level = if (character.boots == null) 0 else (character.boots.?.level - 1) / 2;

    const levels: [8]u3 = .{
        @intCast(left_level),
        @intCast(right_level),
        @intCast(helm_level),
        @intCast(armor_level),
        @intCast(pants_level),
        @intCast(gloves_level),
        @intCast(boots_level),
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

pub fn pack_left_hand(character: Character) u8 {
    const left_hand_group = if (character.left_hand == null) 0b111 else character.left_hand.?.group;
    const is_fenrir = if (character.pet == null) false else character.pet.?.type == .Fenrir;
    const is_normal_fenrir = if (character.pet == null) false else character.pet.?.flag == .None;
    const is_dark_horse = if (character.pet == null) false else character.pet.?.flag == .DarkHorse;

    return left_hand_group & 0b111 << 5
        | 0 << 4
        | 0 << 3
        | @as(u8, @intFromBool(is_fenrir and is_normal_fenrir)) << 2
        | 0 << 1
        | @as(u8, @intFromBool(is_dark_horse));
}

pub fn pack_wings_pet_flag(character: Character) [2]u8 {
    const extra_pet = flags.get_extra_pet_flag(character);
    const small_wings = flags.get_small_wings_flags(character);
    const is_blue_fenrir = if (character.pet == null) false else character.pet.?.flag == .BlueFenrir;
    const is_black_fenrir = if (character.pet == null) false else character.pet.?.flag == .BlackFenrir;
    const is_gold_fenrir = if (character.pet == null) false else character.pet.?.flag == .GoldFenrir;

    return .{
        extra_pet | @as(u8, @intFromBool(is_blue_fenrir)) << 1 | @as(u8, @intFromBool(is_black_fenrir)),
        small_wings[1] | @as(u8, @intFromBool(is_gold_fenrir)),
    };
}
