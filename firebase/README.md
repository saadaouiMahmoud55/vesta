# Firebase

One Firebase project shared by both apps (Authentication and Firestore). Rules are tested with the Firebase emulator.
Never commit service-account keys or the app config files.

## Firestore security rules (VST-33)

Rules for data model v4 (`docs/data-model.md`) are in `firestore.rules` (v4 = VST-74: offer types, statuses, listing contact, guest reading).
`storage.rules` is no longer used since the decision of 8 Oct (photos are stored in Firestore).

### Run the emulator and the tests
1. Start the emulator: `cd firebase` then `firebase emulators:start --project demo-vesta`
   (Auth 9099, Firestore 8085, UI 4000)
2. In another terminal: `cd firebase/tests`, `npm install` (first time only), then `npm test`

Never run `firebase deploy` or `firebase login`. The project id `demo-vesta` keeps everything local.
The Emulator UI ignores the rules when you write data by hand: use the tests to check refusals.

### What the tests cover (`rules.test.js` and `auth.test.js`, run `npm test` for the exact count)
Listings (3-letter currency, rentPeriod only for rent, propertyType list, photoCount 0 to 10), photos (ids p0 to p9, any free id, owner only, size limit, batch with the listing), private contact, favorites, **v4 (VST-74):** guest reading of listings and photos, statuses per offer type (sale, rent, stay), `land` and `commercial` (never by the night), `verified` only from the console, typed optional fields (amenities, house rules, check-in times, dates, numbers), and the protected contact document `listings/{id}/contact/info` (Tunisian phone `+216`, signed-in readers only). Conversations (id `{listingId}_{buyerId}`, other participant = listing owner, participantIds and listingId immutable), messages (no edit or delete).

### Auth and users tests (VST-34)
`tests/auth.test.js` (24 tests) covers the sign-in and `users` rules: a signed-out user can do nothing, a signed-in user can read public profiles, sign-up creates only `users/{uid}` and `users/{uid}/private/contact` for the user's own uid, nobody can update or delete another user's data, `displayName` and `photoBase64` are validated, and any collection not described in the data model is refused.
`npm test` runs both test files one after the other (same emulator, same project id).

### Known limits
- Rules check that photoCount is between 0 and 10, not that it equals the real number of photos.
- Deleting a listing without deleting its photos in the same batch leaves orphan photos (the app must delete them).
- The photo size limit is 280000 characters (about 200 KB once encoded in base64).
- `firestore.indexes.json` holds the 8 indexes used by the queries. Deploy them with `firebase deploy --only firestore:indexes` (Manar only).
- A listing without `status` is valid for the rules but is not returned by `where status == 'available'`: the apps always write the status, old test listings get it once by hand.
- The phone number document `listings/{id}/contact/info` is readable by any signed-in account, including an anonymous Firebase account (see `docs/report/limits-and-future-work.md`).
- There are no rules yet for `bookings` and `blockedNights` (booking is not merged).

## Photo contract for the app (VST-35)

Photos of a listing live in `listings/{listingId}/photos/{photoId}`.

- `photoId` must be `p0` to `p9`. This enforces the maximum of 10 photos per listing. The id gives the display order (`p0` first). After a delete, a free id can be reused: the new photo then takes the position of that id.
- Fields: `base64` (a string of 1 to 280000 characters, without the `data:image/...` prefix) and `createdAt`. No other field is accepted.
- Compress on the phone before upload: about 800 px wide, JPEG, under 200 KB (about 273000 base64 characters).
- Adding or deleting a photo and updating `photoCount` on the listing must be done in the same batch.
- Deleting a listing: delete its photos in the same batch, otherwise they stay orphaned and nobody can delete them afterwards.
- Only the owner of the listing writes photos. Any signed-in user can read them.

## Android API key restriction (VST-101)

The Android key created by Firebase ("Android key (auto created by Firebase)", project `vesta-d1048`, Google Cloud Console > APIs & Services > Credentials) can be restricted to our apps. A build whose package name and signing SHA-1 are not in the list is blocked at sign-in ("Requests from this Android client application are blocked").

Application restrictions > Android apps, 4 rows:

| Package | Certificate | Used by |
|---|---|---|
| `com.vesta.flutterapp.debug` | developer debug key | `flutter run` (the debug build has the `.debug` suffix) |
| `com.vesta.flutterapp` | developer debug key | `flutter run --release` |
| `com.vesta.flutterapp` | upload key | release builds signed by the developer |
| `com.vesta.flutterapp` | Play App Signing key (Play Console > App integrity) | the app installed from Google Play |

The SHA-1 values are public fingerprints, not secrets, and are kept in the Cloud Console. Never commit a keystore, its password or `key.properties`.

- Get the debug SHA-1 of a machine: `cd flutter-app/android` then `.\gradlew signingReport` (Windows) or `./gradlew signingReport`, line `SHA1` of the `debug` variant. Each developer who runs the app needs their own row with the `.debug` package.
- A change takes about 5 minutes to apply.
- Test after any change: sign in on the debug build and on the Play install.
- If sign-in fails and the demo is close: set Application restrictions to None (instant), then fix the rows.

**Decision (21 Nov 2026, VST-138):** the key stays on Application restrictions = **None** for the delivery. A missing SHA-1 row blocks sign-in for every user of that build, and a Firebase API key is not a secret: data is protected by Auth and the Firestore rules. Known risk: another app can use the key and consume the free quota. The 4-row restriction above is the future-work option.
