const std = @import("std");
const types = @import("packets").types;
const ConnectServer = @import("../../connect_server.zig").ConnectServer;
const OutPackets = @import("../out/main.zig");

const PacketType = types.PacketType;
const PacketResponse = types.PacketResponse;

pub const ServerList = struct {
    pub const header: PacketType = PacketType.C1;
    pub const size: u8 = 0x04;
    pub const code: u8 = 0xf4;
    pub const sub_code: u8 = 0x06;

    pub fn process(server: *const anyopaque, payload: []const u8) !PacketResponse {
        if (payload.len > 0) {
            return PacketResponse{
                .code = .Fail,
                .packet = payload,
            };
        }

        const connect_server: *const ConnectServer = @ptrCast(@alignCast(server));
        const servers = OutPackets.ServerList.init(connect_server.server_list);
        const packet = try servers.to_client();

        return PacketResponse{
            .code = .Success,
            .packet = packet,
        };
    }
};
