const std = @import("std");
const types = @import("types.zig");

const PacketResponse = types.PacketResponse;
const PacketType = types.PacketType;
const Packet = types.Packet;

pub fn handle_packet(
    comptime T: type,
    context: *const anyopaque,
    packet: Packet,
) !PacketResponse {
    const packets = @typeInfo(T).@"union";

    inline for (packets.fields) |field| {
        var header: PacketType = undefined;
        var code: u8 = undefined;
        var sub_code: u8 = undefined;

        if (@hasDecl(field.type, "header")) {
            header = field.type.header;
        }

        if (@hasDecl(field.type, "code")) {
            code = field.type.code;
        }

        if (@hasDecl(field.type, "sub_code")) {
            sub_code = field.type.sub_code;
        }

        if (header == packet.type and code == packet.code and sub_code == packet.sub_code) {
            if (!@hasDecl(field.type, "process")) {
                return error.PacketProcessorNotFound;
            }

            return field.type.process(@ptrCast(@alignCast(context)), packet.payload);
        }
    }

    return error.PacketNotFound;
}

test handle_packet {
    const TestPacket = struct {
        pub const header = PacketType.C1;
        pub const code = 0xf4;
        pub const sub_code = 0x06;

        pub fn process(_: []u8) PacketResponse {
            return PacketResponse.Success;
        }
    };
    const TestPackets = union {
        test_packet: TestPacket,
    };

    const payload = [2]u8{ 0x01, 0x02 };
    const packet = Packet{
        .type = PacketType.C1,
        .size = 0x06,
        .code = 0xf4,
        .sub_code = 0x06,
        .payload = payload[0..],
    };

    const response = try handle_packet(TestPackets, packet);

    try std.testing.expect(response == PacketResponse.Success);
}
