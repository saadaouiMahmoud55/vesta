# Map

Map screen of the React Native app (VST-43). It shows every available listing on OpenStreetMap, with Tunisian city search and a "My location" button.

- `MapScreen.tsx`: the screen. Calls `useMapPins` and `findMe`, never Firebase.
- `useMapPins.ts`: controller. Reads the newest listings and turns them into pins.
- `mapPins.ts`: pin rules, same as `pinsFor` in the Flutter app (exact pin if the owner placed one, otherwise the city center, spread on a small spiral).
- `tunisiaPlaces.ts`: the Tunisian places used for city search and city-center pins.
- `locationService.ts`: finds the user once. Never throws, the map works without it.

Repositories in `src/data/` access Firebase.
