const std = @import("std");

pub const Hello = extern struct {
    header: u8 = 0xC1,
    size: u8,
    code: u8,
    sub_code: u8,

    pub fn init() Hello {
        return Hello{
            .header = 0xC1,
            .size = 0x04,
            .code = 0x00,
            .sub_code = 0x01,
        };
    }
};