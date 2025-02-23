const LoginRequest = @import("login_request.zig").LoginRequest;

pub const Packets = union {
    login: LoginRequest,
};