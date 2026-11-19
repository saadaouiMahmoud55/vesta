# Flutter UI kit (VST-93)

Shared building blocks of the Flutter app. A screen uses these widgets and tokens instead of writing its own colors, sizes or texts.

**Rules**

- Colors only from `lib/core/theme/app_colors.dart`. No hex color in a screen (`node tools/check-colors.js`).
- Spacing, radius and text sizes only from `app_dimens.dart` and `app_text_styles.dart` (both measured on the mockups VST-66 and VST-67).
- Every text comes from a translation key (`lib/l10n/*.arb`: English, French, Tunisian Arabic).
- A price is always shown with `PriceText` (it calls `formatPrice`).
- To see every widget: the screen is the route `/ui-kit` (`AppRoutes.uiKit`). It has no menu entry any more (testers did not understand it in Settings). To open it, temporarily add `context.push(AppRoutes.uiKit)` to a button in a debug build.

## Tokens (`lib/core/theme`)

| File | Content |
|---|---|
| `app_colors.dart` | `AppColors`: all brand colors |
| `app_dimens.dart` | `AppSpacing` (xs 4, sm 8, md 12, lg 16, xl 24, xxl 32) and `AppRadius` (card 16, row 14, thumb 12, field 10, pill) |
| `app_text_styles.dart` | `AppTextStyles`: title 20, subtitle 16, body 15, bodySmall 14, caption 13, small 12, tiny 11 (no color) |
| `app_theme.dart` | Material theme: pill buttons (filled and outlined), 52 dp high |

## Widgets (`lib/core/widgets`)

| Widget | File | When to use it |
|---|---|---|
| `PrimaryButton` | `app_button.dart` | The main action of a screen (Publish, Save, Log in). Has a `loading` state. |
| `SecondaryButton` | `app_button.dart` | A second action next to the primary one (Cancel, Choose on the map). |
| `AppTextField` | `app_text_field.dart` | Every text input. Pass `errorText` to show the error below. Use `ltr: true` for phone numbers and prices. |
| `FilterTag` | `filter_tag.dart` | Pill to choose a filter or a value (property type, period, tab filter). |
| `AppTopBar` | `app_top_bar.dart` | App bar of a screen outside the tabs. The back arrow flips in Arabic. |
| `showAppBottomSheet` | `app_bottom_sheet.dart` | Any bottom sheet (sign-in sheet, filters, choices). |
| `AppAvatar` | `app_avatar.dart` | Profile picture (photo, else initials, else icon). |
| `LoadingView` | `app_states.dart` | A list or a screen that is loading. |
| `EmptyState` | `app_states.dart` | A list with no item (icon, one sentence, optional action). |
| `ErrorState` | `app_states.dart` | A load error: message and a translated Retry button. |
| `OfflineBanner` | `app_states.dart` | Thin banner when the network is down. The screen decides when to show it. |
| `OfferTypeBadge` | `offer_type_badge.dart` | The ribbon with the offer type: stay blue, rent navy, sale terracotta. `OfferTypeBadge.colorOf(type)` gives the color (map pins). |
| `PriceText` | `price_text.dart` | Every price: `TND 650,000`, `TND 1,200 / month`, `TND 120 / night`. Left-to-right also in Arabic. |
| `KeyFactsRow` | `key_facts_row.dart` | Icon and value facts (rooms, bathrooms, area). `keyFactsOf(listing)` builds them from a listing. |
| `ListingCard` | `features/listings/listing_card.dart` | A listing in a list: photo, ribbon, heart, title, city, key facts, price. |
| `DirectionalIcon`, `LtrText`, `isRtl` | `rtl_helpers.dart` | Icons that flip in Arabic (back arrow, chevrons); phone numbers and prices that stay left-to-right. |

## Screenshots (real phone)

Debug build on a real phone, screen **UI kit**.

| Arabic (right-to-left) | Français |
|---|---|
| ![UI kit in Arabic](ui-kit/ar-1.png) | ![UI kit in French](ui-kit/fr-1.png) |

## Not in this kit

- No internet detection: `OfflineBanner` only draws the banner (a connectivity package is not in the project).
- No skeleton loader: `LoadingView` is a spinner.
