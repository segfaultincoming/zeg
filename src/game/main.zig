pub const Account = @import("account.zig").Account;
pub const Character = @import("character.zig").Character;
pub const Appearance = @import("appearance.zig").Appearance;

test {
    @import("std").testing.refAllDecls(@This());
}
