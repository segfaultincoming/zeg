pub const Wearable = struct {
    idx: u8,
    group: u8,
    level: u4,
    excellent: bool,
    ancient: bool,
    // TODO: Add JoL and Excellent options
};

pub const Pet = struct {
    type: PetType,
    flag: PetFlag,
};

pub const PetType = enum {
    GuardianAngel,
    Imp,
    Unicorn,
    Dinorant,
    Fenrir,
    None,
    PetPanda,
    PetUnicorn,
    Skeleton,
    Rudolph,
    SpiritOfGuardian,
    Demon,
};

pub const PetFlag = enum {
    None,
    Dinorant,
    DarkHorse,
    BlueFenrir,
    BlackFenrir,
    GoldFenrir,
};

pub const Wings = struct {
    type: WingsType,
    small: bool,
};

pub const WingsType = enum {
    WingsOfElf,
    WingsOfHeaven,
    WingsOfSatan,
    WingsOfMistery,
    WingsOfSpirit,
    WingsOfSoul,
    WingsOfDragon,
    WingsOfDarkness,
    CapeOfLord,
    WingsOfDespair,
    CapeOfFighter,
    WingOfStorm,
    WingOfEternal,
    WingOfIllusion,
    WingOfRuin,
    CapeOfEmperor,
    WingOfDimension,
    CapeOfOverrule,
    None,
};
