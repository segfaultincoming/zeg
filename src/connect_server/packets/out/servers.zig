const std = @import("std");
const utils = @import("packets").utils;
const PacketType = @import("packets").types.PacketType;
const ServerList = @import("../../servers/types.zig").ServerList;

pub const Servers = struct {
    header: PacketType = PacketType.C2,
    size: u16 = undefined,
    code: u8 = 0xF4,
    sub_code: u8 = 0x06,
    server_list: ServerList,

    pub fn init(server_list: ServerList) Servers {
        return Servers{
            .header = PacketType.C2,
            .size = 0x16,
            .code = 0xF4,
            .sub_code = 0x06,
            .server_list = server_list,
        };
    }

    // NOTE: WIP, this is as beautiful as a road killed animal.
    pub fn to_client(self: *const Servers) ![]const u8 {
        const server_len: u16 = @intCast(self.server_list.len);
        const server_count = try utils.split_into_bytes(u16, server_len, .big);

        var servers = try utils.block_alloc(u8, server_len * 4);
        var server_idx: usize = 0;

        for (
            self.server_list.items(.id),
            self.server_list.items(.load),
        ) |id, load| {
            const id_u8 = try utils.split_into_bytes(u16, id, .little);
            const load_u8 = try utils.split_into_bytes(u16, load, .little);
            servers[server_idx * 4 + 0] = id_u8[0];
            servers[server_idx * 4 + 1] = id_u8[1];
            servers[server_idx * 4 + 2] = load_u8[0];
            servers[server_idx * 4 + 3] = load_u8[1];
            server_idx += 1;
        }

        var response = std.ArrayList(u8).init(std.heap.page_allocator);
        // (header + u16 size + code + sub_code + u16 servers_count) + severs.len
        const servers_len: u16 = @intCast(servers.len);
        const packet_size: u16 = 7 + servers_len;
        const size = try utils.split_into_bytes(u16, packet_size, .big);

        try response.append(@intFromEnum(self.header));
        try response.appendSlice(size);
        try response.append(self.code);
        try response.append(self.sub_code);
        try response.appendSlice(server_count);
        try response.appendSlice(servers);

        return try response.toOwnedSlice();
    }
};
