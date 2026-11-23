# Vesta React Native app

Reduced React Native version of Vesta, kept for the academic demo (the Flutter app is the one published on Google Play). It uses Expo SDK 57, TypeScript and the Firebase JavaScript SDK, so it runs in Expo Go.

## Run the app

```sh
npm install
cp .env.example .env        # PowerShell: Copy-Item .env.example .env
# Fill the EXPO_PUBLIC_FIREBASE_* values in .env (ask Manar for the Firebase project values).
npm start
```

Open the QR code with Expo Go on the same network as the development computer. Firebase credentials are read from `.env`; never commit `.env`, real keys, `google-services.json`, or signing keystores.

## What the app covers

Login and sign-up, listings (Explore tab, details with photo gallery, contact buttons for call and WhatsApp), publish form with photos, search with filters, map (OpenStreetMap), chat, message alerts with an unread badge, and English, French and Arabic.

Not done in this version: the Favorites and Profile tabs (placeholder screens), guest browsing, My listings, account deletion, onboarding and settings. Booking requests are on the unmerged branch `feature/VST-85-rn-booking`. Details and test results: `docs/report/limits-and-future-work.md`.

## Project structure and screen rules

- `src/core/` contains the theme, configuration, translations, and shared components.
- `src/data/` contains Firebase initialization, models, and repositories.
- `src/features/` contains one module per product area: auth, listings, search, map, chat, favorites, profile, and notifications. Each folder has a short README.
- `src/navigation/` contains the native stack navigators, the bottom tabs and the authentication guard.

Use this call flow: **Screen → Controller (hook or context) → Repository → Firebase**. A screen must never call Firebase directly. Keep visual colors in `src/core/theme.ts` and display all screen text with translation keys.

React Navigation native stack is used because it provides native stack transitions and supports separate auth and main flows. The root guard selects the auth stack when signed out and the main stack when signed in. The auth controller (`src/features/auth/authController.tsx`) follows the Firebase session: the app starts on Log in or on Home depending on the kept session.

## Translations and language switching

All texts come from the master file `docs/translations.csv`. Do not edit `src/core/translations/en.ts`, `fr.ts` and `ar.ts` by hand: edit the master file and run `node scripts/translations.js build` from the repo root (see `CONTRIBUTING.md` and `docs/translations.md`). Use a key through `AppText`'s `translationKey` or `useTranslation()`. Do not add user-facing strings directly to screens or components. The initial language follows the phone language when it is English, French, or Arabic; other phone languages fall back to English.

Arabic uses right-to-left layout. The language selector saves the selected language. Changing between Arabic and a left-to-right language updates the native layout direction and reloads the app to apply it; this reload is required on Android. The selected language is restored after reload.

## Checks

```sh
npx tsc --noEmit
npm test
```

From the repo root, also run `node tools/check-colors.js` (no color written outside `src/core/theme.ts`).
