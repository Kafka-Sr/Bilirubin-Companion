# Bilirubin Companion Frontend PoC

This Flutter app is a **frontend-only proof of concept** that simulates a bilirubin monitoring experience.

## What is simulated
- In-memory babies, measurements, and device connectivity
- Simulated scan action (adds synthetic measurements instantly)
- Simulated export action (`Export simulated` snackbar)
- Device connect/disconnect strip and transport switching (Wi-Fi/BLE)
- Interactive settings controls (Wi-Fi/Bluetooth stubs, language, theme, app lock)

## What is intentionally NOT implemented
- No database (no Drift/SQLite)
- No encryption
- No real Wi-Fi/BLE communication
- No cloud sync

## Run
```bash
flutter pub get
flutter run
```

## Demo flow
1. Open dashboard and pick a baby from the selector.
2. Tap the device strip to toggle connect/disconnect.
3. Use overflow menu → **Simulate Scan** to append new measurement data.
4. Open Settings from strip icon or overflow menu and switch language/theme.
