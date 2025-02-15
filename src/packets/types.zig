pub const PacketType = enum(u8) {
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

pub const Packet = struct {
    type: PacketType,
    size: u32,
    code: u8,
    sub_code: u8,
    payload: []const u8,
};

pub const ResponseCode = enum {
    Fail,
    Success,
};

pub const PacketResponse = struct {
    code: ResponseCode,
    packet: []const u8,
};

// NOTE: This might not be needed
// pub const Packet = struct {
//     process: fn (payload: []const u8) PacketResponse,
// };
