const std = @import("std");
const network = @import("network");

const types = @import("types.zig");
const Packet = @import("in/packets.zig").Packet;
const Packets = @import("in/packets.zig").Packets;
const PacketResponse = @import("in/packets.zig").PacketResponse;

const cipher = network.cipher;
const keys = network.keys;
const PacketType = types.PacketType;
const PacketHeader = types.PacketHeader;
const PacketCode = types.PacketCode;

pub fn parse(bytes: []const u8) !Packets {
    const header = try header_parser(bytes);
    const codes = code_parser(header);
    return try handle_packet(Packets, codes);
}

pub fn header_parser(bytes: []const u8) !PacketHeader {
    const packetType: PacketType = @enumFromInt(bytes[0]);
    const packet: []const u8 = switch (packetType) {
        PacketType.C3, PacketType.C4 => try cipher.decrypt(bytes, keys.server_keys),
        else => bytes,
    };
    const size = network.get_packet_size(packet);
    const payload = packet[network.get_header_size(packet)..];

    return PacketHeader{
        .type = packetType,
        .size = size,
        .payload = payload,
    };
}

pub fn code_parser(packet: PacketHeader) PacketCode {
    const code = packet.payload[0];
    const sub_code = packet.payload[1];

    return PacketCode{
        .type = packet.type,
        .size = packet.size,
        .code = code,
        .sub_code = sub_code,
        .payload = packet.payload[2..],
    };
}

pub fn handle_packet(comptime T: type, packet: PacketCode) !PacketResponse {
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
            const parsed_packet = Packet{
                .process = field.type.process,
            };
            return parsed_packet.process(packet.payload);
        }
    }

    return error.PacketNotFound;
}

test handle_packet {
    const payload = [2]u8{ 0x01, 0x02 };
    const packet = PacketCode{
        .type = PacketType.C1,
        .size = 0x06,
        .code = 0xf4,
        .sub_code = 0x06,
        .payload = payload[0..],
    };
    const packet_response = try handle_packet(Packets, packet);

    try std.testing.expect(packet_response == PacketResponse.Success);
}

test header_parser {
    const packet = [2]u8{ @intFromEnum(PacketType.C1), 0x04 };
    const parsedPacket = try header_parser(packet[0..]);
    try std.testing.expect(parsedPacket.type == PacketType.C1);
}

test code_parser {
    const payload = [2]u8{ 0xF1, 0xFF };
    const packet_code = code_parser(.{
        .payload = payload[0..],
        .size = 0x04,
        .type = PacketType.C1,
    });
    try std.testing.expect(packet_code.code == 0xF1);
    try std.testing.expect(packet_code.sub_code == 0xFF);
}
