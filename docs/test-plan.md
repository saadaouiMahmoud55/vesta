# Vesta test plan (VST-52)

Version 2, 3 November 2026 (review of 2 November applied). Owner: Ahmed. Reviewer: Manar.

This is one test plan for both apps (Flutter and React Native). Every test is run on **both** apps, on a **real phone**, with the same steps and the same expected result. It is used in Sprint 3 (real-phone testing) and in the buffer (final tests), and it is the proof of the tests in the final report.

**How to use it**

1. Read the real-phone checklist and prepare the two test accounts and the test data.
2. Run the tests of a section in order. Follow the numbered steps exactly.
3. In the **Flutter** and **React Native** columns write `Pass`, `Fail` or `Not tested`. If a feature does not exist yet in one app, leave `Not tested`. Tests marked `Not in MVP` are out of scope: leave `Not in MVP`.
4. Fill in your name, the date and the phone model. If a test fails, create a Jira bug and write it in the bug table at the end.

Specification used for the expected results: `docs/user-stories.md`, `docs/offer-types.md`, `docs/data-model.md`. The answers of the review of 2 November are in "Decisions" at the end; the two questions still open are in "Open questions".

## Real-phone checklist

- [ ] Phone model and Android version written in the Phone model column (example: Xiaomi Redmi Note 13, Android 15).
- [ ] Wi-Fi tested, and mobile data tested (at least the sign-in and the map).
- [ ] Permissions to test: location, photos or camera (profile and listing photos), notifications (Android 13 or newer asks).
- [ ] A second phone (or an emulator) is ready for the chat and notification tests.
- [ ] Phone language switched to English, French and Arabic for LNG-01.
- [ ] **Flutter app:** debug build with `flutter run` (app id `com.vesta.flutterapp.debug`, it installs next to the Play Store version), or the release APK (`flutter build apk --release`, see `flutter-app/README.md`). Do **not** install the release APK on a phone that has the Google Play test version.
- [ ] **React Native app:** install Expo Go from Google Play, run `npm install` and `npm start` in `react-native-app/`, fill `.env` (ask Manar for the values, never commit it) and scan the QR code on the same Wi-Fi as the computer.
- [ ] Both apps use the same Firebase project.

## Test accounts and test data

Create two accounts in the apps (any email you can access, password of 8 characters or more): **A** is the owner, **B** is the buyer or tenant. Use Tunisian data:

| Offer | Title | City | Price | Details |
|---|---|---|---|---|
| Sale | Villa à Hammamet | Hammamet | 650000 TND | villa, area 220 m², 2 photos |
| Rent | Appartement S+2 à La Marsa | La Marsa | 1200 TND per month | apartment, area 95 m², furnished |
| Stay | Riad à Tozeur | Tozeur | 120 TND per night | riad, 4 guests, 2 beds, wifi and ac |
| Stay | Maison d'hôtes à Sidi Bou Said | Sidi Bou Said | 180 TND per night | guest house, 2 guests, 1 bed |

Phone numbers use the format `+216XXXXXXXX`. Use photos from the gallery of the phone, and one photo larger than 5 MB.

## Authentication
Accounts A (owner) and B (buyer) are created in AUTH-01. Password: 8 characters or more.

| ID | Test | Steps | Expected result | Flutter | React Native | Tester | Date | Phone model |
|---|---|---|---|---|---|---|---|---|
| AUTH-01 | Sign up | 1. Open the app signed out.<br>2. Tap Sign up.<br>3. Enter a name, a new email and a password of 8 characters or more.<br>4. Tap Sign up. | The account is created, the user is signed in and sees the home screen. | Not tested | Not tested | | | |
| AUTH-02 | Sign up with wrong data | 1. Open Sign up.<br>2. Try each of these: an invalid email (`abc`), a password shorter than 8 characters, an email that already has an account.<br>3. Tap Sign up each time. | Each attempt stays on the screen with a clear error message in the app language. No account is created. | Not tested | Not tested | | | |
| AUTH-03 | Log in | 1. Open Log in.<br>2. Enter the email and password of account A.<br>3. Tap Log in. | The user is signed in and sees the home screen. The name of A is shown in Profile. | Not tested | Not tested | | | |
| AUTH-04 | Log in with a wrong password | 1. Open Log in.<br>2. Enter the email of A and a wrong password.<br>3. Tap Log in. | An error message is shown, the user stays on Log in and is not signed in. No crash. | Not tested | Not tested | | | |
| AUTH-05 | Session is kept | 1. Log in as A.<br>2. Close the app completely (swipe it away from the recent apps).<br>3. Open the app again. | The user is still signed in. The login screen is not shown. | Not tested | Not tested | | | |
| AUTH-06 | Log out | 1. Log in as A.<br>2. Open Profile, tap Settings, then tap Log out.<br>3. Close and reopen the app. | The user is signed out and the app does not sign in again. Publish, Chat and Favorites ask to sign in. | Not tested | Not tested | | | |
| AUTH-07 | Guest browsing | 1. Open the app signed out.<br>2. Browse the home screen, use Search and open the details of a listing.<br>3. Tap Favorite, Chat, the contact number and Publish.<br>4. Sign in from the sign-in sheet. | Step 2 works without an account and the contact number is hidden. Step 3: each action opens the sign-in sheet. After step 4 the user comes back to the same screen. | Not tested | Not tested | | | |

## Listings
Run these tests signed in as A unless the step says otherwise. Offer types and fields: `docs/offer-types.md`.

| ID | Test | Steps | Expected result | Flutter | React Native | Tester | Date | Phone model |
|---|---|---|---|---|---|---|---|---|
| LST-01 | Publish a sale | 1. Tap Publish and choose "Sell".<br>2. Fill: title `Villa à Hammamet`, a description of 40 characters or more, property type Villa, city Hammamet, price 650000, area 220, phone `+21620123456`.<br>3. Add 2 photos.<br>4. Tap Publish. | The listing is saved and appears in My listings with the For sale ribbon. The price is shown as `TND 650,000` (no unit). The details show the area and the 2 photos. | Not tested | Not tested | | | |
| LST-02 | Publish a rent | 1. Tap Publish and choose "Rent out".<br>2. Fill: title `Appartement S+2 à La Marsa`, description, property type Apartment, city La Marsa, price 1200, period month, area 95, furnished yes, phone.<br>3. Add 3 photos.<br>4. Tap Publish. | The listing is saved with the For rent ribbon. The price is shown as `TND 1,200 / month` and the furnished info appears in the details. | Not tested | Not tested | | | |
| LST-03 | Publish a stay | 1. Tap Publish and choose "Offer a stay".<br>2. Open the property type list.<br>3. Fill: title `Riad à Tozeur`, description, property type Riad, city Tozeur, price 120 per night, guests 4, beds 2, amenities wifi and ac, check-in 14:00, phone.<br>4. Add 1 photo.<br>5. Tap Publish. | Step 2: the list does not contain land or commercial. The listing is saved with the Stay ribbon and the price `TND 120 / night`. Guests, beds and amenities appear in the details. | Not tested | Not tested | | | |
| LST-04 | Changing the offer type clears the fields | 1. Tap Publish and choose "Sell".<br>2. Fill the price and turn Negotiable on.<br>3. Go back and choose "Offer a stay". | The sale-only fields (negotiable, year built, documents note) are cleared and hidden. The stay fields (guests, beds, amenities) appear. | Not tested | Not tested | | | |
| LST-05 | Required fields and limits | 1. Start a publish form.<br>2. Try to publish with each of these: a description under 40 characters, no photo, a sale without area, a stay without guests or beds, a phone that does not start with `+216`, a title of 100 characters and a description of 2000 characters (paste them).<br>3. Tap Publish each time. | The first five are refused with a message next to the field and nothing is saved. The title of 100 characters and the description of 2000 characters are accepted: the text wraps or is cut cleanly, the layout stays intact and the app does not crash. | Not tested | Not tested | | | |
| LST-06 | Photos: 1 to 10 | 1. Start a publish form.<br>2. Select several photos at once in the gallery (up to 10), one of them larger than 5 MB.<br>3. Select the same photo again, then try to add an 11th photo.<br>4. Remove one photo and add another. | The photos are accepted and the big one is compressed (under about 200 KB) and displayed in the details. A duplicate is not added (message shown). The 11th photo is refused with a message. The photo counter is always correct. | Not tested | Not tested | | | |
| LST-07 | View the details of a listing | 1. Log in as B.<br>2. Open a listing from the list.<br>3. Swipe through the photos.<br>4. Look at the price, the key facts and the buttons under the price.<br>5. Log in as A and open the same listing. | All photos can be swiped. The price has its unit. The key facts match the offer type. B sees the contact buttons (Call, WhatsApp if enabled, Chat) under the price. A (the owner) does not see the Chat button. | Not tested | Not tested | | | |
| LST-08 | Edit my listing | 1. Log in as A and open My listings.<br>2. Open a listing, tap Edit, change the price and the description, save.<br>3. Log in as B and open the same listing. | The changes are visible in the list and the details for A and for B. B has no Edit and no Delete button on the listing of A. | Not tested | Not tested | | | |
| LST-09 | Delete my listing | 1. Log in as A and open My listings.<br>2. Open a listing, tap Delete and confirm.<br>3. Check Search and the Map.<br>4. Log in as B, who had this listing in Favorites, and open Favorites. | A confirmation is asked first. The listing disappears from My listings, Search and the Map. In the Favorites of B it shows "no longer available" and the app does not crash. | Not tested | Not tested | | | |
| LST-10 | Change the status | 1. Log in as A and open My listings.<br>2. Set the sale to Sold, the rent to Rented and the stay to Unavailable.<br>3. Log in as B, who has all three in Favorites, and check Search, Map and Favorites. | The status choices match the offer type. The three listings no longer appear in Search, Map and Home. In Favorites B still sees them with a status ribbon. | Not tested | Not tested | | | |

## Search and filters
Prerequisite: at least one sale, one rent and one stay are published (LST-01 to LST-03).

| ID | Test | Steps | Expected result | Flutter | React Native | Tester | Date | Phone model |
|---|---|---|---|---|---|---|---|---|
| SRC-01 | Buy, Rent and Stay tabs | 1. Open Search.<br>2. Tap Buy, then Rent, then Stay. | Each tab shows only its offer type. The price unit follows the tab: none for Buy, `/ month` for Rent, `/ night` for Stay. | Not tested | Not tested | | | |
| SRC-02 | Price filter | 1. Open Search and tap the Stay tab.<br>2. Open the filters and set a price range that contains only one stay.<br>3. Apply. | Only the listings inside the range are shown. The price slider uses the unit of the tab. | Not tested | Not tested | | | |
| SRC-03 | City and property type filters | 1. Open Search and the Rent tab.<br>2. Filter by the city `La Marsa`.<br>3. Add the property type Apartment. | Only the matching listings are shown. Removing a filter updates the list. | Not tested | Not tested | | | |
| SRC-04 | Combined filters and reset | 1. Open Search and combine a tab, a price range, a city and a property type.<br>2. Check the results.<br>3. Tap Reset. | Every result matches all the filters. Reset restores the full list of the tab. | Not tested | Not tested | | | |
| SRC-05 | No result | 1. Open Search, tab Stay.<br>2. Filter for a combination with no listing (for example Tozeur, under 10 TND). | A clear empty-state message is shown (not a blank screen, not an error). Changing the filter shows results again. | Not tested | Not tested | | | |

## Map and location
Prerequisite: listings with coordinates (one of each offer type) and one listing without coordinates.

| ID | Test | Steps | Expected result | Flutter | React Native | Tester | Date | Phone model |
|---|---|---|---|---|---|---|---|---|
| MAP-01 | Map opens | 1. Open the Map tab with network on. | The OpenStreetMap tiles load. The map is centered on Tunis by default. Pan and zoom work. `© OpenStreetMap contributors` is visible and can be tapped (not hidden behind a button). | Not tested | Not tested | | | |
| MAP-02 | Location permission allowed | 1. Open the Map tab for the first time.<br>2. Tap the my-location button.<br>3. Allow the permission. | The permission dialog is shown. After Allow a marker shows the position of the phone and the map recenters on it. | Not tested | Not tested | | | |
| MAP-03 | Location permission denied | 1. Open the Map tab for the first time.<br>2. Tap the my-location button.<br>3. Deny the permission. | The app does not crash. A message explains that the location is off. The map keeps working on the default center. | Not tested | Not tested | | | |
| MAP-04 | Pins | 1. Open the Map tab.<br>2. Look at the pins.<br>3. Tap a pin, then tap its mini card. | Only listings with coordinates have a pin; the listing without coordinates is not shown. The pin color follows the offer type (Stay blue, Rent navy, Sale terracotta). The mini card opens the details. | Not tested | Not tested | | | |
| MAP-05 | Map without network | 1. Turn off Wi-Fi and mobile data.<br>2. Open the Map tab.<br>3. Turn the network back on. | The app does not crash and shows missing tiles or a message. The tiles load again when the network is back. | Not tested | Not tested | | | |

## Chat
Use two phones (or one phone and an emulator): phone 1 is signed in as B, phone 2 as A.

| ID | Test | Steps | Expected result | Flutter | React Native | Tester | Date | Phone model |
|---|---|---|---|---|---|---|---|---|
| CHT-01 | Start a conversation | 1. On phone 1 (B) open a listing of A.<br>2. Tap Chat.<br>3. Type `Bonjour, est-ce disponible ?` and send. | The message appears in the conversation. The conversation appears in the chat list of B with this last message. | Not tested | Not tested | | | |
| CHT-02 | The owner replies in real time | 1. Keep the conversation open on phone 1.<br>2. On phone 2 (A) open the Chat tab and the conversation.<br>3. Send a reply. | A sees the message of B and the conversation in the list. The reply appears on phone 1 within a few seconds without refreshing. | Not tested | Not tested | | | |
| CHT-03 | One conversation per listing and buyer | 1. As B, open the same listing again and tap Chat.<br>2. Open another listing of A and tap Chat. | The same listing opens the same conversation (no duplicate). The other listing creates a new conversation. | Not tested | Not tested | | | |
| CHT-04 | Chat list and empty state | 1. Create a new account C and open the Chat tab.<br>2. As A open the Chat tab. | C sees an empty-state message. A sees the conversations with the most recent first. | Not tested | Not tested | | | |
| CHT-05 | Empty and long messages | 1. Open a conversation.<br>2. Try to send an empty message and a message with only spaces.<br>3. Send a message of 2000 characters.<br>4. Try to send a message of 2001 characters. | The empty messages are not sent. The message of 2000 characters is sent and wrapped, and the layout stays correct. The message of 2001 characters is not sent and the app does not crash. | Not tested | Not tested | | | |
| CHT-06 | Chat when signed out | 1. Open a listing as a guest.<br>2. Tap Chat.<br>3. Sign in. | The sign-in sheet is shown. After signing in the user comes back to the same listing. | Not tested | Not tested | | | |
| CHT-07 | Call and WhatsApp | 1. As B open a listing with WhatsApp enabled.<br>2. Tap Call, then go back and tap WhatsApp.<br>3. Open a listing without WhatsApp. | Call opens the phone dialer with the number of the listing (`+216...`). WhatsApp opens a chat with that number. The WhatsApp button is hidden when it is not enabled. | Not tested | Not tested | | | |

## Favorites

| ID | Test | Steps | Expected result | Flutter | React Native | Tester | Date | Phone model |
|---|---|---|---|---|---|---|---|---|
| FAV-01 | Add a favorite | 1. Log in as B and open a listing.<br>2. Tap the heart.<br>3. Close the app completely and open it again.<br>4. Open the Favorites tab. | The heart is filled. The listing is in Favorites, also after restarting the app. | Not tested | Not tested | | | |
| FAV-02 | Remove a favorite | 1. Open the Favorites tab.<br>2. Tap the heart of a listing (or the remove button). | The listing disappears from the list at once and the heart is empty in the details. | Not tested | Not tested | | | |
| FAV-03 | Empty favorites | 1. Log in with a new account.<br>2. Open the Favorites tab. | An empty-state message is shown in the app language (not a blank screen). | Not tested | Not tested | | | |

## Profile

| ID | Test | Steps | Expected result | Flutter | React Native | Tester | Date | Phone model |
|---|---|---|---|---|---|---|---|---|
| PRF-01 | View the profile | 1. Log in as A.<br>2. Open the Profile tab. | The name and the email (or photo) are shown, with My listings and a Settings entry. | Not tested | Not tested | | | |
| PRF-02 | Edit the name | 1. Open Profile and Edit profile.<br>2. Change the name and save.<br>3. Close and reopen the app. | The new name is shown in Profile, also after restarting the app. | Not tested | Not tested | | | |
| PRF-03 | Edit the photo | 1. Open Edit profile.<br>2. Choose a photo from the gallery (and one from the camera if available).<br>3. Save. | The photo is shown as the profile picture. A big photo is accepted (compressed). Cancelling keeps the old photo. | Not tested | Not tested | | | |
| PRF-04 | My listings | 1. Log in as A (with listings) and open My listings.<br>2. Log in as B (without listings) and open My listings. | A sees only own listings and can open each one. B sees an empty-state message. | Not tested | Not tested | | | |
| PRF-05 | Language selector | 1. Open Profile > Settings and the language selector.<br>2. Choose Français, then العربية, then English.<br>3. Close and reopen the app. | The texts change right away. The chosen language is kept after restarting. | Not tested | Not tested | | | |
| PRF-06 | Delete my account (after VST-84) | 1. Not built yet: run this test after VST-84.<br>2. Log in with a test account that has a listing.<br>3. Open Profile > Settings and Delete account (check where it is), confirm.<br>4. Try to log in again with the same email. | A confirmation is asked first. The account and its data are removed. The login fails and the app is back in guest mode. | Not tested | Not tested | | | |

## Notifications
Use two phones. Phone 2 is signed in as A, phone 1 as B. Real push notifications need the paid Firebase plan, so they are not in the MVP (NTF-02, NTF-03). Only the in-app alert is tested (NTF-04).

| ID | Test | Steps | Expected result | Flutter | React Native | Tester | Date | Phone model |
|---|---|---|---|---|---|---|---|---|
| NTF-01 | Notification permission | 1. Install the app on a phone with Android 13 or newer and sign in.<br>2. When the permission dialog appears, tap Allow.<br>3. Repeat on a fresh install and tap Deny. | The dialog is shown. After Deny the app works normally without notifications and does not crash. | Not tested | Not tested | | | |
| NTF-02 | Notification when the app is in the background (not in MVP) | 1. On phone 2 (A) send the app to the background.<br>2. On phone 1 (B) send a message to A. | A receives a notification for the new message within a few seconds. Real push needs the paid Firebase plan. | Not in MVP | Not in MVP | | | |
| NTF-03 | Tap the notification (not in MVP) | 1. Receive a message notification on phone 2.<br>2. Tap the notification. | The app opens on the right conversation. Real push needs the paid Firebase plan. | Not in MVP | Not in MVP | | | |
| NTF-04 | App open and sender (in-app alert only) | 1. On phone 2 keep the app open on another screen.<br>2. On phone 1 send a message.<br>3. Look at both phones. | A sees an in-app alert or a badge for the new message (no push notification). B gets nothing for his own message. | Not tested | Not tested | | | |

## Languages, right-to-left and prices
Run the main flows in the three languages. Test data is Tunisian stays.

| ID | Test | Steps | Expected result | Flutter | React Native | Tester | Date | Phone model |
|---|---|---|---|---|---|---|---|---|
| LNG-01 | Default language | 1. Set the phone language to English, then install or reopen the app on a fresh install.<br>2. Repeat with French, Arabic and German. | The app starts in the phone language when it is English, French or Arabic. With German (or any other language) the app starts in Arabic. | Not tested | Not tested | | | |
| LNG-02 | Main flows in English | 1. Set the app to English.<br>2. Sign up, publish a stay, search, open the details, send a chat message, add a favorite, edit the profile. | Every step works and every text is in English. | Not tested | Not tested | | | |
| LNG-03 | Main flows in French | 1. Set the app to Français.<br>2. Repeat the flows of LNG-02. | Every step works and every text is in French. No text is left in English. | Not tested | Not tested | | | |
| LNG-04 | Main flows in Arabic | 1. Set the app to العربية.<br>2. Repeat the flows of LNG-02 (type the texts with the Arabic keyboard). | Every step works and every text is in Arabic. No text is left in English. | Not tested | Not tested | | | |
| LNG-05 | Right-to-left layout | 1. Set the app to العربية.<br>2. Open Home, Search, a listing details, Map, Chat, Favorites and Profile.<br>3. Switch back to English. | The layout is mirrored on every screen: text aligned to the right, back arrow, tabs and filters mirrored. Nothing is cut or overlapping. In English the layout is left-to-right again. | Not tested | Not tested | | | |
| LNG-06 | TND price and period | 1. Open a sale (650000), a rent (1200 per month) and a stay (120 per night).<br>2. Check the price in English, Français and العربية. | The price is written currency first with a comma as thousands separator: `TND 650,000` (sale, no unit), `TND 1,200 / month` (rent), `TND 120 / night` (stay). French: `/ mois`, `/ nuit`. Arabic: `/ شهر`, `/ ليلة`. In Arabic the numbers and TND stay left-to-right inside the sentence. | Not tested | Not tested | | | |
| LNG-07 | No missing text | 1. Set the app to Français, then to العربية.<br>2. Walk through every screen, dialog, error message (wrong password), empty state, ribbon, button and permission text. | No translation key name is visible (like `offer.sale`), no text is left in English and no label is empty. | Not tested | Not tested | | | |

## General

| ID | Test | Steps | Expected result | Flutter | React Native | Tester | Date | Phone model |
|---|---|---|---|---|---|---|---|---|
| GEN-01 | App without network | 1. Turn off Wi-Fi and mobile data.<br>2. Open the app while signed in.<br>3. Open Search and a listing, then try to publish.<br>4. Turn the network back on. | The app opens without crashing. A message or empty state is shown instead of an endless loading. No partial listing is created. The screens load again when the network is back. | Not tested | Not tested | | | |
| GEN-02 | Install and first launch | 1. Flutter: install the release APK (`flutter build apk --release`) on a phone that does not have the Google Play test version.<br>2. React Native: open the app in Expo Go with the QR code.<br>3. Open each app for the first time. | Each app opens on the home or login screen without crashing and can reach Firebase (sign up works). | Not tested | Not tested | | | |

## Cross-app (same account, same Firebase)
Run these tests with both apps installed. Write the result in both result columns.

| ID | Test | Steps | Expected result | Flutter | React Native | Tester | Date | Phone model |
|---|---|---|---|---|---|---|---|---|
| X-01 | Same account on both apps | 1. Sign up or log in as A in the Flutter app.<br>2. Log in with the same email and password in the React Native app. | Both apps sign in. The name, the photo and My listings are the same in both apps. | Not tested | Not tested | | | |
| X-02 | Listing created in Flutter, seen in React Native | 1. In the Flutter app publish `Villa à Djerba` (sale) with 2 photos.<br>2. Open the React Native app as B and look in Search and on the Map. | The listing is in the React Native app with the same title, price, offer type and photos. | Not tested | Not tested | | | |
| X-03 | Listing created in React Native, seen in Flutter | 1. In the React Native app publish `Maison d'hôtes à Sidi Bou Said` (stay) with 2 photos.<br>2. Open the Flutter app as B and look in Search and on the Map. | The listing is in the Flutter app with the same title, price (`/ night`), offer type and photos. | Not tested | Not tested | | | |
| X-04 | Messages and favorites across apps | 1. As B in the Flutter app send a message to A.<br>2. As A in the React Native app read it and reply.<br>3. As B in the React Native app add a favorite.<br>4. Open Favorites in the Flutter app as B. | The message and the reply are visible in both apps. The favorite is visible in both apps. | Not tested | Not tested | | | |

## Decisions (review of 2 November)

Answers of Manar, applied in the tests above.

1. **Price format.** `TND 120,000` as `formatPrice` gives (currency first, comma). Rent `TND 1,200 / month`, stay `TND 120 / night`. `offer-types.md` is updated in PR #38. (LST-01 to LST-03, LNG-06)
2. **Listings near me.** Not in the MVP as a sorted list. The map location button that recenters on the user is enough. No new test.
3. **Own listing.** The Chat button is hidden on the owner's own listing. (LST-07)
4. **Limits.** A chat message is limited to 2000 characters (Firestore rules). Title and description have no rule limit: tests use 100 characters for the title and 2000 for the description. (LST-05, CHT-05)
5. **Push notifications.** Real push needs the paid Firebase plan, so it is out of the MVP. NTF-02 and NTF-03 are `Not in MVP`. NTF-04 is an in-app alert only.
6. **Deleted listing in Favorites.** It shows "no longer available" and the app does not crash. (LST-09)
7. **Scope.** Report, block, booking request and visit request come later (VST-84, VST-92). No test cases for them yet.

## Open questions

1. **Language fallback in React Native.** The Flutter app starts in Arabic when the phone language is not English, French or Arabic (LNG-01). The React Native app falls back to English (`config.defaultLanguage = 'en'`). Should React Native be aligned with Flutter, or should the expected result of LNG-01 be per app? Until then RN fails LNG-01.
2. **NTF-01 (permission dialog).** With no real push in the MVP, is the notification permission dialog still shown? Keep, change or mark `Not in MVP`?

## Bugs found

| Jira key | Test ID | App | Description |
|---|---|---|---|
| | | | |
