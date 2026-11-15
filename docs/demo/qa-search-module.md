# Q&A cheat sheet: the search and filters module (VST-122)

Module: Flutter search and filters, written by Eya (VST-40). Files in `flutter-app/lib/features/search/`: `search_filters.dart` (the filter logic), `search_filters_notifier.dart` (state and reading), `search_filters_sheet.dart` (the filter panel), `search_screen.dart` (the screen). Reads listings through `ListingRepository.getLatestListings` in `flutter-app/lib/features/listings/listing_repository.dart`. Tests: the search tests in `flutter-app/test/`.

## The 30-second explanation

The Search tab reads the 100 newest listings once, then filters them inside the app. The filters are a city or title text, a price range, an offer type (sale, rent, stay) and a property type. The text waits 400 ms after the last key before filtering. Sold, rented, unavailable and hidden listings are not offered. Filtering is pure Dart logic with no Firebase in it, so it is easy to test.

## How it is built

- **`SearchFilters`** (`search_filters.dart`): plain data and logic. `matches(listing)` checks each filter, `apply(listings)` keeps the order (newest first) and removes unavailable listings, `activeCount` gives the number for the badge on the filter button.
- **`SearchFiltersNotifier`** (`search_filters_notifier.dart`): Riverpod notifier that holds the filters. `setCity` uses a 400 ms timer so only the last keystroke counts. When the signed-in user changes, the filters start again empty.
- **`searchableListingsProvider`**: reads the 100 newest listings once; `searchResultsProvider` applies the filters on that list and passes loading and error states to the screen.
- **Screen and sheet**: only show the state and call the notifier.

## Likely questions and short answers

1. **Why filter in the app and not in Firestore?**
   Firestore needs one composite index for each combination of filters, and a price range forces the first sort on `price`, so "newest first" would be lost. Reading the 100 newest listings (no index needed) and filtering them in memory is simple and fast at our size. The code comment says it: if the app grows to thousands of listings, move the main filters into the query.

2. **What is the limit of that choice?**
   Only the 100 newest listings are searchable. An older listing does not appear in the search, although it is still in the app. This is in the report as a known limit and as future work (server-side search with pagination).

3. **Why wait 400 ms after typing?**
   To avoid filtering on every key and to keep the screen smooth. Only the last keystroke counts (`Timer` in `setCity`, cancelled on each new key and on dispose).

4. **How does the city search work with accents and Arabic?**
   `normalizeSearchText` lowers the case, removes accents (so "gabes" finds "Gabès") and trims spaces. Arabic is kept as typed, since it has no case or accents. The text matches the city or the title of the listing.

5. **What is the difference between "rent" and "stay"?**
   The filter uses `offerTypeOf(listing)`, never `listingType` alone: a rent per night is a stay, a rent per month or year is a rent, and a sale is a sale. This is the same rule as the badges and the status choices (`docs/offer-types.md`).

6. **Why do sold or hidden listings not appear?**
   `apply` removes any listing that is unavailable. They still show in the favorites (with a banner), but the search should not offer something nobody can rent or buy. Reserved listings stay visible: PR #106 documents that choice.

7. **What happens when the user logs out or in?**
   The provider watches the user id: the list is read again and the filters are reset, so a new user never sees the filters of the previous one.

8. **How are loading and errors shown?**
   The results provider passes the loading and error state of the read to the screen, with a retry. A failed read does not show a blank screen.

9. **How is it tested?**
   `SearchFilters` has no Firebase, so unit tests cover each filter, the accents, the empty state and the order. Eya also tested on a real Redmi phone in Arabic.

10. **What would you improve with more time?**
    Server-side filters and pagination, sort options (price, distance) and saving a search.

## Honest limits (say them before they are asked)

- Only the newest 100 listings are searched.
- No sort choice: newest first only.
- No search by distance from the user.
- The React Native search (VST-41, PR #105) is a separate version for the reduced RN app.

## If you do not know the answer

Say: "That part is in `search_filters.dart`, I can show you the exact lines." Then open the file. Do not guess.
