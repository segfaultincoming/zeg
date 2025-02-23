const std = @import("std");
const packets = @import("packets").types;
const cs = @import("../../main.zig");

const PacketType = packets.PacketType;
const PacketResponse = packets.PacketResponse;

pub const ServerListRequest = struct {
    pub const header: PacketType = PacketType.C1;
    pub const size: u8 = 0x04;
    pub const code: u8 = 0xf4;
    pub const sub_code: u8 = 0x06;

    pub fn process(connect_server: *const cs.ConnectServer, payload: []const u8) !PacketResponse {
        if (payload.len > 0) {
            return PacketResponse{
                .code = .Fail,
                .packet = payload,
            };
        }

        const servers = cs.OutPackets.ServerList.init(connect_server.server_list);
        const packet = try servers.to_client();

        return PacketResponse{
            .code = .Success,
            .packet = packet,
        };
    }
};
