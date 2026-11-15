# React Native UI kit

Twins of the Flutter UI kit (`docs/ui-kit.md`). They only draw: they read nothing from Firestore. Texts come from the existing keys (`offerSale`, `offerRent`, `offerStay`, `unitNight`, `unitMonth`, `unitYear`, `favoritesUnavailable`).

| Component | File | Use |
| --- | --- | --- |
| `PriceText` | `react-native-app/src/core/ui/PriceText.tsx` | Price with its unit (`TND 120 / night`). Always left-to-right. `period` is the `rentPeriod`; leave it null for a sale. |
| `OfferTypeBadge` | `react-native-app/src/core/ui/OfferTypeBadge.tsx` | Ribbon: stay = blue, rent = navy, sale = terracotta. `offerColor(type)` gives the color. |
| `ListingCard` | `react-native-app/src/core/ui/ListingCard.tsx` | Photo with ribbon, title, city, price. `topEnd` takes the heart. `unavailable` shows the grey veil. |
| `KeyFactsRow` | `react-native-app/src/core/ui/KeyFactsRow.tsx` | Row of facts (rooms, bathrooms, area, guests) as `{ icon, value }`. The screen provides the icon (no icon library). Values read left-to-right in Arabic. |
| `FilterTag` | `react-native-app/src/core/ui/FilterTag.tsx` | Pill chip for filters and choices: white when off, primary when on. Takes a `labelKey`. |
| `rtlHelpers` | `react-native-app/src/core/ui/rtlHelpers.tsx` | `isRtl()`, `DirectionalIcon` (flips its child in Arabic), `LtrText` (prices, phones, areas). Same names as `rtl_helpers.dart`. |

`offerTypeOf(listing)` (`src/data/models/offerType.ts`) decides sale, rent or stay: sale = sale, rent by month or year = rent, rent by night = stay.

Radius tokens added to `theme.ts` with the Flutter names: `card`, `row`, `thumb`, `field`, `pill`.

Buttons and the loading, empty and error states already exist in `react-native-app/src/core/components` (`PrimaryButton`, `TextButton`, `LoadingView`, `EmptyView`, `ErrorView`). Not yet: the debug screen with screenshots in English, French and Arabic (part 3). The spacing scale of `theme.ts` (`md` 16, `lg` 24) differs from Flutter's `AppSpacing` (`md` 12, `lg` 16): changing it would move the existing screens, so it is a decision for Manar.
