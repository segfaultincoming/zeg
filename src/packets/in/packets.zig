const ServersRequest = @import("./servers_request.zig").ServersRequest;
pub const Packet = union{
    servers_request: ServersRequest,

    pub fn from_client(self: *const Packet) []const u8 {
        // TODO
        _ = self;
        return []const u8{};
    }
};