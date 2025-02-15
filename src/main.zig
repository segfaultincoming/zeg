const connect_server = @import("connect_server/main.zig");

pub fn main() !void {
    try connect_server.start();
}
