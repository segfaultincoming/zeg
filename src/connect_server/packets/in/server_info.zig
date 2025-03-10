const std = @import("std");
const packets = @import("packets").types;
const cs = @import("../../main.zig");

const PacketType = packets.PacketType;
const PacketResponse = packets.PacketResponse;

pub const ServerInfoRequest = struct {
    pub const header: PacketType = PacketType.C1;
    pub const code: u8 = 0xf4;
    pub const sub_code: u8 = 0x03;

    pub fn process(connect_server: *const cs.ConnectServer, payload: []const u8) !PacketResponse {
        if (payload.len != 2) {
            return PacketResponse{
                .code = .Fail,
                .packet = null,
            };
        }

        const server_list = connect_server.server_list;
        const server_id = std.mem.readInt(u16, payload[0..2], .little);
        const server_idx: ?usize = for (server_list.items(.id), 0..) |id, idx| {
            if (id != server_id) continue;
            break idx;
        } else null;

        if (server_idx) |idx| {
            const server_info = cs.OutPackets.ServerInfo.init(server_list.get(idx));
            const packet = try server_info.to_client();

            return PacketResponse{
                .code = .Success,
                .packet = packet,
            };
        }

        return PacketResponse{
            .code = .Fail,
            .packet = null,
        };
    }
};
