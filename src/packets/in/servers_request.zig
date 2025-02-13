const std = @import("std");
const PacketType= @import("../types.zig").PacketType;
const PacketResponse = @import("packets.zig").PacketResponse;

pub const ServersRequest = struct {
    pub const header: PacketType = PacketType.C1;
    pub const size: u8 = 0x04;
    pub const code: u8 = 0xf4;
    pub const sub_code: u8 = 0x06;

    pub fn process(payload: []const u8) PacketResponse {
        // TODO: Obviously for testing purposes
        if (payload[0] == 0x69) {
            return PacketResponse.Fail;
        }

        return PacketResponse.Success;
    }
};
