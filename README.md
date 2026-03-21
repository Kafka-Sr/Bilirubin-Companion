# Biligun Companion Frontend

Offline-first Flutter frontend for a bilirubin handheld companion app. This implementation is UI-first only and uses in-memory mock repositories and services so backend, persistence, BLE, Wi-Fi, and device integrations can be wired later.

## Run

```bash
flutter pub get
flutter run
```

## Frontend-only scope

- No login or auth
- No network calls
- No real BLE or Wi-Fi integration
- No database or file persistence
- No encryption or secure storage
- No native hooks or code generation

## Dashboard structure

The dashboard is organized into these six sections, in order:

1. Hero
2. Device
3. Image
4. Bhutani
5. Metadata
6. Recommendation

## Mock interactions

### Connect or disconnect the device

- Tap the `Device` strip on the dashboard.
- The mock device toggles between connected and disconnected after a short delay.
- The strip updates to show either `Connected: <device_id> (<Wi-Fi/BLE>)` or `Not connected`.

### Simulate scans

- Open the overflow menu in `Hero`.
- Choose `Simulate Scan`.
- If the mock device is connected, a new bilirubin measurement is created in memory, the `Image` section updates, the `Bhutani` chart updates, and the `Recommendation` card recalculates.
- If the mock device is disconnected, the app shows a friendly failure snackbar.

### Mock export preview

- Tap the export icon in `Hero`.
- The app generates JSON in memory for the current baby and opens a preview sheet.
- The JSON includes baby data, measurement metadata, and `has_image` booleans only.
- Choosing `Simulate export` shows a success snackbar.

## Metadata and settings

- Tap the edit icon in `Metadata` to add or edit baby information.
- Validation trims the baby name, rejects control characters, validates weight, and prevents future birth dates.
- Open `Settings` from the `Device` section to configure mock Wi-Fi, Bluetooth, language, theme mode, and the app lock stub.

## Optional sample images

This implementation uses polished placeholder image cards by default. If you want to add real sample images later, place them in a folder such as:

```text
assets/sample_images/
```

Then register the asset paths in `pubspec.yaml` and map them into the mock measurement layer.

## Design system

- The UI uses a frosted-glass design system with soft translucent cards, subtle highlights, rounded corners, layered gradients, and gentle shadows.
- The Bhutani chart follows the same glass-inspired language instead of using a permanently dark panel.

## Exact theme palette

### Light mode

- Background: `#FCFDFD`
- Surface: `#F4F4F4`
- Primary: `#2D517E`
- Secondary: `#5179A3`
- Text: `#1E1E1E`

### Dark mode

- Background: `#111313`
- Surface: `#1E1E1E`
- Primary: `#97C8E9`
- Secondary: `#C3E0F1`
- Text: `#F4F4F4`

