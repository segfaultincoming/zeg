const std = @import("std");

pub const hello = struct {
    header: u8,
    size: u8,
    code: u8,
    sub_code: u8,

    pub fn init() hello {
        return hello{
            .header = 0xC1,
            .size = 0x04,
            .code = 0x00,
            .sub_code = 0x01,
        };
    }

    pub fn to_client(self: *const hello) [@sizeOf(hello)]u8 {
        const bytes: [*]const u8 = @ptrCast(self);
        const size = @sizeOf(hello);
        var result: [size]u8 = undefined;

        for (bytes[0..size], 0..) |value,i| {
            result[i] = value;
        }

        // Can I use this?
        // &std.mem.toBytes(timeout)

        return result;
    }
};
