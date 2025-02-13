const Hello = @import("./out/hello.zig").Hello;

pub const PacketType = enum (u8){
    C1 = 0xC1,
    C2 = 0xC2,
    C3 = 0xC3,
    C4 = 0xC4,
};

pub const PacketHeader = struct {
    type: PacketType,
    size: u32,
    payload: []const u8,
};

pub const PacketCode = struct {
    type: PacketType,
    size: u32,
    code: u8,
    sub_code: u8,
    payload: []const u8,
};
