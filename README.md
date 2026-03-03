# Bilirubin Companion

Offline-first Flutter app for bilirubin device companion workflow.

## Run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Sample image asset

Put sample images in:

- `assets/sample/baby_1.jpg`

The app attempts to attach this image for simulated scans if present.

## Mock device usage

- Tap the **device strip** to connect/disconnect.
- Use the dashboard overflow menu (**⋮**) and tap **Simulate Scan**.
- The simulated measurement is persisted for the selected baby and plotted on the Bhutani chart.

## Export behavior

- Tap the **download** icon in the dashboard top row.
- The export writes JSON (camelCase keys) to app documents directory.
- Export includes baby and measurement metadata, with `hasImage` but no raw image bytes.
- A snackbar displays success/failure and the saved path.
