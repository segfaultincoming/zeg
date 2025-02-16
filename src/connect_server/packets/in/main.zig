const ServerList = @import("./server_list.zig").ServerList;
const ServerInfo = @import("./server_info.zig").ServerInfo;

pub const Packets = union {
    server_list: ServerList,
    server_info: ServerInfo,
};
