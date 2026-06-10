# Bilirubin

An offline-first Flutter companion app for handheld neonatal bilirubin measurement devices. Built for healthcare workers to screen and monitor newborn hyperbilirubinemia at the point of care.

## What it does

The app connects to a Raspberry Pi-based handheld bilirubin sensor over Wi-Fi and records transcutaneous bilirubin measurements for individual babies. Each measurement is automatically classified against the Bhutani nomogram (Pediatrics 2000) into one of five risk zones — Low, Intermediate, High-Intermediate, High, and Very High — and plotted on an interactive chart so clinicians can track trends over time.

All data is stored locally first (SQLite via Drift), so the app works without internet access. When a connection is available, records synchronise to a Supabase backend.

## Roles

The app has three user roles, each with a different experience:

- **Admin** — full access; manages staff and parent accounts, links parents to babies, initiates and resolves baby transfers between hospitals, and views the audit log
- **Staff** — records measurements, manages babies, and uses the main dashboard
- **Parent** — read-only view of their linked baby's measurements and risk zone history

## Key features

- **Authentication** — email and password login via Supabase Auth; deactivated accounts are blocked at login
- **Baby management** — create, edit, archive, and permanently delete babies; transfer babies across hospitals
- **Device pairing** — auto-discovers the Pi sensor on the local network via UDP beacon (port 4040); falls back to a built-in simulator for development and demonstration
- **Bhutani chart** — interactive nomogram overlay showing all historical measurements per baby with auto-scaling Y-axis
- **Risk classification** — automatic zone assignment with a recommendation card shown on the dashboard
- **Parent access** — admins link parent accounts to babies; parents see a read-only dashboard for their baby
- **Baby transfers** — initiate, accept, reject, and cancel inter-hospital transfers with a full preview and permanent-data-loss warning
- **Cloud sync** — outbox-based synchronisation to Supabase; gracefully degrades if offline
- **Audit log** — full audit trail of sensitive actions (account changes, transfers, exports, parent links) viewable by admins
- **App lock** — optional PIN and biometric (Face ID / fingerprint) protection
- **Localisation** — English and Indonesian (Bahasa Indonesia)
- **Dark mode** — system / light / dark theme toggle

## Tech stack

| Layer | Technology |
|---|---|
| UI | Flutter (Material Design 3) |
| State | Riverpod 2 |
| Navigation | GoRouter |
| Local DB | Drift (SQLite) |
| Auth & backend | Supabase |
| Secure storage | flutter_secure_storage |
| Crypto | pointycastle (AES-GCM, SHA-256) |
| Biometrics | local_auth |
| i18n | flutter_localizations + intl |

## Configuration

Copy `.env.example` to `.env` and fill in your Supabase project URL and anon key:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Run code generation after pulling (required for Drift DAOs):

```
dart run build_runner build --delete-conflicting-outputs
```
