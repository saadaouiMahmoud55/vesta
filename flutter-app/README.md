# Vesta — Flutter app

Flutter version of the Vesta real estate app (buy / rent / sell / stay in Tunisia). It is the reference app: version **1.0.0 (build 3)** is published on Google Play. English, French and Arabic (right-to-left).

## Requirements

- Flutter 3.47.5 (stable). Check yours with `flutter --version`.
- Android Studio with the Android SDK. `flutter doctor` must show a green "Android toolchain".
- An Android phone with USB debugging enabled (a real device is required to validate tickets).
- Your own `google-services.json` in `android/app/` (ask Manar for Firebase access). It is git-ignored.

## Android package

`com.vesta.flutterapp` (release). Debug builds use `com.vesta.flutterapp.debug`, so `flutter run` installs next to the Google Play version without removing it.

The release package is registered in Firebase. Do not change it.

## Run the app

From the `flutter-app/` folder, with the phone plugged in and unlocked:

```
flutter pub get
flutter devices
flutter run -d <device-id>
```

Expected result: the onboarding or login screen, then the Explore tab with the listings.

The first build downloads about 180 MB of Android components and can take 10 to 25 minutes on a slow connection. Do not close the terminal. If it fails with a network error, run `flutter run` again: files already downloaded are kept.

## Project structure

```
lib/
├── main.dart, app.dart      Entry point and app widget
├── firebase_options.dart    Firebase configuration
├── core/                    Theme (color and text tokens), router, config, utils, shared widgets
├── l10n/                    Generated translation files (do not edit by hand)
└── features/                auth, onboarding, listings, search, map, chat, favorites,
                             profile, notifications, settings
```

Structure per module: `screen → controller → repository → service` (see C4 level 4). A screen never calls Firebase directly. Colors only come from `lib/core/theme/`, and every text comes from the translations (see `CONTRIBUTING.md`).

Checks before a PR: `flutter analyze` and `flutter test`, then `node tools/check-colors.js` from the repo root.

## Release build (Android, Google Play)

Done by the person who publishes (VST-53). The package name stays `com.vesta.flutterapp`.

1. **Create the upload keystore (once).** If an upload key already exists (the first Play upload was signed with one), ask Manar for it and do not create a second one: a new key needs a key reset request in the Play Console. Keep it outside the repo and back it up together with its password: losing it blocks every future update. On Windows, `keytool` comes with Android Studio:
   ```
   & "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkey -v -keystore "$env:USERPROFILE\vesta-upload.jks" -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. **Create `android/key.properties`** (already in `.gitignore`, never commit it) with your own values. Use forward slashes in the path:
   ```
   storePassword=<your password>
   keyPassword=<your password>
   keyAlias=upload
   storeFile=C:/Users/<you>/vesta-upload.jks
   ```
3. **Build** from `flutter-app/`:
   ```
   flutter build appbundle --release
   flutter build apk --release
   ```
   Outputs: `build/app/outputs/bundle/release/app-release.aab` (for Google Play) and `build/app/outputs/flutter-apk/app-release.apk` (for a phone test).
4. **Check the signature.** The owner must be your name, not "Android Debug":
   ```
   & "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -printcert -jarfile build\app\outputs\bundle\release\app-release.aab
   ```
5. **Test the APK on a real phone**: sign up, log in, publish a listing with photos, Arabic. Only then send the AAB. Do **not** use a phone that has the Play Store version: the release APK has a different signature, so Android asks to uninstall the Play version first. Use another phone, or an emulator.
6. **Upload the `.aab`** to the Play Console.

Notes:
- Without `key.properties`, the release build falls back to debug signing. That is fine for `flutter run --release`, but Google Play will not accept it.
- Each Play upload needs a higher build number: change the number after `+` in `version:` in `pubspec.yaml` (the published version is `1.0.0+3`).
- The `INTERNET` permission is declared in the main `AndroidManifest.xml`. Without it, Firebase does not work in release builds.
- The first release build downloads the Flutter engine for three architectures and can take 15 to 20 minutes on a slow connection. Later builds take about a minute.

## Secrets (never commit)

- `google-services.json`, `local.properties`, `key.properties` and keystores are never committed.
- API keys are never committed. Google Maps is not used (see "Map" below), so no map key is needed.

## Map (OpenStreetMap)

The app uses OpenStreetMap for the map (VST-42): free, no API key, no billing. Decided on 8 Oct (VST-19). Code: `lib/features/map` (`MapScreen`, `LocationService`, `mapListingsProvider`).

Packages (tested on a real phone): `flutter_map` 8.3.2, `latlong2` 0.10.1, `geolocator` 14.1.1.

Setup:
- Tile URL: `https://tile.openstreetmap.org/{z}/{x}/{y}.png`
- `userAgentPackageName: 'com.vesta.flutterapp'` is set on the `TileLayer`.
- Keep the attribution visible on the map: "© OpenStreetMap contributors" (`RichAttributionWidget`), with `alignment: AttributionAlignment.bottomLeft` so a floating button at the bottom right does not hide it.
- Android permissions in `AndroidManifest.xml`: `INTERNET`, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`.

Limits:
- The free OSM tile server is meant for light use (fine for a demo).
- No key to store, nothing secret to commit.

## Message alerts (VST-50)

Vesta alerts the user about new chat messages only while the app is running. There is no server push.

- The notification center lists the unread conversations, and the bell and chat icons show an unread badge (VST-99).

Limit: sending a real push notification when the app is closed needs a small Cloud Function that calls Firebase Cloud Messaging, and Cloud Functions need the Blaze plan (a bank card). The team decided on 8 Oct not to use a card, so a user whose app is closed sees the unread badge and the notification center the next time the app is opened.

Upgrade path (if a card becomes possible): a Cloud Function sends an FCM push to the receiver's device token when a message is created.

## Troubleshooting (Windows)

- If the project and the Pub cache are on different drives (for example project on `F:`, cache on `C:`), the Android build can fail with the Kotlin error "this and base files have different roots". Fix: add `kotlin.incremental=false` to `%USERPROFILE%\.gradle\gradle.properties` (your PC only, do not commit it), then run `flutter clean`.
- If the first build fails with a network error, run `flutter run` again: files already downloaded are kept.
- If every `flutter` command hangs with no output (even `flutter --version`), an old `flutter.bat` process is probably still holding Flutter's startup lock. List them with `Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match "flutter" }`, stop the leftover `cmd.exe` ones with `Stop-Process -Id <id> -Force`, and close VS Code (its Flutter extension keeps starting `flutter devices`). Do not press Ctrl+C repeatedly during a build.
- Sign-in blocked with "Requests from this Android client application are blocked": see the API key notes in `firebase/README.md`.
