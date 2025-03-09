const std = @import("std");
const Game = @import("game");

// Player ID -> Account
var connected_players = std.AutoHashMap(u64, Game.Account).init(std.heap.page_allocator);
// Account Name -> Player ID
var connected_accounts = std.StringHashMap(u64).init(std.heap.page_allocator);

pub const GameServer = struct {
    player_id: u64,

    pub fn init(player_id: u64) GameServer {
        return GameServer{ .player_id = player_id };
    }

    pub fn connect(self: *const GameServer, account: Game.Account) !void {
        if (connected_accounts.contains(account.name)) {
            return error.AlreadyConnected;
        }

        connected_players.put(self.player_id, account) catch |err| {
            std.debug.print("[GameServer] Failed to connect 0x{x} due to {}.\n", .{self.player_id, err});
            return error.FailedToConnect;
        };

        connected_accounts.put(account.name, self.player_id) catch |err| {
            std.debug.print("[GameServer] Failed to connect 0x{x} due to {}.\n", .{self.player_id, err});
            return error.FailedToConnect;
        };

        std.debug.print("[GameServer] Player count: {d}\n", .{connected_players.count()});
    }

    pub fn disconnect(self: *const GameServer) void {
        remove(self.player_id);
    }

    pub fn remove(player_id: u64) void {
        if (connected_players.get(player_id)) |account| {
            _ = connected_accounts.remove(account.name);
            _ = connected_players.remove(player_id);
        }
    }

    pub fn get_account(self: *const GameServer) !Game.Account {
        if (connected_players.get(self.player_id)) |account| {
            return account;
        }

        return error.NotFound;
    }
};
