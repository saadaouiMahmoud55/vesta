# Chat (VST-45)

Real-time chat between a buyer and a listing owner. Same Firestore data as the Flutter app: a conversation has the id `{listingId}_{buyerId}`, messages cannot be edited or deleted (see `firebase/README.md`).

`ChatListScreen` / `ChatScreen` → `chatController.ts` → `chatRepository` (`src/data/repositories/chatRepository.ts`) → Firestore. A screen never calls Firebase.

- `ChatListScreen.tsx`: the conversations of the signed-in user, newest first, with the unread count.
- `ChatScreen.tsx`: the messages of one conversation and the input.
- `chatController.ts`: `useConversations()` (live list, restarts when the user signs in or out, `unreadTotal` for the badge) and the controller of one conversation. If a message is still queued after `sendWaitLimit` (8 s, offline), the screen tells the user; Firestore sends it when the network is back.
- Errors are mapped in `src/data/repositories/chatErrors.ts` and shown with translation keys.

Known limit (test X-04, 22 Nov): on some Android phones the input and the Send button are hidden by the navigation bar, so a reply cannot be sent from React Native. Reading messages sent from Flutter works. See `docs/report/limits-and-future-work.md`.
