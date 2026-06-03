# SURFIE ECU iOS

Native SwiftUI iOS 17+ rewrite of the recovered `Surfie-ECU.apk` functionality.

## What Was Recovered

- Live BLE device discovery.
- BLE connection.
- Dynamic service/characteristic discovery.
- Notification subscription for every notify/indicate characteristic.
- Generic write/read helpers.
- ECU telemetry packet parser.
- Main telemetry UI.
- Device list panel.
- About/contact screen.

## Build

Requirements:
- macOS with Xcode 16+.
- iPhone/iPad running iOS 17+ for CoreBluetooth testing.

Open this folder in Xcode:

```bash
open Package.swift
```

Select the `SurfieECU` executable target and run on a physical iOS device. Bluetooth does not behave fully in the simulator.

## Build unsigned IPA for Sideloadly

If you do not have a Mac, upload this folder as a GitHub repository and run:

```text
Actions -> Build unsigned IPA -> Run workflow
```

Download the `SurfieECU-unsigned-ipa` artifact. Install `SurfieECU-unsigned.ipa` with Sideloadly; Sideloadly will sign it locally with your Apple ID before installing it on the iPhone.

Notes:
- The workflow intentionally builds with `CODE_SIGNING_ALLOWED=NO`.
- A free Apple ID in Sideloadly usually means the app must be refreshed periodically.
- Use a real iPhone, not the simulator, because BLE must be tested on real hardware.

## Real Device Testing Required

- Bluetooth permission prompts.
- Discovery of the real ECU peripheral.
- Dynamic service and characteristic enumeration.
- Notification subscription.
- Packet fragmentation handling.
- Telemetry value scaling.
- Writable characteristic behavior.

## Functions Not Recoverable From APK

- Login: only unused scaffold strings were found; no active page or API call.
- Firmware Update: no OTA screen, endpoint, binary source, or BLE command format.
- Ride Statistics: no history model or storage found.
- ECU Control: no active control UI or command catalog found.
- Fixed BLE UUIDs: Android discovers runtime services/characteristics dynamically.
- Business REST/MQTT/WebSocket endpoints: not present in active code.

Every unavailable feature is represented in code as explicit `unavailable`/documented behavior instead of silent fake logic.

## Reverse Engineering Artifacts

Main artifacts were written under `../reverse/`:

- `apktool/`
- `jadx/`
- `Surfie-ECU-dex2jar.jar`
- `app-service.pretty.js`
- `aapt-badging.txt`
- `aapt-permissions.txt`
- `aapt-list.txt`
