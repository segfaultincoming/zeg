const LoginRequest = @import("login_request.zig").LoginRequest;
const CharacterListRequest = @import("character_list_request.zig").CharacterListRequest;
const FocusCharacter = @import("focus_character.zig").FocusCharacter;

pub const Packets = union {
    login: LoginRequest,
    character_request: CharacterListRequest,
    focus_character: FocusCharacter,
};