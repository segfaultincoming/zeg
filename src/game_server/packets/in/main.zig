const LoginRequest = @import("login_request.zig").LoginRequest;
const CharacterListRequest = @import("character_list_request.zig").CharacterListRequest;

pub const Packets = union {
    login: LoginRequest,
    character_request: CharacterListRequest,
};