# Vesta React Native app (VST-63)

The React Native app uses Expo SDK 57, TypeScript, and the Firebase JavaScript SDK so it can run in Expo Go.

## Run the app

```sh
npm install
Copy-Item .env.example .env
# Fill the EXPO_PUBLIC_FIREBASE_* values in .env when connecting to a Firebase project.
npm start
```

Open the QR code with Expo Go on the same network as the development computer. Firebase credentials are read from `.env`; never commit `.env`, real keys, `google-services.json`, or signing keystores.

## Project structure and screen rules

- `src/core/` contains the theme, configuration, translations, and shared components.
- `src/data/` contains Firebase initialization, models, and repositories.
- `src/features/` contains one module per product area: auth, listings, search, map, chat, favorites, profile, and notifications.
- `src/navigation/` contains the native stack navigators and the authentication guard.

Use this call flow: **Screen → Controller (hook or context) → Repository → Firebase**. A screen must never call Firebase directly. Keep visual colors in `src/core/theme.ts` and display all screen text with translation keys.

React Navigation native stack is used because it provides native stack transitions and supports separate auth and main flows. The root guard selects the auth stack when signed out and the main stack when signed in. The auth controller (`src/features/auth/authController.tsx`) follows the Firebase session: the app starts on Log in or on Home depending on the kept session.

## Translations and language switching

Translations live in `src/core/translations/en.ts`, `fr.ts`, and `ar.ts`. To add a translation key, add the same key to all three files, then use it through `AppText`'s `translationKey` or `useTranslation()` in a screen. Do not add user-facing strings directly to screens or components. The initial language follows the phone language when it is English, French, or Arabic; other phone languages fall back to English.

Arabic uses right-to-left layout. The language selector saves the selected language. Changing between Arabic and a left-to-right language updates the native layout direction and reloads the app to apply it; this reload is required on Android. The selected language is restored after reload.

## Checks

```sh
npx tsc --noEmit
npm test
```
