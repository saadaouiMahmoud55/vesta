# Vesta — Flutter app

Flutter version of the Vesta real estate app (buy / rent). Created in Sprint 0 (Eya) for ticket VST-21.

## Requirements

- Flutter 3.47.5 (stable). Check yours with `flutter --version`.
- Android Studio with the Android SDK. `flutter doctor` must show a green "Android toolchain".
- An Android phone with USB debugging enabled (a real device is required to validate tickets).

## Android package

`com.vesta.flutterapp`

This is the package registered in Firebase. Do not change it.

## Run the app

From the `flutter-app/` folder, with the phone plugged in and unlocked:

```
flutter pub get
flutter devices
flutter run -d <device-id>
```

Or in one line: `flutter pub get && flutter run`

Expected result: a white screen with the word "Vesta" in the center.

The first build downloads about 180 MB of Android components and can take 10 to 25 minutes on a slow connection. Do not close the terminal. If it fails with a network error, run `flutter run` again: files already downloaded are kept.

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
5. **Test the APK on a real phone**: sign up, log in, publish a listing with photos, Arabic. Only then send the AAB. Do **not** use a phone that has the Play Store test version: the release APK has a different signature, so Android asks to uninstall the Play version first, and a tester who does that can break the 14-day closed test count. Use another phone, or an emulator.
6. **Upload the `.aab`** to the Play Console test track.

Notes:
- Without `key.properties`, the release build falls back to debug signing. That is fine for `flutter run --release`, but Google Play will not accept it.
- Each Play upload needs a higher build number: change the number after `+` in `version:` in `pubspec.yaml` (for example `1.0.0+2`).
- The `INTERNET` permission is declared in the main `AndroidManifest.xml`. Without it, Firebase does not work in release builds.
- The first release build downloads the Flutter engine for three architectures and can take 15 to 20 minutes on a slow connection. Later builds take about a minute.

## Secrets (never commit)

- `google-services.json` and `local.properties` are never committed.
- API keys are never committed. Google Maps is not used anymore (see "Map" below), so no map key is needed.
- Firebase config is not set up in this app yet. It comes in a later ticket.

## Project structure

Structure per module: `screen → controller → repository → service` (see C4 level 4).

## Map (OpenStreetMap)

The app uses OpenStreetMap for the map (VST-42): free, no API key, no billing. Decided on 8 Oct (VST-19). Code: `lib/features/map` (`MapScreen`, `LocationService`, `mapListingsProvider`).

Packages tested on a real phone (Redmi 2209116AG, Android 13, debug build):
- `flutter_map` 8.3.2
- `latlong2` 0.10.1
- `geolocator` 14.1.1

These packages were first tested in a throwaway test app and are now in `pubspec.yaml` (VST-42).

Setup:
- Tile URL: `https://tile.openstreetmap.org/{z}/{x}/{y}.png`
- Set `userAgentPackageName: 'com.vesta.flutterapp'` on the `TileLayer`.
- Keep the attribution visible on the map: "© OpenStreetMap contributors" (`RichAttributionWidget`). Use `alignment: AttributionAlignment.bottomLeft` so it is not covered by a floating button at the bottom right.
- Android permissions in `AndroidManifest.xml`: `INTERNET`, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`.
- `INTERNET` is only added to debug builds by default. It is now declared in the main manifest (VST-53), so release builds have it.

Test results (throwaway test app, debug build on the phone):
- Map displays OSM tiles (Tunis), pan and zoom work: yes
- Marker displayed: yes
- Location permission asked and position found: yes (blue marker at the phone position, map recentered)
- Attribution: with the default placement (bottom right) the attribution button was hidden behind the floating button and could not be tapped. With `bottomLeft` it is visible and shows "© OpenStreetMap contributors".

Limits:
- The free OSM tile server is meant for light use (fine for a demo).
- No key to store, nothing secret to commit.

## Troubleshooting (Windows)

- If the project and the Pub cache are on different drives (for example project on `F:`, cache on `C:`), the Android build can fail with the Kotlin error "this and base files have different roots". Fix: add `kotlin.incremental=false` to `%USERPROFILE%\.gradle\gradle.properties` (your PC only, do not commit it), then run `flutter clean`.
- The first build downloads about 180 MB of Android engine files. On a slow connection it can take a long time. If it fails with a network error, run `flutter run` again: files already downloaded are kept.
- If every `flutter` command hangs with no output (even `flutter --version`), an old `flutter.bat` process is probably still holding Flutter's startup lock. List them with `Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match "flutter" }`, stop the leftover `cmd.exe` ones with `Stop-Process -Id <id> -Force`, and close VS Code (its Flutter extension keeps starting `flutter devices`). Do not press Ctrl+C repeatedly during a build.
## Message alerts (VST-50)

Vesta alerts the user about new chat messages only while the app is running. There is no server push.

- The notification center lists the unread conversations, and the bell and chat icons show an unread badge (VST-99).

Limit: sending a real push notification when the app is closed needs a small Cloud Function that calls Firebase Cloud Messaging, and Cloud Functions need the Blaze plan (a bank card). The team decided on 8 Oct not to use a card, so a user whose app is closed sees the unread badge and the notification center the next time the app is opened.

Upgrade path (if a card becomes possible): a Cloud Function sends an FCM push to the receiver's device token when a message is created.
