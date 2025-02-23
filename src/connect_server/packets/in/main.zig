const ServerListRequest = @import("./server_list.zig").ServerListRequest;
const ServerInfoRequest = @import("./server_info.zig").ServerInfoRequest;

pub const Packets = union {
    server_list: ServerListRequest,
    server_info: ServerInfoRequest,
};
