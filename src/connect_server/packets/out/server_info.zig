const std = @import("std");
const utils = @import("packets").utils;
const PacketType = @import("packets").types.PacketType;
const ServerItem = @import("../../servers/types.zig").ServerItem;

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
        // TODO
        return try utils.create_packet(
            self.header,
            self.code,
            self.sub_code,
            &.{ },
        );
    }
};
