const std = @import("std");

pub const ServerItem = struct {
    id: u16,
    connections: u8,
    maxConnections: u8,
    load: u16,
    loadIndex: u8,
    endpoint: [:0]const u8,
};

pub const Servers = std.MultiArrayList(ServerItem);