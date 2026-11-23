# Search (VST-41)

Search with filters, same behavior as the Flutter app. The screen reads the newest listings once, then filters them in memory.

`SearchScreen` / `SearchFiltersSheet` → `searchController.ts` (`useSearchController`) → `listingsRepository` → Firestore. A screen never calls Firebase.

- `searchFilters.ts`: the `SearchFilters` type (min and max price, city, offer type, property type), `applyFilters`, text normalization (lower case, no accents) and the constants `SEARCH_LIST_LIMIT` (100 newest listings) and `SEARCH_DEBOUNCE_MS` (400 ms after the last keystroke).
- `searchController.ts`: loads the listings, keeps the filters, exposes the result list, the active filter count, loading and error states.
- `SearchFiltersSheet.tsx`: the filter sheet. Offer type uses the shared rule buy / rent / stay (a stay, rent per night, is not a rent).

Known limits: only the 100 newest listings are searched (no server-side filtering or pagination), and the city filter compares the text as stored, so an Arabic spelling does not match a city stored in Latin letters (VST-139). See `docs/report/limits-and-future-work.md`.
