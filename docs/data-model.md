# Vesta Firestore data model (v4)

Single reference for the Firestore collections used by both apps (Flutter and React Native).
Prices are stored as a number with a currency code. The currency code is read from the app config (TND) and is never hardcoded in the apps or in the rules.

**v4 (VST-74, 27 Oct):** adds the fields of the three offer types (sale, rent, stay, see `docs/offer-types.md`), the `status` of a listing, two new property types (`land`, `commercial`), the listing contact in its own protected document, and public reading of listings for guest browsing (VST-72). **Every new field is optional**, so listings published before v4 stay valid and editable.

| Collection | Document id | Fields (type) | Rules summary |
|---|---|---|---|
| `users` | Auth `uid` | `displayName` (string), `photoBase64` (string, optional, compressed, under 200 KB), `createdAt` (server timestamp) | Create/update/delete: the user only. Read: any signed-in user (public profile, shown in listings and chat). |
| `users/{uid}/private/contact` | `contact` | `email` (string), `phone` (string, optional) | Read/write: the user only. |
| `listings` | auto-id | `ownerId` (string), `title` (string), `description` (string), `price` (number, above 0), `currency` (string of 3 letters, from the app config, TND), `rentPeriod` (`"night"`, `"month"` or `"year"`, required only when `listingType` is `"rent"`), `listingType` (`"sale"` or `"rent"`), `propertyType` (string, see values below), `city` (string), `latitude` (number, optional), `longitude` (number, optional), `bedrooms` (number, optional), `bathrooms` (number, optional), `areaSqm` (number, optional, square meters), `photoCount` (int 0 to 10, kept in sync with the photos, see decisions), `createdAt` (server timestamp), `updatedAt` (server timestamp). **New in v4, all optional:** `status` (see below), `negotiable` (bool), `yearBuilt` (number, 1800 or more), `documentsNote` (string, max 200), `furnished` (bool), `depositMonths` (number, 0 or more), `availableFrom` (timestamp), `minMonths` (number, 1 or more), `maxGuests` (number, 1 or more), `beds` (number, 0 or more), `amenities` (list, max 10 keys), `checkIn` and `checkOut` (string `HH:mm`), `houseRules` (list, max 4 keys), `minNights` (number, 1 or more), `viewCount` (number, 0 or more), `verified` (bool) | **Read: anyone, signed in or not** (guest browsing, VST-72). Create: signed-in user with `ownerId == uid`, `verified` absent or false. Update: owner only; `ownerId`, `createdAt` and `verified` cannot change. Delete: owner only. Optional fields must have the right type when present. |
| `listings/{id}/photos` | fixed ids `p0` to `p9` | `base64` (string, compressed, under 200 KB), `createdAt` (server timestamp) | Read: anyone (guest browsing). Create/update/delete: listing owner only. The 10 fixed ids enforce the maximum of 10 photos. The id gives the display order. Each add or delete is one batch write together with the `photoCount` update on the listing. |
| `listings/{id}/contact` | fixed id `info` | `contactPhone` (string, `+216` then 8 digits, first digit 2, 3, 4, 5, 7 or 9), `whatsappEnabled` (bool, optional), `updatedAt` (timestamp, optional). No other field. | **Read: signed-in users only** (guests never get the number). Create/update/delete: listing owner only. |
| `favorites` | `{uid}_{listingId}` | `userId` (string), `listingId` (string), `createdAt` (server timestamp) | Read/create/delete: the user only. |
| `conversations` | `{listingId}_{buyerId}` | `participantIds` (array of exactly 2 uids), `listingId` (string), `lastMessage` (string), `lastMessageAt` (server timestamp), `unread` (map `uid -> number`, messages the user has not read yet; +1 for the other person at each send, reset to 0 when the user opens the chat) | Read/create/update: participants only. |
| `conversations/{id}/messages` | auto-id | `senderId` (string), `text` (string), `createdAt` (server timestamp) | Read: participants (rules read the parent conversation). Create: participant with `senderId == uid`. No edit or delete. |

## Offer types (product view, no stored field)

`sale` = `listingType` sale. `rent` = `listingType` rent with `rentPeriod` month or year. `stay` = `listingType` rent with `rentPeriod` night. Both apps use one helper `offerTypeOf(listing)`. Details: `docs/offer-types.md`.

## `propertyType` values (final list)

`apartment`, `house`, `villa`, `studio`, `riad`, `guest_house`, `land`, `commercial`

`land` and `commercial` are never rented by the night (refused by the rules). The same list is used everywhere: data model, rules, filters and mockups.

## `status` values

| Offer type | Allowed `status` |
|---|---|
| sale | `available`, `reserved`, `sold`, `hidden` |
| rent | `available`, `reserved`, `rented`, `hidden` |
| stay | `available`, `unavailable`, `hidden` |

A missing `status` means `available` for the **rules**. **Queries cannot do that**: `where status == 'available'` does not return documents without the field. So **the apps always write `status: 'available'` when creating a listing**, and listings created before v4 (test data) must get the field once by hand in the Firebase console. Only the owner changes `status`.

## Amenity and house-rule keys

`amenities`: `wifi`, `ac`, `heating`, `kitchen`, `parking`, `pool`, `breakfast`, `washing_machine`, `tv`, `garden`.
`houseRules`: `no_smoking`, `no_pets`, `no_parties`, `quiet_hours`.
The apps translate these keys (never store translated text).

## Decisions

- `messages` is a subcollection of `conversations` (simpler for realtime and rules).
- `currency` is a string of 3 letters filled from the app config (TND). The rules only check that it is 3 letters.
- Photos are stored as compressed base64 in `listings/{id}/photos` with fixed ids `p0` to `p9`, because rules cannot count documents (max 10, raised from 5 on 12 Nov). The field `order` is removed: the id gives the order.
- Search fields (`listingType`, `rentPeriod`, `propertyType`, `status`, `price`, `city`, `createdAt`) are top-level fields of `listings`.
- `latitude`, `longitude`, `bedrooms`, `bathrooms` and `areaSqm` are optional. The map only shows listings that have coordinates.
- A conversation id is `{listingId}_{buyerId}`, so there is one conversation per buyer and per listing. `participantIds` always holds exactly 2 uids.
- The user profile has a public part (`users/{uid}`: name and photo, readable by any signed-in user, so names and photos show in listings and chat) and a private part (`users/{uid}/private/contact`: email and phone, readable only by the user).
- **The phone number of a listing is not stored in the listing document.** Listings are readable by guests, so a phone inside would be public. It lives in `listings/{id}/contact/info`, readable only by signed-in users. The apps read it only when the details screen is opened by a signed-in user. At publish time the apps write the listing and the contact in **one batch**.
- `photoCount` stays in sync with the photos: adding or deleting a photo and updating `photoCount` on the listing are done in one batch write (one atomic write, never two separate ones).
- `verified` (the "Verified" badge) is set only from the Firebase console by Manar. The rules refuse any client that sets it to true or changes it.
- `viewCount` is for the owner dashboard (Sprint 3). Its rule only checks type and minimum for now; the "+1 per user per day" limit is added with the dashboard ticket (VST-98).
- Deleting a listing: the app deletes its photos and its `contact/info` in the same batch (otherwise they stay orphaned).
- `createdAt` and `updatedAt` are server timestamps.

## Indexes (`firebase/firestore.indexes.json`)

All are on collection `listings`, with `status` first because every public query filters on `status == 'available'`.

| Query | Index |
|---|---|
| Buy tab, sorted by price | `status`, `listingType`, `price` |
| Buy tab, newest first | `status`, `listingType`, `createdAt` (descending) |
| Rent or Stay tab (filter on `rentPeriod`), by price | `status`, `listingType`, `rentPeriod`, `price` |
| Rent or Stay tab, newest first | `status`, `listingType`, `rentPeriod`, `createdAt` (descending) |
| Property type filter | `status`, `propertyType`, `createdAt` (descending) |
| City filter, newest first | `status`, `city`, `createdAt` (descending) |
| City filter, by price | `status`, `city`, `price` |
| My listings | `ownerId`, `createdAt` (descending) |

The final list comes from the search queries (VST-40). Where Firestore cannot do a filter combination, the app filters the small remaining list on the phone.

## Class diagram

See `docs/c4/level4-classes.png` (source: `docs/c4/level4-classes.mmd`).
