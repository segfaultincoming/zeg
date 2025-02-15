const ServersRequest = @import("./servers_request.zig").ServersRequest;

pub const Packets = union {
    servers_request: ServersRequest,
};
