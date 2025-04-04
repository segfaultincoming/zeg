const std = @import("std");
const network = @import("network");
const types = @import("types.zig");

const cipher = network.cipher;
const keys = network.keys;
const PacketType = types.PacketType;
const PacketHeader = types.PacketHeader;
const Packet = types.Packet;

pub fn parse(bytes: []const u8, decrypt_c1_c2: bool) !Packet {
    const header = try header_parser(bytes, decrypt_c1_c2);
    return packet_parser(header);
}

pub fn header_parser(bytes: []const u8, decrypt_c1_c2: bool) !PacketHeader {
    const packetType: PacketType = @enumFromInt(bytes[0]);
    const packet: []const u8 = try cipher.decrypt(bytes, keys.server_keys, decrypt_c1_c2);
    const size = network.get_packet_size(packet);
    const payload = packet[network.get_header_size(packet)..];

    return PacketHeader{
        .type = packetType,
        .size = size,
        .payload = payload,
    };
}

pub fn packet_parser(packet: PacketHeader) Packet {
    const code = packet.payload[0];
    const sub_code = switch (packet.payload.len) {
        1 => 0,
        else => packet.payload[1],
    };
    const payload: []const u8 = switch (packet.payload.len) {
        1 => &[_]u8{},
        else => packet.payload[2..],
    };

    return Packet{
        .type = packet.type,
        .size = packet.size,
        .code = code,
        .sub_code = sub_code,
        .payload = payload,
    };
}

test header_parser {
    const packet = [2]u8{ @intFromEnum(PacketType.C1), 0x04 };
    const parsedPacket = try header_parser(packet[0..], false);
    try std.testing.expect(parsedPacket.type == PacketType.C1);
}

test packet_parser {
    const payload = [2]u8{ 0xF1, 0xFF };
    const packet_code = packet_parser(.{
        .payload = payload[0..],
        .size = 0x04,
        .type = PacketType.C1,
    });
    try std.testing.expect(packet_code.code == 0xF1);
    try std.testing.expect(packet_code.sub_code == 0xFF);
}
