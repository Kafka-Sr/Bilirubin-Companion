# Bilirubin Companion

A frontend-only Flutter implementation of an offline-first bilirubin companion app for a handheld screening device. The app is intentionally UI-first, uses in-memory mock state, and is organized into the six dashboard sections: Hero, Device, Image, Bhutani, Metadata, and Recommendation.

## Features

- Frosted-glass design system across dashboard cards, sheets, dialogs, and settings.
- Exact light/dark palette foundation:
  - Light: Background `#FCFDFD`, Surface `#F4F4F4`, Primary `#2D517E`, Secondary `#5179A3`, Text `#1E1E1E`
  - Dark: Background `#111313`, Surface `#1E1E1E`, Primary `#97C8E9`, Secondary `#C3E0F1`, Text `#F4F4F4`
- Two pages only:
  - Dashboard
  - Settings
- Riverpod-based frontend state.
- Mock device connect/disconnect and scan simulation.
- Mock export preview as JSON.
- Bhutani nomogram with pure Dart risk-zone classification logic.

## Run the project

```bash
flutter pub get
flutter run
```

## Mock device behavior

- The **Device** strip sits between **Hero** and **Image**.
- Tap the Device strip to toggle mocked connect/disconnect with a slight delay.
- The device text updates between connected and disconnected states.
- The settings icon on the Device strip navigates to the Settings page.

## Simulate scans

- Open the **Hero** overflow menu (three dots).
- Choose **Simulate Scan**.
- A mock bilirubin measurement is generated in memory for the selected baby.
- The **Image**, **Bhutani**, and **Recommendation** sections update immediately.

## Export preview / mock export

- Tap the export icon in the **Hero** section.
- The app generates a JSON preview in memory with snake_case keys.
- The preview is shown in a dialog.
- No file is written to disk.
- Export includes baby metadata, measurement metadata, and `has_image` only.

## Optional sample images

This implementation does not require bundled sample images. The **Image** section uses polished placeholder scan cards. If you want to wire real placeholder assets later, place them under `assets/images/` and register them in `pubspec.yaml`.

## Frontend-only scope note

This app does **not** implement:

- Drift / SQLite
- Secure storage
- Encryption
- Native integrations
- BLE / Wi-Fi device SDKs
- File persistence
- Camera access
- Authentication
- Network calls

Everything is mocked in memory to keep the project production-lean and easy to extend.

## Dashboard structure

The dashboard is organized into these exact six sections:

1. Hero
2. Device
3. Image
4. Bhutani
5. Metadata
6. Recommendation

## Design system note

The UI uses a frosted-glass design system with soft translucency, gentle highlights, rounded corners, subtle blur treatment, and calm clinical contrast in both light and dark themes.
