const std = @import("std");

pub const Hello = extern struct {
    header: u8 = 0xC1,
    size: u8 = 0x04,
    code: u8 = 0x00,
    sub_code: u8 = 0x01,

    pub fn init() Hello {
        return Hello{};
    }
};
