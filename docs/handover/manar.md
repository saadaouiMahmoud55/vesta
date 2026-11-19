# Handover: Manar (VST-114)

What I built in Vesta, how to find it, how to test it, and what is still open. One page.

## Tickets done

- **Foundations:** monorepo and branch protection (VST-16), Jira (VST-17), Firebase project and Auth (VST-18, 32, 34), Flutter skeleton with theme, navigation, i18n (VST-62), logo and app icon (VST-65), C4 levels 1-2 and README (VST-25, 26, 69).
- **Product and data:** offer types spec (VST-100, 103), data model v2 and Firestore rules (VST-74), guest browsing (VST-72), absurd-price bug (VST-104).
- **Features (Flutter):** chat (VST-44), map and geolocation (VST-42), settings and language switcher (VST-95), onboarding, part 1 of VST-99.
- **Design pass 1 (VST-109, PR #76, still in review):** login (welcome text, "Continue as guest"), sign up, onboarding, settings (Account card: change password, notifications), notifications empty state, chat list, chat room (listing strip, date separators), map price pins and preview card. Search now matches the listing title as well as the city.
- **Security (VST-101):** the 3 Firebase API keys are restricted to the 25 Firebase APIs. See `firebase/README.md`.
- **Release and process:** debug app id so `flutter run` does not remove the Play test build (VST-102), Play test log (VST-76), search filters reset bug (VST-124, PR #72).

## Where the code is

| Feature | Folder / file |
|---|---|
| Chat | `flutter-app/lib/features/chat/` (`chat_models`, `chat_repository`, `chat_controller`, `chat_list_screen`, `chat_screen`) |
| Map | `flutter-app/lib/features/map/` (`map_screen`, `map_controller`, `location_service`, `map_listing_preview`) |
| Onboarding | `flutter-app/lib/features/onboarding/` |
| Rules and tests | `firebase/firestore.rules`, `firebase/tests/`, `docs/data-model.md` |
| Theme and CI | `flutter-app/lib/core/theme/app_colors.dart`, `docs/brand/design-tokens.md`, `tools/check-colors.js`, `.github/workflows/check-colors.yml` |

## Data I use

- **Chat:** one conversation per listing and per buyer, id `{listingId}_{buyerId}`. `participantIds` always has 2 uids. Messages are in the subcollection `messages` (last 50 loaded, listener removed when the screen closes). A send is one batch: the message, `lastMessage`, `lastMessageAt` and +1 in `unread` for the other person. The unread map (`uid -> count`) feeds the badge on the chat icon (`unreadTotalProvider`). Each message picks its own text direction (Arabic, French, English mixed).
- **Map:** `flutter_map` with OpenStreetMap tiles (no Google key, no billing). The map reads the 100 newest listings and shows those with `latitude`, `longitude` and that are still available. Attribution "© OpenStreetMap contributors" is always visible. `geolocator` asks the permission only when the user taps "my location", and every refusal is a normal result.
- **Onboarding:** 3 screens at first launch, "seen" saved on the phone with `shared_preferences` (`onboarding_seen`) and read in `main()`, so the home never flashes.
- **Rules:** listings are public to read (guests), writes are owner only. Phone number is private (`listings/{id}/contact/info`, signed-in read). Conversations and messages: participants only. Emulator tests are in `firebase/tests/`.
- **Workflow:** Jira To Do, In Progress, In Review, Done. Branch `feature/VST-NN-name`, PR into `develop`, commit `type(scope): message [VST-NN]`, `node tools/check-colors.js` must pass.

## How to test

1. `cd flutter-app; flutter analyze; flutter test; node ../tools/check-colors.js`.
   Design: open the app in English, French and Arabic and check login, settings, chat and the map.
2. Chat: two accounts on two phones. Contact the owner from a listing, send messages both ways, check the unread badge, then open the chat and check it goes to 0.
3. Map: open Carte, tap a pin (preview card), tap "my location" and allow, then deny, and check the map still works.
4. Onboarding: clear the app data, open the app, check the 3 screens appear once.
5. Rules: see `firebase/README.md` for the emulator.

## Known limits

- Notification center (second half of VST-99) is not started, it needs chat, alerts and booking events first.
- No server push: no Cloud Functions on the free plan. Alerts are in-app and local only.
- The map and the search read only the 100 newest listings.
- The map shows no price pins until a listing has `latitude` and `longitude`: the publish form has no location picker yet (VST-39, Ahmed).
- The Android API key has no application restriction yet (it needs the Play App Signing SHA-1 from Mahmoud, see `firebase/README.md`). Apple and Google sign-in are not done (Apple needs a paid developer account).
- Listings are in one `listings` collection with `listingType` (sale, rent) and `rentPeriod`. Splitting them into separate collections (sales, rentals) was suggested; it would change the rules, both apps and the data, so it is future work.
- The Arabic text of the onboarding needs a native read.
- React Native map (VST-43) not started: `react-native-maps` does not display in Expo Go on Android.

## 3 questions a teammate could ask

1. **Why is the conversation id `{listingId}_{buyerId}`?** One conversation per buyer and listing, no duplicate if the buyer taps "Contact" twice, and the rules can check the id.
2. **Why is the phone number not in the listing document?** The listing is public (guests read it); the number is in `contact/info`, which only signed-in users can read.
3. **Why does the app not use Google Maps?** It needs a billing account, which we ruled out; OpenStreetMap is free, with attribution and tile-usage rules.
