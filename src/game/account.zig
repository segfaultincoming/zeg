const mocks = @import("mocks/character.zig");
const Character = @import("character.zig").Character;

pub const Account = struct {
    name: []u8,
    characters: []Character,

    pub fn init(name: []u8) Account {
        return Account{
            .name = name,
            .characters = @constCast(mocks.get_characters_mock()),
        };
    }
};
