const LoginRequest = @import("login_request.zig").LoginRequest;
const CharacterListRequest = @import("character_list_request.zig").CharacterListRequest;
const FocusCharacter = @import("focus_character.zig").FocusCharacter;
const SelectCharacter = @import("select_character.zig").SelectCharacter;

pub const Packets = union {
    login: LoginRequest,
    character_request: CharacterListRequest,
    focus_character: FocusCharacter,
    select_character: SelectCharacter,
};