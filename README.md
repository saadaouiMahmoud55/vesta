# Vesta: Real Estate & Homes

Mobile app to buy, rent, sell and stay in Tunisia: search, view and publish real-estate listings. It is built **twice**, with **Flutter** and with **React Native**, on one shared **Firebase** backend, in Tunisian Arabic, French and English.

Mini-project *Application Mobile Services Immobilier* (supervisor: Wahid Hamdi, ISET), due **24 Nov 2026, 08:30**. Code freeze: **17 Nov 2026**.

## Status

| App | State |
|---|---|
| **Flutter** (reference app) | Version **1.0.0 (build 3)**, published on Google Play on 19 Nov 2026 (package `com.vesta.flutterapp`). |
| **React Native** (academic demo) | Reduced version of the Flutter app, run with Expo Go. Not published. |

Frozen code: tag `v1.0.0-rc1` (merge of `develop` into `main`, PR #142). Known limits and future work are in [`docs/report/limits-and-future-work.md`](docs/report/limits-and-future-work.md).

## Team
Manar Degachi · Eya Ben Belgacem · Ahmed Bouguerra · Mahmoud Saadaoui

## Features (Flutter app)
Sign up and log in · Guest browsing · Onboarding · Search with filters (offer type, city, price, property type) · Listing details with photo gallery · Publish, edit and delete a listing (up to 10 photos) · Map with geolocation (OpenStreetMap) · Real-time chat · Favorites · Profile and My listings · Call and WhatsApp contact buttons · In-app notification center and unread badges · Settings and account deletion · English, French and Arabic (right-to-left).

The React Native app covers login, search and filters, listings with details and photo gallery, publishing, map, chat (read), contact buttons and message alerts. Booking requests, reviews and the AI assistant are not merged in either app (see the limits document).

## Repository layout
```
vesta/
├── flutter-app/         Flutter version (Dart)
├── react-native-app/    React Native version (TypeScript, Expo)
├── firebase/            Firestore rules, indexes and emulator tests
├── docs/
│   ├── brand/           Logo, icons, colors
│   ├── c4/, uml/        C4 model (levels 1-4) and UML diagrams
│   ├── demo/            Demo script and Q&A sheets
│   ├── handover/        Handover notes per team member
│   ├── report/          Final report, limits, slides outline
│   ├── store/           Google Play texts and screenshots
│   ├── data-model.md    Firestore data model
│   ├── test-plan.md     Test plan and results
│   └── ...              Translations, UI kit, user stories, Jira backlog
├── scripts/             Translations build and GitHub setup helpers
├── tools/               Color check used by CI
└── .github/             PR template and CI workflows
```

## Architecture
Both apps share the same module structure: Auth, Search, Listing details, Publish, Map, Chat, Favorites, Profile and Notifications, on top of a single data layer in front of Firebase (Auth, Firestore) and OpenStreetMap. The call flow is always **screen → controller → repository → Firebase**: no screen talks to Firebase directly. Photos are stored as compressed base64 in Firestore (no Firebase Storage, no Google Maps, so no billing account is needed). Diagrams are in [`docs/c4/`](docs/c4/README.md) and [`docs/uml/`](docs/uml/README.md).

## Getting started
1. Clone: `git clone https://github.com/manar09-code/vesta.git && cd vesta && git checkout develop`
2. Ask Manar for the Firebase project access, then download **your own copy** of `google-services.json` (Android) into `flutter-app/android/app/`. It is git-ignored, never commit it.
3. Flutter: see [`flutter-app/README.md`](flutter-app/README.md). React Native: see [`react-native-app/README.md`](react-native-app/README.md). Firestore rules and tests: see [`firebase/README.md`](firebase/README.md).

## Workflow
Read [CONTRIBUTING.md](CONTRIBUTING.md). Tasks live in Jira (project key **VST**). Two GitHub Actions run on every PR into `develop`: the color check (`tools/check-colors.js`) and the translations check (`scripts/translations.js check`).

## Future work (out of the MVP)
- **Booking requests** (VST-85 React Native, VST-92 Flutter). Both were left unmerged after the code freeze (PR #151 for React Native was closed): the work is kept on the branches `feature/VST-85-rn-booking` and `feature/VST-92-flutter-booking`. They need the `bookings` and `blockedNights` data structure, Firestore rules with tests and a rules deployment first. Firestore rules cannot check that two accepted bookings do not overlap, so the app checks before a request is sent and the owner accepts manually.
- **Real server push notifications (FCM).** They need Cloud Functions (Blaze plan) or a small external server. The app uses an in-app notification center instead (VST-99).
- **Firebase Storage for photos.** Storage also needs the Blaze plan. Photos are stored as compressed base64 in `listings/{id}/photos` (max 10).
- **Reviews, AI assistant, server-side search and pagination**: see the limits document.
