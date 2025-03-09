const std = @import("std");
const Address = std.net.Address;
const allocator = std.heap.page_allocator;

pub fn get_player_id(address: Address) !u64 {
    var buffer: [64]u8 = undefined;
    const buf = buffer[0..];
    const result = try std.fmt.bufPrint(buf, "{}", .{address});

    return std.hash.Fnv1a_64.hash(result);
}

test "get_player_id (ipv4)" {
    const ipv4_bytes = [4]u8{ 255, 255, 255, 255 };
    const ipv4 = Address{ .in = .init(ipv4_bytes, 55901) };
    const result = try get_player_id(ipv4);
    const expected: u64 = 1133453060309144041;

    try std.testing.expect(result == expected);
}

test "get_player_id (ipv6)" {
    const ipv6_bytes = [16]u8{
        0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff,
    };
    const ipv6 = Address{
        .in6 = .init(ipv6_bytes, 55901, 0, 0),
    };
    const result = try get_player_id(ipv6);
    const expected: u64 = 10727886957869853623;

    try std.testing.expect(result == expected);
}
