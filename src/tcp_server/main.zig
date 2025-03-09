pub const server = @import("server.zig").server;
pub const player = @import("player.zig");

test {
    @import("std").testing.refAllDecls(@This());
}