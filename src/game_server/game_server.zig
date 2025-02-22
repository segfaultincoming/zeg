const std = @import("std");
const Context = @import("context.zig").Context;

pub const GameServer = struct {
    pub fn init() !GameServer {
        return GameServer{};
    }
};
