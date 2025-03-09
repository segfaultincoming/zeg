const ConnectionId = @import("tcp_server").ConnectionId;
const Game = @import("game");
const state = @import("state.zig");

pub const GameServer = struct {
    connection_id: ConnectionId,

    pub fn init(connection_id: ConnectionId) GameServer {
        return GameServer{
            .connection_id = connection_id,
        };
    }

    pub fn connect(self: *const GameServer, account: Game.Account) !void {
        return state.connect(self.connection_id, account);
    }

    pub fn disconnect(self: *const GameServer) void {
        self.remove(self.connection_id);
    }

    pub fn remove(connection_id: ConnectionId) void {
        state.disconnect(connection_id);
    }

    pub fn get_account(self: *const GameServer) !Game.Account {
        return state.get_account(self.connection_id);
    }
};
