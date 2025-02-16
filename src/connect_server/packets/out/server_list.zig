const std = @import("std");
const utils = @import("packets").utils;
const PacketType = @import("packets").types.PacketType;
const Servers = @import("../../servers/types.zig").Servers;

pub const ServerList = struct {
    header: PacketType = PacketType.C2,
    code: u8 = 0xF4,
    sub_code: u8 = 0x06,
    server_list: Servers,

    pub fn init(server_list: Servers) ServerList {
        return ServerList{
            .header = PacketType.C2,
            .code = 0xF4,
            .sub_code = 0x06,
            .server_list = server_list,
        };
    }

    pub fn to_client(self: *const ServerList) ![]const u8 {
        const server_count = try server_count_to_client(self);
        const servers = try server_list_to_client(self);

        return try utils.create_packet(
            self.header,
            self.code,
            self.sub_code,
            &.{ server_count, servers },
        );
    }

    fn server_count_to_client(self: *const ServerList) ![]const u8 {
        return try utils.split_into_bytes(u16, @intCast(self.server_list.len), .big);
    }

    fn server_list_to_client(self: *const ServerList) ![]const u8 {
        var servers = try utils.block_alloc(u8, self.server_list.len * 4);

        var server_offset: usize = 0;
        for (self.server_list.items(.id), self.server_list.items(.load)) |id, load| {
            std.mem.copyForwards(
                u8,
                servers[server_offset .. server_offset + 2],
                try utils.split_into_bytes(u16, id, .little),
            );
            server_offset += 2;

            std.mem.copyForwards(
                u8,
                servers[server_offset .. server_offset + 2],
                try utils.split_into_bytes(u16, load, .little),
            );
            server_offset += 2;
        }

        return servers;
    }
};
