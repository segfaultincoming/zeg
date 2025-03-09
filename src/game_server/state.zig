const std = @import("std");
const Game = @import("game");
const ConnectionId = @import("tcp_server").connection.ConnectionId;

const allocator = std.heap.page_allocator;

// Connection ID -> Account
var connected_players = std.AutoHashMap(ConnectionId, Game.Account).init(allocator);
// Account Name -> Connection ID
var connected_accounts = std.StringHashMap(ConnectionId).init(allocator);

pub const AccountError = error{
    AlreadyConnected,
    FailedToConnect,
    NotFound,
};

pub fn connect(connection_id: ConnectionId, account: Game.Account) AccountError!void {
    if (connected_accounts.contains(account.name)) {
        return error.AlreadyConnected;
    }

    connected_players.put(connection_id, account) catch |err| {
        std.debug.print("[GameServer] Failed to connect 0x{x} due to {}.\n", .{ connection_id, err });
        return error.FailedToConnect;
    };

    connected_accounts.put(account.name, connection_id) catch |err| {
        std.debug.print("[GameServer] Failed to connect 0x{x} due to {}.\n", .{ connection_id, err });
        return error.FailedToConnect;
    };

    print_player_count();
}

pub fn disconnect(connection_id: ConnectionId) void {
    if (connected_players.get(connection_id)) |account| {
        _ = connected_accounts.remove(account.name);
        _ = connected_players.remove(connection_id);
    }
    print_player_count();
}

pub fn print_player_count() void {
    std.debug.print("[GameServer] Player count: {d}\n", .{get_player_count()});
}

pub fn get_player_count() u32 {
    return @as(u32, connected_players.count());
}

pub fn get_account(connection_id: ConnectionId) AccountError!Game.Account {
    if (connected_players.get(connection_id)) |account| {
        return account;
    }

    return error.NotFound;
}