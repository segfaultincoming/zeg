pub fn wearable(comptime TIdx: type) type {
    return struct {
        idx: TIdx,
        group: u3,
        level: u3,
        excellent: bool,
        ancient: bool,
        // TODO: Add JoL and Excellent options
    };
}

pub const Pet = struct {
    idx: u6,
    flag: Pets
};

pub const Pets = enum {
    None,
    DarkHorse,
    BlueFenrir,
    BlackFenrir,
    GoldFenrir,
};
