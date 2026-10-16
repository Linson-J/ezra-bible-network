# Ezra Bible Network

Android app for Ezra Bible Network. It has four tabs: a live TV stream, the program schedule, a verse of the day, and a More tab for prayer requests, contact details and settings.

- **Android only.** Package `com.ezrabiblenetwork.app`, minSdk 23, targetSdk 36.
- **No Firebase.** Notifications are local (`flutter_local_notifications`).
- **Ready for a backend.** All data goes through repository interfaces. Today the data comes from JSON files in `assets/data/`. Set `DATA_SOURCE=api` to use the HTTP API described below.
- **Flutter 3.32.0 / Dart 3.8.0.** Do not upgrade. Package versions are chosen to work with this SDK.

## Setup

```bash
cp .env.example .env      # then edit .env
flutter pub get
flutter run               # with a device or emulator connected
```

The app bundles `.env` at build time. Edit it, then rebuild.

| Key | Purpose |
|---|---|
| `STREAM_URL` | **Required.** The HLS (`.m3u8`) URL, e.g. `https://riotv.stream.onecloudlive.in/riotv/riotvmax/index.m3u8`. |
| `STREAM_BACKUP_URL` | Optional. A second HLS URL, tried right away if the first one fails. |
| `DATA_SOURCE` | `local` (JSON assets) or `api`. |
| `API_BASE_URL` | Required when `DATA_SOURCE=api`, e.g. `https://api.example.com`. |
| `DAILY_VERSE_HOUR` / `DAILY_VERSE_MINUTE` | Default time for the daily verse notification, in the device's time zone. Users can change it in Settings. |

If `.env` is missing, if `STREAM_URL` is empty, or if `STREAM_URL` is not an http(s) URL, the app shows a **Configuration error** screen that explains the problem.

> **RTMP vs HLS.** `rtmp://…` is the *ingest* URL that OBS or your encoder pushes to. The app can't play RTMP. Use the HLS `…/index.m3u8` URL that the streaming server publishes.

`.env`, `android/key.properties` and keystores are gitignored. Commit only `.env.example`.

### Content to replace before release

The files in `assets/data/` contain **sample data**:

- `app_content.json`: placeholder address, email, phone, WhatsApp and social links. Replace all of them.
- `schedule.json`: a sample weekly schedule. `dayOfWeek` runs from 1 (Monday) to 7 (Sunday). Times are `HH:mm` in the viewer's local time. A program whose `endTime` is earlier than its `startTime` runs past midnight.
- `app_config.json`: set `donationUrl`. Leave `streamUrl` empty to use the URL from `.env`.
- `verses.json`: 366 verses, one per day of the year, King James Version (public domain).

## Project layout

```
lib/
  config/          env.dart (typed .env access), app_constants.dart
  models/          Program, Verse, AppContent, AppConfig, PrayerRequest (fromJson/toJson)
  repositories/    abstract interfaces + repository_provider.dart (picks local or api)
    local/         read assets/data/*.json
    api/           http implementations of the API contract below
  services/        player_service, notification_service, settings_service, native_bridge
  state/           app_state.dart (loaded data, reminders, verse scheduling)
  screens/         splash, home_shell (bottom nav), live, schedule, verse, more, …
  widgets/         reusable UI
  theme/           app_theme.dart
android/app/src/main/kotlin/com/ezrabiblenetwork/app/
  MainActivity.kt     PiP (manual + auto on Home), battery-optimisation settings
  PlaybackService.kt  mediaPlayback foreground service for background audio
```

## How things work

**Live stream.** The player is `better_player_plus`, pinned to **1.0.8** exactly. `PlaybackService.kt` uses that version's media-notification id (20772077). Check it before upgrading the package.

- If the primary URL fails, the app tries the backup URL. If both fail, it shows an offline/error screen and retries every 10 seconds. It also retries as soon as the network comes back.
- **Go Live** reloads the stream, which jumps back to the live edge after a pause.
- **Background playback.** better_player shows the media notification with lock-screen play/pause. A small native foreground service (`foregroundServiceType="mediaPlayback"`) takes over that same notification, so Android doesn't kill the app and only one notification appears.
- **Picture-in-picture.** There's a PiP button, and the app enters PiP automatically when the user leaves it while video is playing. Users can turn the automatic part off in Settings.
- **Audio-only** hides the video. If the stream offers several qualities, it also switches to the lowest bitrate. The current stream has only one quality (576p), so for that stream audio-only saves no data.

**Daily verse.** Each day's verse is different, so the app can't use one repeating notification. On every app open, and whenever the user changes the setting, it schedules the next 30 days as separate notifications. The notification plugin's boot receiver restores them after a reboot or app update. If the user doesn't open the app for 30 days, the verses stop until the next open.

**Program reminders.** Tapping the bell on a program sets a weekly notification 10 minutes before it starts. Reminders are saved in SharedPreferences. On launch, the app re-applies them against the current schedule.

**Alarms are inexact.** The app doesn't request `SCHEDULE_EXACT_ALARM`, so Android may deliver notifications a few minutes late, especially in Doze. On first launch the app asks for the notification permission (Android 13+). It then asks once whether to open the battery-optimisation settings. It opens the system list rather than requesting the Play-restricted `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.

## Icons and splash

Both are generated from `assets/images/logo.png`:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

The status-bar notification icon is `android/app/src/main/res/drawable/ic_notification.xml`, a white cross. Replace it with a single-colour silhouette of the logo if you like.

## Build

```bash
flutter analyze
flutter test
flutter build apk --debug          # quick test build
```

### Release AAB (Play Store)

1. Create an upload keystore once, and keep it and its passwords safe:
   ```bash
   keytool -genkey -v -keystore ~/ezra-upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create `android/key.properties` (gitignored):
   ```properties
   storePassword=<store password>
   keyPassword=<key password>
   keyAlias=upload
   storeFile=/home/<you>/ezra-upload-keystore.jks
   ```
3. Increase `version:` in `pubspec.yaml`. The number after `+` is the versionCode and must go up with every upload.
4. Build:
   ```bash
   flutter build appbundle --release
   # → build/app/outputs/bundle/release/app-release.aab
   ```

If `key.properties` is missing, release builds are signed with the debug key. That's fine for testing, but the Play Store rejects them. Release builds use R8. Keep rules are in `android/app/proguard-rules.pro`.

**Play Console notes:** The app uses a foreground service of type `mediaPlayback`. The Play Console asks you to declare it and explain it ("continue the live stream when the screen is off"). The app needs no exact-alarm declaration.

## Connecting a backend later

1. Implement the endpoints below.
2. In `.env`, set `DATA_SOURCE=api` and `API_BASE_URL=https://your-api`, then rebuild.

No other code changes are needed. `lib/repositories/api/` already implements this contract, and `repository_provider.dart` switches to it. All responses are JSON. Dates are `YYYY-MM-DD`. Times are `HH:mm`.

| Method | Path | Response |
|---|---|---|
| GET | `/api/config` | `{ streamUrl, streamBackupUrl, isLive, offlineMessage, announcement, minAppVersion, forceUpdate, donationUrl }` |
| GET | `/api/schedule` | `[ { id, title, speaker, description, dayOfWeek, startTime, endTime, thumbnailUrl } ]` |
| GET | `/api/content` | `{ about, address, email, phone, whatsapp, youtubeUrl, facebookUrl, instagramUrl, websiteUrl }` |
| GET | `/api/verses?from=YYYY-MM-DD&days=30` | `[ { date, reference, text } ]` |
| POST | `/api/prayer-requests` | body `{ name, phone, request }` → `201` |
| POST | `/api/devices` | body `{ fcmToken, platform }` → `201` (future push notifications) |

Field meanings:

- **config.streamUrl / streamBackupUrl**: if non-empty, they override `.env`. You can change the stream without shipping an app update.
- **config.isLive**: `false` shows the "off air" screen with `offlineMessage` and doesn't connect until the user taps **Try anyway**.
- **config.announcement**: if non-empty, it appears as a banner on the Live tab.
- **config.minAppVersion + forceUpdate**: if `forceUpdate` is true and the installed version is older than `minAppVersion`, a blocking dialog links to the Play Store.
- **schedule.dayOfWeek**: 1 = Monday … 7 = Sunday. `thumbnailUrl` may be empty.
- **verses**: return exactly `days` consecutive entries starting at `from`.
- **prayer-requests**: when `DATA_SOURCE=api`, the prayer screen submits the form directly instead of opening WhatsApp or email.
- **devices**: `DeviceRepository` is in place, but nothing calls it yet. Push notifications would need FCM, which this app deliberately doesn't use yet.

If an API call fails, the app keeps working with built-in defaults: an empty schedule with a Retry button, and the stream URL from `.env`.
