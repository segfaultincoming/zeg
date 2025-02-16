const std = @import("std");
const utils = @import("packets").utils;
const PacketType = @import("packets").types.PacketType;
const ServerItem = @import("../../config.zig").ServerItem;

pub const ServerInfo = struct {
    header: PacketType = PacketType.C1,
    code: u8 = 0xF4,
    sub_code: u8 = 0x03,
    server_info: ServerItem,

    pub fn init(server_info: ServerItem) ServerInfo {
        return ServerInfo{
            .header = PacketType.C1,
            .code = 0xF4,
            .sub_code = 0x03,
            .server_info = server_info,
        };
    }

    pub fn to_client(self: *const ServerInfo) ![]const u8 {
        const ip_address = try ip_address_to_client(self.server_info.ip_address);
        const port = try utils.split_into_bytes(u16, self.server_info.port, .little);

        return try utils.create_packet(
            self.header,
            self.code,
            self.sub_code,
            &.{ ip_address, port },
        );
    }

    fn ip_address_to_client(server_ip: [:0]const u8) ![]const u8 {
        const ip_address = try utils.block_alloc_zeroes(u8, 16);
        std.mem.copyForwards(u8, ip_address[0..server_ip.len], server_ip);
        return ip_address;
    }
};
