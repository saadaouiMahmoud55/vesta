# Vesta offer types: sale, rent, stay (spec, VST-100)

Vesta is an app to **buy, rent, sell and stay** in Tunisia: houses, apartments, villas, riads, guest houses, Airbnbs, land and commercial places. This page is the single reference for the product behaviour in **both apps** (Flutter for Google Play, React Native for the academic demo). The data model (`docs/data-model.md`) and the rules (`firebase/firestore.rules`) are changed from this page in VST-74.

## 1. The three offer types

The Firestore fields already exist and **do not change**: `listingType` (`sale` | `rent`) and `rentPeriod` (`night` | `month` | `year`, required when rent). The three offer types are a **product view** on those two fields. No `offerType` field is stored.

| Offer type | Stored as | Price shown as | Who | Main contact |
|---|---|---|---|---|
| **Sale** | `listingType = sale` | `TND 120,000` | Seller to buyer | Chat, call, WhatsApp, visit request (S3) |
| **Rent** | `listingType = rent` and `rentPeriod` = `month` or `year` | `TND 900 / month` | Landlord to tenant | Chat, call, WhatsApp, visit request (S3) |
| **Stay** | `listingType = rent` and `rentPeriod = night` | `TND 150 / night` | Host to guest | Chat, call, WhatsApp, booking request (S3) |

**Price format.** Prices follow `formatPrice` (`flutter-app/lib/core/config/app_config.dart`): currency first, comma as thousands separator, for example `TND 450,000`. The unit (`/ night`, `/ month`, `/ year`) is added after it. `formatPrice` is the reference for every screen, in both apps.

Both apps use one helper, `offerTypeOf(listing)`, that returns `sale`, `rent` or `stay` from those two fields. Nobody re-implements the rule inside a screen.

## 2. Property types

Existing values (do not rename): `apartment`, `house`, `villa`, `studio`, `riad`, `guest_house`.
**New values (rules change in VST-74):** `land`, `commercial` (shop or office).

| Offer type | Allowed property types |
|---|---|
| Stay | `guest_house`, `riad`, `apartment`, `villa`, `studio`, `house` |
| Rent | `apartment`, `house`, `villa`, `studio`, `riad`, `commercial` |
| Sale | all of them, including `land` and `commercial` |

## 3. Fields by offer type

R = required, O = optional, - = not used. Existing fields are in **bold**.

| Field | Sale | Rent | Stay | Note |
|---|---|---|---|---|
| **title, description, price, currency, city** | R | R | R | description at least 40 characters; **price must be above 0** (the rules refuse 0 and negative prices) |
| **propertyType** | R | R | R | see section 2 |
| **latitude, longitude** | O | O | O | map shows only listings with coordinates |
| **areaSqm** | R | R | O | |
| **bedrooms, bathrooms** | R* | R* | O | *Required for apartment, house, villa, studio, riad and guest house. Not asked for `land`, optional for `commercial`. The publish form enforces it; the Firestore rules accept them as optional. |
| 1 to 10 photos | R | R | R | at least 1 |
| `contactPhone` (`+216XXXXXXXX`) | R | R | R | **stored in `listings/{id}/contact/info`**, readable by signed-in users only |
| `whatsappEnabled` (bool) | O | O | O | default false, same contact document |
| `status` | `available`, `reserved`, `sold`, `hidden` | `available`, `reserved`, `rented`, `hidden` | `available`, `unavailable`, `hidden` | default `available`: **the apps always write `status: 'available'` on create** (the rules accept a missing status, but search queries on `status == 'available'` do not return listings without the field) |
| `negotiable` (bool) | O | - | - | |
| `yearBuilt` (number) | O | - | - | |
| `documentsNote` (string, max 200) | O | - | - | text only, no upload ("title deed available") |
| `furnished` (bool) | - | R | O | |
| `depositMonths` (number) | - | O | - | |
| `availableFrom` (date) | - | O | - | |
| `minMonths` (number) | - | O | - | |
| `maxGuests`, `beds` (numbers) | - | - | R | |
| `amenities` (array of keys) | - | O | O | `wifi`, `ac`, `heating`, `kitchen`, `parking`, `pool`, `breakfast`, `washing_machine`, `tv`, `garden` |
| `checkIn`, `checkOut` (text `HH:mm`) | - | - | O | |
| `houseRules` (array of keys) | - | - | O | `no_smoking`, `no_pets`, `no_parties`, `quiet_hours` |
| `minNights` (number) | - | - | O | default 1 |
| `viewCount` (number) | O | O | O | dashboard, Sprint 3, +1 per user per day. **Not possible with the current rules:** only the owner can write the listing, so counting views from other users needs another mechanism, decided in Sprint 3. |
| `verified` (bool) | O | O | O | set only by Manar in the console, "Verified" badge |

**Phone format.** `+216` followed by 8 digits, and the first digit must be 2, 3, 4, 5, 7 or 9 (pattern `^\+216[234579][0-9]{7}$`). The rules refuse any other number, for example one starting with 1, so the forms apply the same check.

The phone is **not** in the listing document. Listings are readable by guests (no account needed, VST-72), so a phone inside would be public. It is stored in `listings/{id}/contact/info`, which only signed-in users can read (decided in VST-74). The number is prefilled from the profile when publishing and the owner can change it per listing. The app writes the listing and its contact in one batch, and reads the contact only when a signed-in user opens the details screen.

**Who enforces what.** The Firestore rules (VST-74) check only the **types** of the new fields, the allowed `status` values per offer type, the phone format, and that `land` and `commercial` are never offered per night. Every new field is optional in the rules, so listings published before v4 stay valid. The **required fields (R) and the property-type table of section 2 are enforced by the apps** in the publish form (for example description of at least 40 characters, area, guests and beds for a stay). Both apps must apply the same checks.

## 4. Behaviour rules (both apps)

1. **Publish:** the first step is "What do you want to do?" with three choices: Sell / Rent out / Offer a stay. The next fields depend on the choice. Changing the choice clears the fields that no longer apply.
2. **Cards:** photo, title, city, price with its unit, ribbon with the offer type.
3. **Search:** three tabs **Buy / Rent / Stay** are the first filter. Price slider unit follows the tab. Only `status = available` listings appear in search, map and home.
4. **Map:** pins use the offer type color. Tap shows a mini card.
5. **Details:** the "key facts" row depends on the type (section 3). Contact buttons sit under the price.
6. **Statuses:** the owner changes the status in "My listings". `sold` and `rented` stay visible to people who favorited or chatted about the listing, with a ribbon, and disappear from search.
7. **Booking (stay) and visit request (sale, rent):** Sprint 3 (VST-92).
8. **Guests** can browse, search and read details. Favorite, chat, contact numbers, publish and requests ask to sign in and come back to the same screen.
9. **Every user can publish.** There is no buyer/owner role.
10. **Home:** three entry tiles **Buy / Rent / Stay** (same labels and offer colors as section 5). Tapping a tile opens Search on that tab. The tiles are built in the Explore home ticket (Sprint 3).

## 5. Colors (Figma theme only)

| Offer type | Color | Hex |
|---|---|---|
| Stay | primary blue | `#176AAB` |
| Rent | navy | `#20394A` |
| Sale | terracotta | `#A65D42` |

Ribbons use the color as background with cream text (`#FAF8F4`). No other color is added.

## 6. Labels (first version, the glossary ticket VST-77 validates the final wording)

| Key | English | Français | العربية (تونسي) |
|---|---|---|---|
| `offer.sale` | For sale | À vendre | للبيع |
| `offer.rent` | For rent | À louer | للكراء |
| `offer.stay` | Stay | Séjour | إقامة |
| `tab.buy` | Buy | Acheter | شراء |
| `tab.rent` | Rent | Louer | كراء |
| `tab.stay` | Stay | Séjourner | إقامة |
| `unit.night` | / night | / nuit | / ليلة |
| `unit.month` | / month | / mois | / شهر |
| `unit.year` | / year | / an | / سنة |
| `status.sold` | Sold | Vendu | مباع |
| `status.rented` | Rented | Loué | مكري |
| `status.reserved` | Reserved | Réservé | محجوز |
| `field.furnished` | Furnished | Meublé | مفروش |
| `field.negotiable` | Negotiable | Négociable | قابل للتفاوض |

Numbers and `TND` stay left-to-right inside Arabic sentences; `formatPrice` is the only function that formats a price.

## 7. What each ticket does with this page

| Ticket | Uses |
|---|---|
| VST-74 data model + rules | sections 2, 3 (new fields, new property types, status values per type, phone format) |
| VST-93 UI kit | section 5 colors, `OfferTypeBadge`, `PriceText`, `KeyFactsRow` |
| VST-73, VST-81 | sections 3 and 4 (publish, cards, details) |
| VST-40 | section 4.3 (tabs and filters) |
| VST-42 | section 4.4 and 5 (pins) |
| VST-96 | section 3 `status` per type |
| VST-79 | contact rules |
| VST-77, VST-70 | section 6 labels |
| VST-92 (S3) | booking for stay, visit request for sale and rent |
