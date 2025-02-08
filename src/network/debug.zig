const std = @import("std");

pub fn print_blocks(blocks: [][]u8) void {
    for (blocks) |block| {
        print_bytes(block);
    }
}

pub fn print_bytes(bytes: []const u8) void {
    std.debug.print("\n", .{});
    std.debug.print("---------------------------------------------------\n", .{});
    std.debug.print("PRINT BYTES ({d})\n", .{bytes.len});
    std.debug.print("---------------------------------------------------\n", .{});
    var chunk_idx: u32 = 0;
    for (bytes, 1..) |byte, i| {
        std.debug.print("0x{x:0>2} ", .{byte});
        if (i % 8 == 0) {
            std.debug.print(" [{d}]\n", .{chunk_idx});
            chunk_idx += 1;
        }
    }
    if (bytes.len % 8 != 0) {
        std.debug.print("[{d}]\n", .{chunk_idx});
    }
    std.debug.print("--------------------------------------------------\n", .{});
}
