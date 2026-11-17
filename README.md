# OurSound

A Flutter couples app for sharing music, memories, and time together.

## Features

- **Music discovery**: search the catalog by title/artist/mood, or use **Find on
  YouTube** to search YouTube and add a result to your library. YouTube tracks
  play inside the app with an embedded player — **nothing is downloaded or
  stored locally**, they stream on demand.
- **Memories**: add memories with **photos and videos** picked from the device.
  Media is uploaded to the backend (`POST /api/memories`, 20 MB per file, up to
  10 files) and shown in the memory detail screen.
- **Other**: chat, playlists, daily questions, challenges, moods, dedications,
  listen-together, stats, and phone-number based couple matching.

## Privacy & permissions (opt-in)

The `AppPermission` features on the **Privacy & Permissions** screen are all
**OFF by default**. Nothing is collected until the user explicitly turns a
feature on:

- Toggling a permission on opens a confirmation explaining exactly what is
  collected and where it goes. The user must choose **"I understand — Enable"**.
- Location access is requested from the operating system only after the user
  opts in to the GPS feature.
- Each feature runs only while the app is open.
- Turning a feature off stops collection immediately and deletes locally stored
  snapshot data. "Revoke All Permissions" does the same for everything.
- Snapshots are kept in a plainly named folder in the app's own storage, never
  a hidden one.

An older build that defaulted these permissions to ON is migrated once on first
launch: stored values are cleared so the user is actually asked.

## Development

```bash
flutter pub get
flutter analyze
flutter run

# Release APK
flutter build apk --release
```

The backend lives in `backend/` (Node/Express + Prisma). See `backend/.env.example`
for configuration.
