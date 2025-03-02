const item = @import("item.zig");
const Pet = item.Pet;
const Weapon = item.wearable(u8);
const Armor = item.wearable(u4);
const Cosmetic = item.wearable(u3);

pub const Appearance = struct {
   class: u4,
   pose: u4,

   // Cosmetics
   cosmetics: u4,
   pet: Pet,

   // Items
   left_hand: Weapon,
   right_hand: Weapon,
   helm: Armor,
   armor: Armor,
   pants: Armor,
   gloves: Armor,
   boots: Armor,
   wings: Cosmetic,
   full_ancient_set: bool,
};