const decrypt = @import("network/decrypt.zig");
const connect_server = @import("connect_server/server.zig");

pub fn main() !void {
    try connect_server.start();
}
