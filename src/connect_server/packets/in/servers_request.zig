const std = @import("std");
const types = @import("../../../packets/types.zig");

const PacketType= types.PacketType;
const PacketResponse = types.PacketResponse;

pub const ServersRequest = struct {
    pub const header: PacketType = PacketType.C1;
    pub const size: u8 = 0x04;
    pub const code: u8 = 0xf4;
    pub const sub_code: u8 = 0x06;

    pub fn process(payload: []const u8) PacketResponse {
        if (payload.len > 0) {
            return PacketResponse.Fail;
        }

        return PacketResponse.Success;
    }
};