///! TODO: Maybe extract this to a separate config module,
/// so that everything is configured in one place?
const std = @import("std");

pub const ServerItem = struct {
    id: u16,
    connections: u8,
    maxConnections: u8,
    load: u16,
    loadIndex: u8,
    ip_address: [:0]const u8,
    port: u16,
};

pub const Servers = std.MultiArrayList(ServerItem);

pub fn get_server_list() !Servers {
    const gpa = std.heap.page_allocator;
    var serverList = Servers{};

    // TODO: This should not be hardcoded obviously
    {
        const ip_address = "192.168.0.182";
        const port: u16 = 55901;

        try serverList.append(gpa, .{
            .id = 0,
            .connections = 0,
            .maxConnections = 200,
            .load = 0,
            .loadIndex = 0,
            .ip_address = ip_address,
            .port = port,
        });

        try serverList.append(gpa, .{
            .id = 1,
            .connections = 0,
            .maxConnections = 200,
            .load = 0,
            .loadIndex = 0,
            .ip_address = ip_address,
            .port = port,
        });

        try serverList.append(gpa, .{
            .id = 2,
            .connections = 0,
            .maxConnections = 200,
            .load = 0,
            .loadIndex = 0,
            .ip_address = ip_address,
            .port = port,
        });
    }

    return serverList;
}
