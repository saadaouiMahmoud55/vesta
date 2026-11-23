# Listings

Home (Explore tab), listing details, publish form and contact buttons. Screens call a controller (hook); hooks call `listingsRepository` in `src/data/repositories/`; the repository accesses Firebase. Screens never access Firebase directly.

| File | Role |
|---|---|
| `HomeScreen.tsx`, `useLatestListings.ts` | Explore tab: the newest available listings |
| `ListingCard.tsx`, `coverPhotos.ts` | Card and its cover photo (`useCoverPhoto`) |
| `ListingDetailScreen.tsx`, `useListingDetail.ts` | Details: key facts, amenities, location |
| `PhotoGallery.tsx` | Photo gallery (photos come from `listings/{id}/photos`) |
| `ContactButtons.tsx`, `useListingContact.ts`, `contactLinks.ts` | Call and WhatsApp buttons (VST-80); the phone number is read from the protected `listings/{id}/contact/info` document |
| `PublishListingScreen.tsx`, `photoService.ts` | Publish form with photos (VST-39): pick from the gallery or take a photo, compress, up to 10 photos |
| `loadErrorKey.ts` | Maps a load error to a translation key |

Rules to remember:
- A listing and its photos are written in the same batch (see the photo contract in `firebase/README.md`).
- Contact numbers are Tunisian numbers starting with `+216` (`src/core/phone.ts`).
- This version only reads and creates listings: editing or deleting a listing and My listings exist in the Flutter app only. Other known limits (for example the description minimum, VST-137): see `docs/report/limits-and-future-work.md`.
