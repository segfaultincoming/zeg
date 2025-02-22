const ServerList = @import("./server_list.zig").ServerListSend;
const ServerInfo = @import("./server_info.zig").ServerInfoSend;

pub const Packets = union {
    server_list: ServerList,
    server_info: ServerInfo,
};
