const Appearance = @import("appearance.zig").Appearance;

pub const Character = struct {
    slot: u8,
    name: [:0]u8,
    level: [2]u8,
    status: u8,
    appearance: Appearance,
    guid_role: u8,

    fn get_status(self: *const Character) u4 {
        return @intCast(self.status >> 4); // Last 4 bits
    }

    fn get_item_block_state(self: *const Character) u4 {
        return @intCast(self.status & 0x0F); // First 4 bits
    }
};
