const std = @import("std");
const types = @import("packets").types;
const ConnectServer = @import("../../connect_server.zig").ConnectServer;
const OutPackets = @import("../out/main.zig");

const PacketType = types.PacketType;
const PacketResponse = types.PacketResponse;

pub const ServerInfo = struct {
    pub const header: PacketType = PacketType.C1;
    pub const code: u8 = 0xf4;
    pub const sub_code: u8 = 0x03;

    pub fn process(server: *const anyopaque, payload: []const u8) !PacketResponse {
        if (payload.len != 2) {
            return PacketResponse{
                .code = .Fail,
                .packet = null,
            };
        }

        const connect_server: *const ConnectServer = @ptrCast(@alignCast(server));
        const server_id = std.mem.readInt(u16, payload[0..2], .little);
        const server_idx: ?usize = for (connect_server.server_list.items(.id), 0..) |id, idx| {
            if (id != server_id) continue;
            break idx;
        } else null;

        if (server_idx) |idx| {
            const server_info = OutPackets.ServerInfo.init(connect_server.server_list.get(idx));
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
