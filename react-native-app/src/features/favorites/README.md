# Favorites

`useFavorites()` in `favoritesController.ts` provides the live saved-listing ids and optimistic heart toggles. Each component using the hook owns a Firestore listener; there is no favorites provider. The hook uses the existing auth context and calls `favoritesRepository`, the only module that accesses the `favorites` collection. Screens never access Firebase directly.

`FavoritesScreen` combines that listener with `useFavoriteListings()` to load the associated listing documents through `listingsRepository`. The repository reads each id separately so one hidden/deleted listing does not fail the whole list. Successful listing reads are cached for the lifetime of the screen; the selected category uses `categoryOf()` from `src/data/models/listingCategory.ts`.

The authenticated main stack exposes Favorites from Home. Guest browsing is not yet available in the app root, so the signed-out state in `FavoritesScreen` is ready for when it is.
