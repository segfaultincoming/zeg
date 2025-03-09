const cipher_calc = @import("cipher_calc.zig");

pub const cipher = @import("decrypt.zig");
pub const xor = @import("xor_decrypt.zig");
pub const keys = @import("keys.zig");
pub const get_header_size = cipher_calc.get_header_size;
pub const get_packet_size = cipher_calc.get_size;

test {
    @import("std").testing.refAllDecls(@This());
}