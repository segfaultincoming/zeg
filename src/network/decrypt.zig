const std = @import("std");
const Keys = @import("keys.zig").Keys;
const cipher = @import("cipher_calc.zig");

pub fn decrypt(packet: []const u8, decrypt_keys: Keys) []const u32 {
    const block_sizes = cipher.get_blocks(cipher.CipherVersion.New);

    _ = block_sizes;

    const first_byte = @as(u32, packet[0]) + decrypt_keys.key[0];
    const result = [8] u32{ first_byte, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08 };

    return &result;
}

test "packet is decrypted" {
    const packet = [_] u8{ 1, 2, 3 };
    const result = decrypt(&packet, @import("keys.zig").server_keys);

    try std.testing.expectEqual(@as(u32, 0x00007b39), result[0]);
}
