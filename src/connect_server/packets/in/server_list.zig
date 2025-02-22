const std = @import("std");
const types = @import("packets").types;
const ServerList = @import("../out/main.zig").ServerList;
const ConnectServer = @import("../../connect_server.zig").ConnectServer;

const PacketType = types.PacketType;
const PacketResponse = types.PacketResponse;

pub const ServerListSend = struct {
    pub const header: PacketType = PacketType.C1;
    pub const size: u8 = 0x04;
    pub const code: u8 = 0xf4;
    pub const sub_code: u8 = 0x06;

    pub fn process(connect_server: *const ConnectServer, payload: []const u8) !PacketResponse {
        if (payload.len > 0) {
            return PacketResponse{
                .code = .Fail,
                .packet = payload,
            };
        }

        const servers = ServerList.init(connect_server.server_list);
        const packet = try servers.to_client();

        return PacketResponse{
            .code = .Success,
            .packet = packet,
        };
    }
};
