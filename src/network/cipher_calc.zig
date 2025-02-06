const bits_per_byte: u32 = 8;
const bits_per_value: u32 = bits_per_byte * 2 + 2;

pub const CipherBlocks = struct {
    encrypted: u8,
    decrypted: u8,
    encryption: u8,
};

pub const CipherVersion = enum(u32) {
    New,
    Old
};

pub fn get_blocks(version: CipherVersion) CipherBlocks {
    return switch (version) {
        CipherVersion.New => CipherBlocks
        {
            .decrypted = 8,
            .encrypted = 11,
            .encryption = 4
        },
        else => CipherBlocks
        {
            .decrypted = 32,
            .encrypted = 38,
            .encryption = 16
        }
    };
} 

pub fn get_byte_offset(idx: u32) u32 {
    return get_bit_index(idx) / bits_per_byte;
}

pub fn get_bit_offset(idx: u32) u32 {
    return get_bit_index(idx) % bits_per_byte;
}

pub fn get_first_bit_mask(idx: u32) u32 {
    return 0xFF >> get_bit_offset(idx);
}

pub fn get_remainder_bit_mask(idx: u32) u32 {
    return (0xFF << 6 - get_bit_offset(idx) & 0xFF) - (0xFF << 8 - get_bit_offset(idx) & 0xFF);
}

pub fn get_bit_index(idx: u32) u32 {
    return idx * bits_per_value;
}

pub fn get_content_size(packet: []const u8, counter: u32, decrypted: bool) u32 {
    var content_size = get_packet_size(&packet) - get_content_size(&packet);

    if (counter > 0 and decrypted) {
        content_size += 1;
    }

    return content_size;
}

pub fn get_packet_header_size(packet: []const u8) u32 {
    return switch (packet[0]) {
        0xC1, 0xC3 => 2,
        0xC2, 0xC4 => 3,
        else => 0,
    };
}

pub fn get_packet_size(packet: []const u8) u32 {
    return switch (packet[0]) {
        0xC1, 0xC3 => packet[1],
        0xC2, 0xC4 => packet[1] << 8 | packet[2],
        else => 0,
    };
}
