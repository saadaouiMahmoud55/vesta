# Vesta demo script (Mon 16 Nov)

Draft written on 15 Nov from what is merged in `develop`. Lines marked **(if merged)** depend on PRs still open on Sunday: update them after the last merges. Test accounts and who speaks are placeholders to fill in.

## Before the demo (Sunday night)

- Build the debug APK from the final `develop` and install it on two phones. Check that sign-in works on both (the API key is restricted by package name and SHA-1: every phone's SHA-1 must be in the key).
- Create two test accounts: **Owner** and **Client**. Owner has 2 or 3 listings (one sale, one rent, one stay) with real photos and an exact location.
- Put one phone in Arabic and one in French, so the RTL switch is visible.
- Charge the phones, turn off notifications from other apps, connect to a stable network. Keep a second network (phone hotspot) ready.
- Have the app already signed out on the Client phone, to show guest browsing first.
- Close all other apps. Keep a screen recording of the full flow as a backup.

## Flow (about 8 minutes)

**1. Open and browse as a guest (1 min).** Open the app without an account. Explore shows the listings. Say: *"You can browse without signing up; an account is only needed to contact, favorite or publish."* Search a city (try an Arabic spelling) and filter by offer type.

**2. Listing details (1 min).** Open a listing. Show the price and the offer badge (sale, rent, stay), the photos, the amenities, and the small map with the exact location and the **Open in Maps** button. Tap **Contact owner**: the app asks the guest to sign in. Sign in as Client.

**3. Map (1 min).** Open the Map tab. All listings appear as pins with price; tap a pin to see the preview card, tap the card to open the details. Search a Tunisian city.

**4. Favorites and chat (1.5 min).** Favorite a listing, open Favorites, tap it: it opens the details. Send the first message to the owner. Show the listing strip at the top of the chat and the date separator.

**5. Owner side: notifications and My listings (1.5 min).** On the Owner phone: the bell and the chat icon show an unread badge; the notification center lists the conversation and opens the right chat. Say clearly: *"Alerts work while the app is running; there is no server push, because that needs a paid plan."* Then Profile > My listings: change a status (available, reserved, sold).

**6. Publish and edit (1.5 min).** Publish a listing: fields, city, picking the exact location, up to 10 photos (duplicates are skipped). **(if merged)** Edit the listing from My listings: the form is pre-filled, change the price and a photo, save, and show the updated listing on the Client phone.

**7. Profile, language and safety (1 min).** Profile: edit name and photo, **(if merged)** remove the photo, tap the photo to see it full size. Settings: switch the language between Arabic, French and English, and show that the layout flips to right-to-left. Mention that the account can be deleted from Settings.

**8. React Native app (30 s).** Say plainly that the React Native app is a reduced version (sign-in, navigation, a map **(if merged)**, part of the listings), and that Flutter is the full app.

## What we say about the limits

Say them yourselves before the jury asks. The full list is in the report ("limits and future work"):

- Photos are stored as compressed text in Firestore (no paid Storage); maximum 10 per listing.
- No alert when the app is closed (no server push, no paid plan).
- Search reads the newest 100 listings and filters in the app.
- Names typed by users are not translated or transliterated.
- Google and Apple sign-in are future work; the listings are not yet split into separate collections by type.
- Real listings are only published with the owner's written consent; the others are marked as demo content.

## If something fails during the demo

- **Sign-in fails on a phone:** the phone's SHA-1 is missing from the API key. Switch to the other phone and continue; fix it after.
- **Slow or no network:** switch to the hotspot. If it is still slow, play the screen recording of that step.
- **A photo or listing does not load:** go to the next listing; do not retry more than once on stage.
- **The app crashes:** reopen it, sign in again, and continue from the next step.

## Likely questions (prepare one answer each)

1. **Why Firebase and no own backend?** Free plan, fast to build, security rules protect the data (owner-only edits, private contact, valid listings only).
2. **How do you protect the owner's phone number?** It is in a separate private document readable only by signed-in users; guests cannot read it.
3. **How does the edit mode keep the data valid?** One batch updates the listing, its photos and its contact together; the offer type and period are locked so the status rules stay valid.
4. **How do you handle Arabic?** The text files (CSV) generate the Flutter and React Native translations; prices, phone numbers and emails are forced left-to-right inside right-to-left screens.
5. **What would you do with more time?** See "Future work" in the report.
6. **How did you work as a team?** Sprints in Jira, one branch and one pull request per ticket, a required review, and a green check (translations, colors, analyze, tests) before every merge.
