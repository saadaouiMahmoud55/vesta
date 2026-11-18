# Store screenshots (Flutter app)
Screenshots of the Flutter app for the Play Store listing and the project report.

## How they were made
- Taken by Ahmed Bouguerra on 18 Nov 2026.
- Flutter app running on Chrome (`flutter run -d chrome`), device toolbar about 360x780. Image size is 356-362 x 777-782 px.
- Data: the "Demo" listings (for example "Demo - Appartement S+3, La marsa", TND 520,000). The test listings are not used.
- Prices in TND.

## Files

| Screen | EN | FR | AR |
|---|---|---|---|
| 01 Login | 01-login-en.png | 01-login-fr.png | 01-login-ar.png |
| 02 Search | 02-search-en.png | 02-search-fr.png | 02-search-ar.png |
| 03 Listing details (top) | 03-details-en.png | 03-details-fr.png | 03-details-ar.png |
| 03 Listing details (scrolled) | 03-details-en-2.png | 03-details-fr-2.png | 03-details-ar-2.png |
| 04 Map | 04-map-en.png | 04-map-fr.png | 04-map-ar.png |

## Known points
- The description of the Demo listings still has extra spaces before some commas (Firestore data, not part of this fix).
- The contact sign-in button is now in standard Arabic. Other Arabic texts still use Tunisian Darija (the word "باش"), for example some subtitles and hints. Known limit.
