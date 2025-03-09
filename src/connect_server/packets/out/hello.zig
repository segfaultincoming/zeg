const std = @import("std");
const PacketType = @import("packets").types.PacketType;

pub const Hello = struct {
    header: PacketType = PacketType.C1,
    size: u8 = 0x04,
    code: u8 = 0x00,
    sub_code: u8 = 0x01,

    pub fn init() Hello {
        return Hello{};
    }

    pub fn to_client(self: *const Hello) ![]const u8 {
        var bytes = std.ArrayList(u8).init(
            std.heap.page_allocator,
        );
        defer bytes.deinit();

        try bytes.append(@intFromEnum(self.header));
        try bytes.append(self.size);
        try bytes.append(self.code);
        try bytes.append(self.sub_code);

        return try bytes.toOwnedSlice();
    }
};
