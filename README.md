# Bilirubin

Offline-first Flutter app for a handheld bilirubin measurement workflow.

## Runtime configuration

Set the Supabase values in a local `.env` file at the project root:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

The app reads this file at startup.

## Raspberry Pi LAN connection

The app can connect directly to a Raspberry Pi on the same Wi-Fi network.

The app will also listen for Pi beacons on UDP port `4040` and auto-detect a Pi when both devices are on the same network.

In the app, open `Settings` and save the Pi address, for example:

```text
192.168.1.50:8080
```

If no scheme is provided, the app uses `http://` automatically.

The Pi service is expected to expose these endpoints:

- `GET /health` returns `200 OK`
- `GET /device` returns JSON with `deviceId`, `displayName`, and optional `firmwareVersion`
- `GET /measurements?after=<iso8601>` returns a JSON array of measurement events

For beacon discovery, the Pi should broadcast a small JSON packet on UDP port `4040` with:

- `type: bilirubin-pi-beacon`
- `deviceId`
- `displayName`
- `host`
- `port`
- optional `firmwareVersion`

Each measurement item should include:

- `measurementId`
- `capturedAt`
- `bilirubinMgDl`
- `deviceId`
- `modelVersion`
- optional `imageBytesBase64`

## Data flow

- Raspberry Pi captures the image and computes the bilirubin value.
- The mobile app can read the Pi directly over LAN for live interaction.
- Supabase stores synced history, sharing, and cloud-backed records.
- Drift remains the on-device cache for offline use.
- Local baby CRUD and device measurements are staged in a local sync outbox before upload to Supabase.