# TODO

- Having the packets composed as `std.MultiArrayList` may be more efficient.

Conceptual code (not tested)

```zig
const PacketList = std.MultiArrayList(InPackets);
const packets = PacketList{};
// ... add packets
const packetType = 0xC1;
const code = 0xF1;
const packet = switch(packets.items(.header)) {
    packetType => |x| code: switch(x) {
        code => x,
        else => continue :code code,
    }
}
```
