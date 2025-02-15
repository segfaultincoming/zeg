const std = @import("std");
const ServerList = @import("types.zig").ServerList;

pub fn get_server_list() !ServerList {
    const gpa = std.heap.page_allocator;
    var serverList = ServerList{};

    // TODO: This should not be hardcoded obviously
    {
        const endpoint = "192.168.0.182:55901";

        try serverList.append(gpa, .{
            .id = 0,
            .connections = 0,
            .maxConnections = 200,
            .load = 0,
            .loadIndex = 0,
            .endpoint = endpoint,
        });

        try serverList.append(gpa, .{
            .id = 1,
            .connections = 0,
            .maxConnections = 200,
            .load = 0,
            .loadIndex = 0,
            .endpoint = endpoint,
        });

        try serverList.append(gpa, .{
            .id = 2,
            .connections = 0,
            .maxConnections = 200,
            .load = 0,
            .loadIndex = 0,
            .endpoint = endpoint,
        });
    }

    return serverList;
}
