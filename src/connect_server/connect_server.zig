const std = @import("std");
const gpa = std.heap.page_allocator;
const server_types = @import("servers/types.zig");
const ServerList = server_types.ServerList;

pub fn get_server_list() !ServerList {
    var serverList = ServerList{};

    // TODO: This should not be hardcoded obviously
    {
        try serverList.append(gpa, .{
            .id = 0,
            .connections = 0,
            .maxConnections = 200,
            .load = 0,
            .loadIndex = 0,
            .endpoint = "192.168.0.182:55901",
        });
        try serverList.append(gpa, .{
            .id = 1,
            .connections = 0,
            .maxConnections = 200,
            .load = 0,
            .loadIndex = 0,
            .endpoint = "192.168.0.182:55901",
        });
        try serverList.append(gpa, .{
            .id = 2,
            .connections = 0,
            .maxConnections = 200,
            .load = 0,
            .loadIndex = 0,
            .endpoint = "192.168.0.182:55901",
        });
    }

    return serverList;
}

pub const ConnectServer = struct {
    server_list: ServerList,
    pub fn init() !ConnectServer {
        return ConnectServer{
            .server_list = try get_server_list(),
        };
    }
};
