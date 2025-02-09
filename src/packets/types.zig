const Hello = @import("./out/hello.zig").Hello;

pub const PacketType = enum (u8){
    C1 = 0xC1,
    C2 = 0xC2,
    C3 = 0xC3,
    C4 = 0xC4,
};
