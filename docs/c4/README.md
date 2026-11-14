# Vesta C4 diagrams

| Level | File | Content |
|---|---|---|
| 1 and 2 | `Vesta_C4_Niveau1_Contexte.pdf`, `Vesta_C4_Niveau2_Containers.pdf` (sources: `level1-context.mmd`, `level2-containers.mmd`) | Context and containers |
| 3 | `level3-auth-profile.png` (source: `level3-auth-profile.mmd`) | Auth and Profile components of the Flutter app (VST-27) |
| 3 | `level3-listings-favorites.png` (source: `level3-listings-favorites.mmd`) | Listings and Favorites components of the Flutter app (VST-28) |
| 3 | `level3-search-map-chat.png` (source: `level3-search-map-chat.mmd`) | Search, Map and Chat components of the Flutter app (VST-29) |
| 4 | `level4-classes.png` (source: `level4-classes.mmd`) | Data classes (see `docs/data-model.md`) |

Sources are Mermaid files. To redraw a PNG: `npx -p @mermaid-js/mermaid-cli mmdc -i level3-auth-profile.mmd -o level3-auth-profile.png -s 2 -b white`, or paste the `.mmd` file in https://mermaid.live and export the PNG.

## Level 3: Auth and Profile

How to read the diagram:

- The big dashed frame is the Flutter app. Screens are at the top, then controllers, then repositories. The Firebase services are outside the frame.
- Every box shows its type between brackets: `[Component: Flutter screen]`, `[Component: Riverpod controller]`, `[Component: Repository]`, `[External system]`. A small legend at the bottom explains the colors.
- Arrows show who calls whom. The rule is Screen -> Controller -> Repository -> Firebase. A screen never talks to Firebase directly.
- Component names are the names we use in the code. The React Native app uses the same names and layers (its controllers are hooks or contexts).
- Data names come from the data model (`docs/data-model.md`, VST-30): `users/{uid}` (public profile) and `users/{uid}/private/contact` (email and phone).
- `PhotoService` runs on the phone, before anything is sent: `EditProfileScreen` uses it to pick a profile photo and save it as a JPEG under 200 KB (`photoBase64`, see `docs/data-model.md`). It is the same helper as in the Listings diagram.
- One arrow crossing remains on purpose: both controllers use both repositories (`AuthController` and `ProfileController` call `AuthRepository` and `UserRepository`), so the arrows cannot all be drawn without a crossing while keeping the layers.

| Component | Type | Responsibility |
|---|---|---|
| `LoginScreen` | Flutter screen | Email and password form. |
| `SignUpScreen` | Flutter screen | Name, email and password form. |
| `ProfileScreen` | Flutter screen | Shows the profile, the language selector and the log out button. |
| `EditProfileScreen` | Flutter screen | Form to change name, photo and phone. |
| `PhotoService` | Phone-side helper | Picks a photo, resizes it and saves it as JPEG under 200 KB (`photoBase64`). |
| `AuthController` | Riverpod controller | Keeps the sign-in state, checks the input, runs sign up, log in and log out, and asks `UserRepository` to create the profile after sign up. |
| `ProfileController` | Riverpod controller | Loads and saves the profile, handles loading and error states, gets the current user id from `AuthRepository`. |
| `AuthRepository` | Repository | Wraps Firebase Auth: sign up, log in, log out, session. |
| `UserRepository` | Repository | Reads and writes `users/{uid}` and `users/{uid}/private/contact` in Firestore. |

## Level 3: Listings and Favorites

Read it like the Auth and Profile diagram (types between brackets, legend at the bottom, Screen -> Controller -> Repository -> Firebase). Data names come from `docs/data-model.md`: `listings`, `listings/{id}/photos` and `favorites`. The names of the publish flow follow the Flutter code merged in VST-38.

- Photos are stored in Firestore (compressed base64 in `listings/{id}/photos`), NOT in Firebase Storage (decision of 8 Oct, Storage needs a paid plan).
- `PhotoService` runs on the phone, before anything is sent: it picks one photo, resizes it to about 800 px wide, saves it as JPEG under 200 KB, and refuses a 6th photo.
- `ListingRepository` writes the listing and its photos (fixed ids `p0` to `p4`) and the `photoCount` in one batch write, so there is no separate photo repository.
- `formatPrice` (TND, thousands separators) and the translation layer (English, French, Arabic) are shared helpers used by every screen. They are drawn once, without arrows, to keep the diagram readable.
- `FavoritesController` asks `ListingRepository` for the favorite listings, because a favorite only stores the listing id.
- The list screen is called `ListingsScreen`, the name used in the code (a placeholder today); the detail screen is drawn as it will be built.

| Component | Type | Responsibility |
|---|---|---|
| `PublishListingScreen` | Flutter screen | Form to publish a listing (price in TND, rent period, property type, city) with photos. |
| `ListingsScreen` | Flutter screen | Lists the listings with photo and price. |
| `ListingDetailScreen` | Flutter screen | Shows one listing, its photos and a favorite button. |
| `FavoritesScreen` | Flutter screen | Lists the favorite listings. |
| `ListingController` | Riverpod controller | Runs the publish flow, loads the listings, handles loading and error states. |
| `FavoritesController` | Riverpod controller | Adds, removes and loads the favorites. |
| `ListingRepository` | Repository | Reads and writes the `listings` collection and the `listings/{id}/photos` subcollection (one batch write). |
| `FavoritesRepository` | Repository | Reads and writes the `favorites` collection. |
| `PhotoService` | Phone-side helper | Picks a photo, resizes to about 800 px wide, JPEG, under 200 KB, max 10 photos. |
| `formatPrice` and translation layer | Shared helper | Same price format and texts in every screen. |

## Level 3: Search, Map and Chat

Read it like the other level 3 diagrams (types between brackets, legend at the bottom, Screen -> Controller -> Repository -> Firebase). The three modules are grouped in a frame each. Data names come from `docs/data-model.md`: `listings`, `conversations` and `conversations/{id}/messages`.

- The map uses OpenStreetMap tiles, NOT Google Maps (decision of 8 Oct). `MapScreen` loads the tiles directly from OpenStreetMap (the "never talk to Firebase directly" rule is about Firebase) and shows the attribution `© OpenStreetMap contributors`.
- The map only shows listings that have `latitude` and `longitude` (optional in the data model). The default map center (Tunis) comes from the app config.
- `LocationService` asks the GPS permission and gets the position of the phone. `MapController` is the only caller.
- The controller is named `SearchFiltersController` (not `SearchController`) because Flutter Material already has a `SearchController` class, so the name would clash in the code.
- `SearchFilters` (price range, location, property type, sale or rent) is a widget used by `SearchScreen`. `SearchFiltersController` keeps the filters and asks `ListingRepository`, which is shared with the map and with the Listings module.
- A conversation id is `{listingId}_{buyerId}` and its messages are a subcollection. `ChatController` serves both chat screens through `ChatRepository`.
- New message alert (MVP): there is no server push, because Cloud Functions are not available on the Firebase free plan. `ChatRepository` listens to Firestore in real time, `ChatController` sends each new message to `NotificationService`, and `NotificationService` shows a badge and a local notification, when the app is open or in the background.
- Not in the MVP: the real FCM push (app closed). It needs the Firebase Blaze plan or a small external server. It is a future ticket (see "Future work" below).
- `formatPrice`, the app config and the translation layer are shared helpers used by the screens. They are drawn once, without arrows.

| Component | Type | Responsibility |
|---|---|---|
| `SearchScreen` | Flutter screen | Search box and list of results. |
| `SearchFilters` | Flutter widget | Price range, location, property type, sale or rent. |
| `SearchFiltersController` | Riverpod controller | Keeps the filters and loads the results. |
| `MapScreen` | Flutter screen | Map with the listings, shows the OpenStreetMap attribution. |
| `MapController` | Riverpod controller | Loads the listings with coordinates and the user position. |
| `LocationService` | Phone-side service | Asks the GPS permission and gets the position. |
| `ChatListScreen` | Flutter screen | Lists my conversations. |
| `ChatScreen` | Flutter screen | Messages of one conversation. |
| `ChatController` | Riverpod controller | Loads conversations and messages, sends a message, and passes each new message to `NotificationService`. |
| `ChatRepository` | Repository | Reads and writes `conversations` and `conversations/{id}/messages`, and listens to Firestore in real time. |
| `NotificationService` | Phone-side service | Shows a badge and a local notification for a new message (app open or in the background). |
| `ListingRepository` | Repository | Reads the `listings` collection (search and map). |
| `formatPrice`, app config, translation layer | Shared helper | Same price format, map center and texts in every screen. |

### Future work

- Real push notifications with FCM, so the alert also arrives when the app is closed. FCM itself is free, but sending a push to another user needs a server: Firebase Blaze plan (Cloud Functions) or a small external server. Not in the MVP, to be created as a Jira ticket.
