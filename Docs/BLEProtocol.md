# BLE Protocol

## Discovery and Connection

Android behavior:
1. Open Bluetooth adapter.
2. Start discovery with no service UUID filter.
3. Show discovered devices with `name` and `deviceId`.
4. Connect to selected device.
5. Wait about 3 seconds, then call `getBLEDeviceServices`.
6. For every service, call `getBLEDeviceCharacteristics`.
7. Enable notifications for every characteristic with `notify` or `indicate`.
8. Write helper writes the ASCII payload to every characteristic with `write`.
9. Read helper reads the active device's selected characteristic, but the UI does not expose it.

## UUIDs

No fixed ECU service UUID or characteristic UUID is hard-coded in the Surfie business code.

Generic UUIDs found in framework/container code:
- `00002902-0000-1000-8000-00805f9b34fb`: Client Characteristic Configuration descriptor.
- `00000000-0000-1000-8000-00805F9B34FB`: DCloud generic UUID helper.

ASSUMPTION: The real ECU service/characteristic UUIDs are device-specific and must be discovered on the live ECU, because Android subscribes dynamically to all notify/indicate characteristics.

## Packet Framing

Incoming packets are hex strings converted from BLE notification bytes.

Accepted forms:
- Full packet: hex length `64` or `62`, starts with `aa`.
- Fragment 1: hex length `42` or `40`, starts with `aa`; stored as pending data.
- Fragment 2: hex length `24` or `22`; appended only if pending data length is `40`.
- Trailing `0a` is stripped before parsing.

Packets not matching these rules are ignored/logged as text.

## Payload Map

All indexes below are byte indexes after converting hex to bytes.

| Field | Bytes | Formula |
| --- | --- | --- |
| throttle valve | `[4,5]` | big-endian integer |
| rpm | `[6,7]` | `256 * byte6 + byte7` |
| oil consumption 1/H | `[8,9]` | big-endian integer |
| oil consumption 100/KM | `[10,11,12]` | `255 * byte10 * 255 + 255 * byte11 + byte12` |
| Y | `[13]` | integer |
| engine temperature | `[14]` | integer |
| speed | `[16,17]` | big-endian integer |
| inlet temperature | `[18]` | integer |
| runtime seconds | `[19,20,21,22]` | big-endian integer |
| status bits | `[29]` | MSB-first bits |
| fault bits | `[29,28]` | MSB-first bits |

The iOS parser intentionally preserves the Android formula for oil consumption per 100 KM, including the `255` multipliers.

## Fault Labels

1. trigger signal
2. oxygen sensor
3. negative pressure signal
4. fuel injection output
5. oil pump output
6. ignition output
7. throttle valve
8. oil pump plug
9. production fault 1
10. production fault 2
11. production fault 3
12. production fault 4
13. production fault 5
14. production fault 6
15. production fault 7
16. production fault 8
