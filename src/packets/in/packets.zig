const ServersRequest = @import("./servers_request.zig").ServersRequest;

pub const Packets = union {
    servers_request: ServersRequest,
};

pub const Packet = struct {
    process: fn (payload: []const u8) PacketResponse,
};

pub const PacketResponse = enum {
    Fail,
    Success,
};