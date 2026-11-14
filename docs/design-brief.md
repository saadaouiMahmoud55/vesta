# Vesta design brief (VST-106)

One page. This replaces the Figma pages. Figma only gave the color palette; the screens come from `docs/design/vesta-screens.pdf`. If this brief and the code disagree, the code in `AppColors` / `theme.ts` wins for colors, and we fix the brief.

## 1. Rules for every screen

1. Never write a color, text or size directly in a screen. Use a token or a shared UI kit widget.
2. Same screen, same look in Flutter and React Native. Flutter is the reference; React Native mirrors it with the same component names.
3. Three languages: Tunisian Arabic (RTL), French, English. Every text comes from the translation files.
4. Prices in TND, with the unit: `240 TND / nuit`. Phone numbers stay left-to-right, also in Arabic.
5. Check before each PR: `node tools/check-colors.js`, and add before/after screenshots.

## 2. Colors (tokens)

| Token | Hex | Used for |
|---|---|---|
| primary | `#176AAB` | buttons, prices, selected chips, active tab, links, own chat bubbles, map pin |
| navy | `#20394A` | app bar text and titles |
| grey | `#6B777B` | secondary text, hints, placeholders |
| white | `#FFFFFF` | cards, inputs, bottom bar, received chat bubbles |
| border | `#E5E5DF` | input and card outlines, dividers |
| background | `#FAF8F4` | screen background |
| sand | `#F0E7DA` | segmented controls, date separators, input of the chat |
| terracotta | `#A65D42` | secondary accent (avatars, small highlights) |
| error | `#A33B32` | error text, red outlines, "Se déconnecter" |

Light tints of primary (about 15%) are used for the selected tab and for photo placeholders.

## 3. Typography

- Font: the system font (Roboto on Android). Arabic uses the system Arabic font.
- Screen title: centered in the app bar, regular weight, navy.
- Card title: bold, one line, ellipsis if long.
- Secondary line: grey, small ("Sidi Bou Saïd · 3 chambres").
- Price: bold, primary color, with "/ nuit" (or "/ mois", "/ an") in regular grey.
- Field label: small, grey, above the field.

## 4. Shape and spacing (approximate, measured on the mockups)

- Screen side margin: 16 px. Space between cards: 12 px.
- Card: white, radius about 16 px, no strong shadow.
- Input: white, border 1 px, radius 10 px (`AppRadius.field`); focused border in primary.
- Primary button: full width, filled primary, white text, fully rounded ("pill"), height 52 px (`minimumSize` in the theme).
- Chips and segmented controls: fully rounded; selected = filled primary with white text, unselected = white with border.
- Bottom bar: 5 tabs (Explorer, Recherche, Carte, Favoris, Profil), white, selected tab has a light primary pill.
- App bar: background color, title centered, chat and bell icons on the right on the main tabs.

## 5. Components (shared UI kit, same names in both apps)

`PriceText`, `OfferTypeBadge`, `KeyFactsRow`, `ListingCard` (photo, title, city + rooms, price, heart), buttons (filled, text), chips, status chip, empty state, error state, loading state.

- **Empty state:** round light-primary icon, bold title, one grey sentence, one filled button ("Explorer les annonces", "Réinitialiser les filtres").
- **Error and validation:** red outline, red message under the field, a red banner at the top of the form ("Corrigez les 3 champs en rouge pour publier.").
- **Photo placeholder:** light primary tint with the Vesta door icon.

## 6. Reference screens (see the PDF)

Favorites (list and empty), Profile (language switch, My listings, edit profile), Publish a listing (normal, errors, Arabic), Search (results, filter badge, empty), Filters sheet (French and Arabic), Map (price pins, selected pin, preview card, OpenStreetMap attribution), Messages list, Chat (French and Arabic), notification banner, Explore ("Bientôt disponible").

## 7. Arabic (RTL) checklist

- The layout flips: back arrow, icons, lists and chips mirror.
- Text is right-aligned; numbers and phone numbers stay left-to-right.
- Nothing cut off in long Arabic labels; check on a real phone.

## 8. Not decided yet

- Dark mode: not planned.
- Final logo (academic use only for now).
