# Vesta report: limits and future work

Draft for the final report (VST-57). Written 14 Nov 2026 from what we found in the phone tests and reviews. Check each line against the final state of `develop` before submitting.

## Known limits

**Photos**

- Photos are stored as compressed base64 text in Firestore, not in Firebase Storage (free plan). Maximum 10 per listing, about 800 px wide, each under about 270,000 characters.
- Picking photos works on phones. It does not work in Chrome: the image compressor reads a file path, and the browser gives a blob URL instead. Vesta targets Android phones, so the web build is not supported.

**Offline**

- A listing published without internet waits and can be published later without the user knowing. The offline banner only draws a message; it does not detect the connection.

**Search and listings**

- Search reads the newest 100 listings and filters them in the app (no server-side filters, no pagination).
- A hidden listing can still be opened by its direct link.
- In edit mode the owner cannot change the offer type (sale or rent) or the rent period, because the allowed statuses depend on them.

**Language**

- Names typed by users (profile name) stay in the letters they were typed. The app does not transliterate between Latin and Arabic.
- A native-speaker review of the Arabic and French texts, and a right-to-left check on more devices, were not finished.

**Accounts and safety**

- Deleting an account keeps the chat messages for the other person.
- Reporting and blocking users, and the privacy page, were not finished (see the Eya handover).
- The Android API key is restricted to our apps by package name and SHA-1. Every new developer or signing key needs its own row, and a change takes about 5 minutes.
- The app has no Cloud Functions (free plan), so account deletion and cleanup run from the app.

**React Native app**

- It is a reduced MVP of the Flutter app: sign-in, navigation, and part of the listings (the map and the contact buttons only if their pull requests are merged before the freeze). Message alerts and the unread badge are in. No AI assistant, bookings or reviews. The listings work (VST-39) was not finished.

**Content**

- Real listings need the owner's written consent. Listings without consent are clearly marked as demo content.

## Future work

- **Sign in with Google and Apple.** Apple needs a paid developer account.
- **Split the listings in Firestore** into separate collections by type (sales, rentals, stays), as our professor suggested, with indexes per collection.
- **Server-side search** with filters and pagination instead of reading the newest 100.
- **Firebase Storage** for photos, once billing is possible, instead of base64.
- **Real push notifications** (Firebase Cloud Messaging) instead of in-app and local alerts.
- **Offline detection** before publishing, with a clear message.
- **Booking requests, reviews and the AI assistant**, in both apps.
- **Report and block users**, privacy page and terms checkbox at sign-up.
- **Web support for photos** (add the `pica` script and read bytes instead of a file path).
- **Native Arabic review** of every text, aligned with the Tunisian glossary.
- **Dark mode** in Settings. Every screen uses the brand color tokens, so it needs a second set of tokens and a check of each screen.
- **Change the offer type of an existing listing** (sale, rent or stay). The allowed statuses depend on the offer type, so a change also needs a status reset and a rules change.
- **Edit email and phone in the profile** (VST-128): the name and the photo are already done.
- **More real-phone testing** on different devices and Android versions.
