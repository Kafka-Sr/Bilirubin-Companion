# Bilirubin

An offline-first Flutter companion app for handheld neonatal bilirubin measurement devices. Built for healthcare workers to screen and monitor newborn hyperbilirubinemia at the point of care.

## What it does

The app connects to a Raspberry Pi-based handheld bilirubin sensor over Wi-Fi and records transcutaneous bilirubin measurements for individual babies. Each measurement is automatically classified against the Bhutani nomogram (Pediatrics 2000) into one of five risk zones — Low, Intermediate, High-Intermediate, High, and Very High — and plotted on an interactive chart so clinicians can track trends over time.

All data is stored locally first (SQLite via Drift), so the app works without internet access. When a connection is available, records sync to a Supabase backend.

### Key features

- **Baby management** — create, edit, and archive patient records with name, date of birth, and weight
- **Device connection** — auto-discovers the Pi sensor on the local network via UDP beacon (port 4040); falls back to a built-in simulator for development and demo
- **Bhutani chart** — interactive nomogram overlay showing all historical measurements per baby with auto-scaling Y-axis
- **Risk classification** — automatic zone assignment with a recommendation card shown on the dashboard
- **App lock** — optional PIN + biometric (Face ID / fingerprint) protection for sensitive medical data
- **Cloud sync** — outbox-based sync to Supabase; gracefully degrades if not configured
- **Audit log** — local audit trail for exports, edits, and deletions
- **Localization** — English and Indonesian (Bahasa Indonesia)
- **Dark mode** — system / light / dark theme toggle

## Tech stack

| Layer | Technology |
|---|---|
| UI | Flutter (Material Design 3) |
| State | Riverpod 2 |
| Navigation | GoRouter |
| Local DB | Drift (SQLite) |
| Secure storage | flutter_secure_storage |
| Crypto | pointycastle (AES-GCM, SHA-256) |
| Biometrics | local_auth |
| Backend | Supabase (optional) |
| i18n | flutter_localizations + intl |

## Not yet implemented

The following features are partially built or planned for a future release:

- **BLE support** — the settings screen has a placeholder section for Bluetooth Low Energy device pairing; not yet functional
- **Wi-Fi provisioning** — UI exists to enter SSID and password for configuring the Pi's network; values are not yet persisted or used
- **Image handling** — measurements can carry a JPEG from the device; the encryption infrastructure and data model are in place, but image capture, storage, and display are not yet wired into the UI
- **Export to file** — the `ExportBottomSheet` widget and audit trail exist, but file export is not integrated into the main UI
- **Multi-device support** — currently supports one Pi at a time via a single base URL setting; a device manager is planned
- **Medical validation** — Bhutani boundary curves are hardcoded and pending formal verification against the source paper before clinical deployment

## Configuration

Copy `.env.example` to `.env` and fill in your Supabase project URL and anon key. If these are left blank the app runs in fully offline mode.

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Run code generation after pulling (required for Drift DAOs):

```
dart run build_runner build --delete-conflicting-outputs
```
