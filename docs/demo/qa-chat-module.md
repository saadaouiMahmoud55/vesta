# Q&A cheat sheet: the chat module (VST-122)

Module: Flutter chat, written by Eya (VST-44). Files in `flutter-app/lib/features/chat/`: `chat_repository.dart`, `chat_controller.dart`, `chat_models.dart`, `chat_list_screen.dart`, `chat_screen.dart`. Rules in `firebase/firestore.rules` (block `conversations`). Tests: `chat_models_test.dart`, `chat_screen_test.dart`.

## The 30-second explanation

A buyer opens a listing and taps Chat. There is one conversation per listing and per buyer, with the id `{listingId}_{buyerId}`. The messages are in a subcollection `messages`. The conversation document is created with the first message, so opening a chat writes nothing. Everything goes through `ChatRepository`; screens never call Firebase directly.

## How it is built (3 layers)

- **Repository** (`chat_repository.dart`): the only place that talks to Firestore. It sends messages, watches conversations and messages, marks as read, and turns Firebase errors into a small `ChatError` list.
- **Controller** (`chat_controller.dart`): Riverpod providers. They give the live conversation list, the live messages (last 50), the unread total for the badge, and `sendChatMessage` with an 8 second wait limit.
- **Screens**: the list and the chat screen only show state and call the controller.

## Likely questions and short answers

1. **How is a message sent?**
   One Firestore batch writes two things together: the message, and the conversation summary (`lastMessage`, `lastMessageAt`, +1 unread for the other person). So a conversation can never show a message that does not exist. For the first message, the same write also creates the conversation.

2. **How do you stop a stranger from reading a conversation?**
   Firestore rules: only a user whose uid is in `participantIds` can read the conversation and its messages. Messages cannot be edited or deleted (`allow update, delete: if false`). A message must be sent by the user himself (`senderId == uid`) and be at most 2000 characters.

3. **Can the owner talk to himself, or can someone create a conversation for two other people?**
   No. The rules refuse a conversation where the creator is the listing owner, and the id must be `{listingId}_{myUid}`. The code also throws `ownListing` before sending.

4. **What happens offline?**
   Firestore keeps the write in a local queue. The screen waits 8 seconds, then shows a "no network" message, but the message is not lost: it is sent when the network is back. Known limit: there is no real internet check before sending.

5. **How does the unread badge work?**
   Each conversation has `unread` with one counter per user. Sending adds 1 for the other person. Opening the chat sets your own counter to 0 (`markRead`). The badge sums the counters from the same live list, so no second Firestore listener is opened.

6. **Why is the list sorted in the app and not in the query?**
   `arrayContains` plus `orderBy` would need a Firestore index. Sorting in the app avoids it and the lists are small.

7. **Why only the last 50 messages?**
   To keep the screen fast and cheap on reads. The listener stops when the screen closes (`autoDispose`), so there is no leaked listener.

8. **Why is `participantIds` always `[buyer, owner]` in this order?**
   The rules refuse an update that changes the array, and arrays are compared in order. So the app always writes it in the same order.

9. **How are errors shown to the user?**
   The repository maps Firebase codes to `ChatError` (not signed in, own listing, message too long, no network, permission denied, unknown). The screens turn them into translated texts in English, French and Arabic.

10. **How is it tested?**
    Unit tests for the models and the id parsing, and widget tests for the chat screen. Eya also tested on a real Redmi phone with two accounts.

## Honest limits (say them before they are asked)

- No push notifications and no local notification: the alert is in-app only (VST-135 is future work).
- No internet check before sending; the message waits in the queue.
- Messages are text only (no photos) and cannot be edited or deleted.
- The React Native chat (VST-45, PR #102) exists but is not merged before the freeze.

## If you do not know the answer

Say: "That part is in `chat_repository.dart`, I can show you the exact lines." Then open the file. Do not guess.
