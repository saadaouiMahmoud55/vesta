# Handover: Eya (VST-112)

Flutter: listings, search, publish form, My listings and account deletion. Everything below is in `develop` unless it says "not done".

## Tickets done
- **Listing details and list (VST-73, PR #47 and #56):** details screen, the Explore list opens it, price unit from `offerTypeOf`, banner for an unavailable listing.
- **Search and filters (VST-40, PR #57):** city text (400 ms wait), price min and max, offer type, property type, newest first.
- **Amenities and details v4 (VST-81, PR #61 and #62):** publish form with guests, amenities, check-in and check-out, house rules. The details screen shows the same blocks.
- **Delete account (VST-84, PR #63):** dialog in Settings, password asked again, data deleted in a safe order. Report, block and the privacy page are not done.
- **My listings status (VST-96, PR #67):** status chip and bottom sheet by offer type. Part 2 (colored ribbons, favorite count) is not done.
- **Real content (VST-83):** in progress. A listing is published only after the owner's written consent.
- **Reviews:** #54 (translations), #68, #69, #73 and #75 (design and handover docs), #72 (search filters reset).

## Screens
Explore list, Search with the filter sheet, Listing details, Publish form, Profile > My listings, Settings > Delete my account.

## Main files and folders
| Area | Where |
|---|---|
| Search | `flutter-app/lib/features/search/` (`search_filters.dart` holds the filter logic) |
| Listings | `flutter-app/lib/features/listings/` (`listing.dart`, `listing_repository.dart`, `listing_detail_screen.dart`, `publish_listing_screen.dart`) |
| My listings status | `flutter-app/lib/features/profile/listing_status_sheet.dart` |
| Delete account | `flutter-app/lib/features/auth/delete_account_dialog.dart`, `deleteAccount` in `flutter-app/lib/features/auth/auth_repository.dart`, `docs/delete-account.html` |
| Tests | `flutter-app/test/` (`search_filters_test.dart`, `listing_detail_amenities_test.dart`, `listing_status_test.dart`, `delete_account_dialog_test.dart`) |

## Data I use
- **Listings:** `listings`, with photos in `listings/{id}/photos` (ids p0 to p4, base64) and the phone in `listings/{id}/contact/info`. Fields and rules: `docs/data-model.md`, `docs/offer-types.md`.
- **Status:** the app writes `available` at creation. A missing status counts as available. Sold, rented, unavailable and hidden listings are skipped by search.
- **Search:** no Firestore filter. The app reads the newest 100 listings and filters them in memory.
- **Favorites:** `favorites/{uid}_{listingId}`, deleted with the account.
- **Content sources:** each real listing needs the owner's written consent (kept in a private folder, never in the repo) and photos from the owner or taken by us. Never copied from Airbnb, Booking, Facebook or Google.

## How to test
```
cd flutter-app
flutter pub get
flutter gen-l10n
flutter analyze --no-pub
flutter test --no-pub
```
On a phone, `flutter run` installs "Vesta Debug" next to the Play build:
1. Explore: tap a card, the details open, back works.
2. Search: type a city, use the filters, reset. An empty result shows a message.
3. Publish (signed in): fill the fields, add up to 5 photos.
4. Profile > My listings: tap the chip, change the status, then check Search.
5. Settings > Delete my account: open the dialog and cancel. Use a throwaway account to go to the end.
6. Switch to Arabic and check the layout.

## Known limits
- Search reads only the newest 100 listings.
- A hidden listing can still be opened by its direct link (rules not changed yet).
- Favorite count, colored status ribbons and the "reserved" ribbon: not done.
- Delete account keeps the chat messages for the other person. Report and block users, and the privacy page: not done.
- The publish form still shows guests, check-in and house rules for a sale (kept for the MVP) and has no location picker.
- HEIC and very large photos were not tested.

## 3 questions a teammate could ask
1. **Why is search filtered in the app and not in Firestore?** A price range forces the first sort on `price`, so "newest first" is lost, and every filter combination would need an index that Manar deploys. With a small list it is simpler and works for listings without a status field.
2. **What does delete account remove, and in which order?** Photos, contact and listings in one batch per listing, then favorites, then the profile, and the Auth user last, because once it is gone the rules refuse every other delete. Retry is safe.
3. **Why does a listing without a status field still show?** The rules and the app read a missing status as available, and the app always writes `available` when it creates one. A query with `status == 'available'` would miss it, so the filtering is done in the app.