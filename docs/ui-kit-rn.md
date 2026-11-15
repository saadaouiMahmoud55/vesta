# React Native UI kit

Twins of the Flutter UI kit (`docs/ui-kit.md`). They only draw: they read nothing from Firestore. Texts come from the existing keys (`offerSale`, `offerRent`, `offerStay`, `unitNight`, `unitMonth`, `unitYear`, `favoritesUnavailable`).

| Component | File | Use |
| --- | --- | --- |
| `PriceText` | `react-native-app/src/core/ui/PriceText.tsx` | Price with its unit (`TND 120 / night`). Always left-to-right. `period` is the `rentPeriod`; leave it null for a sale. |
| `OfferTypeBadge` | `react-native-app/src/core/ui/OfferTypeBadge.tsx` | Ribbon: stay = blue, rent = navy, sale = terracotta. `offerColor(type)` gives the color. |
| `ListingCard` | `react-native-app/src/core/ui/ListingCard.tsx` | Photo with ribbon, title, city, price. `topEnd` takes the heart. `unavailable` shows the grey veil. |

`offerTypeOf(listing)` (`src/data/models/offerType.ts`) decides sale, rent or stay: sale = sale, rent by month or year = rent, rent by night = stay.

Radius tokens added to `theme.ts` with the Flutter names: `card`, `row`, `thumb`, `field`, `pill`.

Not in this first PR: key facts row, buttons, chips, loading/empty/error states, RTL helpers, debug screen. The spacing scale of `theme.ts` (`md` 16, `lg` 24) differs from Flutter's `AppSpacing` (`md` 12, `lg` 16): changing it would move the existing screens, so it is a decision for Manar.
