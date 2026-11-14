# Handover: Ahmed (VST-111)

What I built in Vesta, how to find it, how to test it, and what is still open. Updated 12 Nov 2026.

## Tickets done

- **Quality and process:** test plan with 60 test cases for both apps (VST-52, PR #39), design-system colors check with a GitHub Action (VST-78, PR #48).
- **React Native:** authentication (VST-37, PR #53, merged 5 Nov): login, sign up, session kept after restart, log out.
- **Flutter:** shared UI kit with the 4 listing widgets of VST-100 (VST-93, PR #52, merged; `flutter analyze` and `flutter test` pass, 146 tests).
- **Translations:** one master file and one script for both apps (VST-70, PR #54, merged 12 Nov).
- **React Native language default:** start in Arabic when the phone language is not English, French or Arabic (VST-105, PR #77, merged 12 Nov).
- **React Native navigation and packages:** bottom tabs with placeholder screens (PR #78) and the image packages `expo-image-picker` and `expo-image-manipulator` (PR #79), both merged 12 Nov.
- **Screens:** React Native login, sign up and the 5-tab shell; Flutter UI kit debug screen (`/ui-kit`).
- **Design:** Sprint 0 mockups (Figma `Vesta-mockups` is the reference for the palette only).

## Where the code is

| Feature | Folder / file |
|---|---|
| Test plan | `docs/test-plan.md` (version 2) |
| Colors check | `tools/check-colors.js`, `.github/workflows/check-colors.yml`, `docs/brand/design-tokens.md` |
| RN auth | `react-native-app/src/features/auth/` (`LoginScreen`, `SignUpScreen`, `authController.tsx`), `src/data/repositories/authRepository.ts`, `authErrors.ts`, `authValidation.ts`, `src/data/firebase.ts`, `src/types/firebase-auth.d.ts`, guard in `App.tsx` |
| UI kit | `flutter-app/lib/core/widgets/`, `lib/core/theme/` (`app_dimens.dart`, `app_text_styles.dart`), `lib/features/listings/listing_card.dart`, `docs/ui-kit.md`, `flutter-app/test/ui_kit_test.dart` |
| UI kit debug screen | route `/ui-kit` (no menu entry any more, see `docs/ui-kit.md`) |
| Translations | `docs/translations.csv` (master), `scripts/translations.js`, `docs/translations.md`, `.github/workflows/translations.yml` |
| RN language default | `react-native-app/src/core/language.ts`, `config.ts`, `i18n.ts`, `__tests__/language.test.ts` |
| RN navigation | `react-native-app/src/navigation/` (`MainStack.tsx`, `MainTabs.tsx`, `PlaceholderScreen.tsx`) |

## Data I use

- **RN auth:** `LoginScreen` / `SignUpScreen` call `AuthController` (`useAuth()` gives `user`, `isInitializing`, `isSignedIn`, `isLoading`, `error`, `signIn`, `signUp`, `signOut`, `clearError`), which calls `AuthRepository`, which calls Firebase Auth. No Firebase call in a screen. Sign up writes `users/{uid}` (`displayName`, `createdAt`) and `users/{uid}/private/contact` (`email`) in one batch, sends the verification mail, and deletes the new Auth account if the batch fails (same as Flutter). The session is kept with AsyncStorage. Password minimum is 8 characters. Guest browsing, forgot password and the email banner are a separate ticket after the RN MVP. The Log out button on `HomeScreen` is temporary (it can move to Profile, VST-49).
- **Texts:** nobody edits `app_en/fr/ar.arb` or the React Native `en/fr/ar.ts` by hand. Add a row in `docs/translations.csv` (key, en, fr, ar, screen, note), then `node scripts/translations.js build`. CI runs `--self-test` and `check`. Keys are dotted in the CSV (`auth.login.button`) and camelCase in code (`authLoginButton`). A number placeholder is `{count:int}`; without `:int` the ARB gets a String and `flutter analyze` fails. A French or Arabic text equal to English needs `same` in the note. Never translate `Vesta` or `TND`. The Flutter generated files (`lib/l10n/generated/`) are committed: run `flutter gen-l10n` and commit them. If `develop` moved and the generated files conflict, do not resolve them by hand: keep both sides in the `.arb` files, regenerate with `flutter gen-l10n`.
- **Colors:** only theme tokens (`app_colors.dart` in Flutter, `src/core/theme.ts` in React Native). Background is `#FAF8F4`, error is `#A33B32`. `node tools/check-colors.js` must pass (the Action scans `react-native-app/src` and `App.tsx` too).
- **UI kit:** use `lib/core/widgets` before writing a new widget (`PrimaryButton`, `AppTextField`, `LoadingView`, `EmptyState`, `ErrorState`, `ListingCard`, ...). Right-to-left helpers: `isRtl`, `DirectionalIcon`, `LtrText`. Full list in `docs/ui-kit.md`.
- **Prices and offers:** `formatPrice` gives `TND 120,000`, always left-to-right. Units `/ night`, `/ month`, `/ year`. `offerTypeOf(listing)` decides sale (terracotta), rent (navy) or stay (blue): sale = sale, rent = rent + month/year, stay = rent + night.
- **Photos (both apps):** no Firebase Storage. Up to 10 photos per listing, about 800 px JPEG, base64 under about 270000 characters (the rules accept 280000), in `listings/{id}/photos/p0..p9` (`base64`, `createdAt`), with `photoCount` on the listing.
- **Workflow:** branch `feature/VST-NN-name`, PR into `develop`, commit `type(scope): message [VST-NN]`. Repo files use CRLF: never run `prettier --write` on the whole RN project. `flutter pub get` changes `flutter-app/linux`, `macos`, `windows`: `git restore` them before committing. Add explicit paths, never `git add -A`. `dart format` only on named files.

## How to test

1. Flutter: `cd flutter-app; flutter analyze; flutter test; node ../tools/check-colors.js`.
2. Translations: `node scripts/translations.js --self-test` and `check`, then `cd flutter-app; flutter gen-l10n`.
3. UI kit: the `/ui-kit` route is no longer reachable from Settings. In a debug build, temporarily add `context.push(AppRoutes.uiKit)` to a button (see `docs/ui-kit.md`), open it on a real phone in Arabic and in French and compare with `docs/ui-kit/ar-1.png` and `fr-1.png`. To see the unavailable card, set `status` to `sold` on a test listing.
4. React Native: `cd react-native-app; npx tsc --noEmit; npm run lint; npm test`, then `npx expo start -c` (add `--tunnel` if the phone cannot reach the PC) and open Expo Go.
5. RN auth on a phone: sign up, close and reopen the app (still signed in), log out, log in, wrong password with 8+ characters.
6. Languages: Login and Home in English, French and Arabic (right-to-left, no key name shown). VST-105: set the phone language to Deutsch, the app opens in Arabic; a language chosen in the app is kept.
7. Test plan: run the cases of `docs/test-plan.md` on a real phone and write the device in the PR.

## Known limits

- `OfflineBanner` only draws the banner (no internet detection). `LoadingView` is a spinner (no skeleton).
- `favorites_screen.dart` keeps its own empty and error views. The Favorites card of the mockups is horizontal; `ListingCard` is vertical.
- UI kit units duplicate the `listingDetailPer*` keys; they can be merged later. `keyFactsOf` shows `0` when a field is filled with 0 (a studio shows "0" bedrooms): Manar decides if it should be hidden.
- Mockup colors for text, secondary text, border and error differ from `AppColors`; the code tokens are kept.
- Offline publish: a Firestore batch commit made offline waits instead of failing: the Publish button shows a spinner and stays disabled, there is no internet check before the commit and no timeout (unlike the chat send), so it can hang and publish later.
- VST-70: the Arabic and French review by two readers and the right-to-left check on a real phone are not done (final check 13 Nov). The ticket says the RN files are `.json`; they are `.ts`.
- Text review points not changed yet: 5 French `favorites.*` texts use "tu" while the rest uses "vous"; 9 Arabic `favorites.*` and `listings.empty` texts are formal Arabic while `docs/i18n/glossary-ar-TN.md` prefers Tunisian; 8 texts exist under two keys.
- React Native is a reduced MVP: no AI assistant, bookings, reviews, Explore Tunisia home or message alerts. RN has 5 bottom tabs (PR #78); Explore is the home screen and some tabs are still placeholders.
- Test plan question NTF-01 (notification permission dialog, no real push in the MVP) is open.

## Still open

- **VST-39 (RN listings), not started, no PR.** Plan: PR 1 = publish form with the 3 offer types and photos (`expo-image-picker`, `expo-image-manipulator`, one `writeBatch` for the listing, photos and `contact/info`, `status: 'available'`, city as text because the RN map picker is not available); PR 2 = list with ribbon and price unit, and details with gallery. Reuse and extend Mahmoud's merged files from PR #58 (`src/data/models/listing.ts`, `listingCategory.ts`, `src/data/repositories/listingsRepository.ts`, `src/features/listings/ListingCard.tsx`): add `offerTypeOf`, the price unit, the ribbon and a `getListing(id)`. The two Expo packages are installed (PR #79). Manar also asked for a latitude and longitude step (or "use my location") so the map shows pins.
- **VST-82 (details and amenities in RN), not started.** The ticket says `governorate`, `checkInTime`, `checkOutTime`; `docs/data-model.md` says `city`, `checkIn`, `checkOut` and at most 10 amenities. The Flutter code is the source of truth.
- **VST-70:** the final check by 13 Nov (`check` plus a search for texts written directly in screens, see `docs/translations.md`), and the right-to-left check with one Jira ticket per problem named `RTL: <screen>: <problem> (Flutter|React Native)` with a screenshot.
- **Merge order:** nothing pending, #52, #54, #77, #78 and #79 are merged. Code freeze is 17 Nov.

## 3 questions a teammate could ask

1. **Why one master CSV for the texts?** Two apps and three languages meant six files to keep in sync by hand. The script generates all of them and CI blocks a missing or inconsistent key.
2. **Why does the UI kit use the code colors and not the mockup colors?** The colors check fails on any color outside `AppColors`. Changing the tokens is a decision for Manar, not part of the kit.
3. **Why does React Native start in Arabic when the phone language is not English, French or Arabic?** Flutter does the same, and the test plan (LNG-01) expects the same behavior in both apps.
