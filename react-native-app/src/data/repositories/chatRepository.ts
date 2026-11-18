import {
  collection,
  doc,
  getDoc,
  increment,
  limit,
  onSnapshot,
  orderBy,
  query,
  serverTimestamp,
  Unsubscribe,
  updateDoc,
  where,
  writeBatch,
} from 'firebase/firestore';
import { auth, db } from '../firebase';
import { errorCodeOf } from './authErrors';
import { ChatFailure, mapChatCode } from './chatErrors';
import {
  ChatMessage,
  Conversation,
  conversationFromData,
  conversationIdFor,
  maxMessageLength,
  messageFromData,
  messagesPageSize,
  sortNewestFirst,
} from '../models/chat';

/**
 * Only place that talks to the `conversations` collection (VST-45).
 * One conversation per listing and per buyer, id = `{listingId}_{buyerId}`
 * (docs/data-model.md). Messages are in the subcollection `messages`.
 */
export class ChatRepository {
  /**
   * Id of the conversation between the signed-in buyer and the owner of the
   * listing. Nothing is written here: the conversation document is created
   * with the first message (see sendMessage).
   * Throws ChatFailure if nobody is signed in, or if the user owns the listing.
   */
  conversationIdForListing(listing: { id: string; ownerId: string }): string {
    const user = auth.currentUser;
    if (user === null) {
      throw new ChatFailure('notSignedIn');
    }
    if (listing.ownerId === user.uid) {
      throw new ChatFailure('ownListing');
    }
    return conversationIdFor(listing.id, user.uid);
  }

  /** Live list of the conversations of the signed-in user, newest first. */
  watchConversations(
    onData: (conversations: Conversation[]) => void,
    onError: (failure: ChatFailure) => void,
  ): Unsubscribe {
    const user = auth.currentUser;
    if (user === null) {
      onData([]);
      return () => {};
    }
    const conversations = query(
      collection(db, 'conversations'),
      where('participantIds', 'array-contains', user.uid),
    );
    return onSnapshot(
      conversations,
      snapshot => {
        // Sorted here (not in the query) so no Firestore index is needed.
        onData(
          sortNewestFirst(
            snapshot.docs.map(item => conversationFromData(item.id, item.data())),
          ),
        );
      },
      error => onError(new ChatFailure(mapChatCode(errorCodeOf(error)))),
    );
  }

  /**
   * Live list of the last `max` messages, newest first. The chat screen shows
   * it upside down so the newest message is at the bottom.
   * Call the returned function to stop the listener.
   */
  watchMessages(
    conversationId: string,
    onData: (messages: ChatMessage[]) => void,
    onError: (failure: ChatFailure) => void,
    max: number = messagesPageSize,
  ): Unsubscribe {
    const messages = query(
      collection(db, 'conversations', conversationId, 'messages'),
      orderBy('createdAt', 'desc'),
      limit(max),
    );
    return onSnapshot(
      messages,
      snapshot => {
        onData(snapshot.docs.map(item => messageFromData(item.id, item.data())));
      },
      error => onError(new ChatFailure(mapChatCode(errorCodeOf(error)))),
    );
  }

  /**
   * Sends a text from the signed-in user (the buyer or the owner).
   * One batch writes the message and the conversation summary together, so a
   * conversation never shows a message that does not exist. For the very first
   * message the same set also creates the conversation.
   */
  async sendMessage(input: {
    listingId: string;
    buyerId: string;
    ownerId: string;
    text: string;
  }): Promise<void> {
    const user = auth.currentUser;
    if (user === null) {
      throw new ChatFailure('notSignedIn');
    }
    const { listingId, buyerId, ownerId } = input;
    if (buyerId === ownerId) {
      throw new ChatFailure('ownListing');
    }
    if (user.uid !== buyerId && user.uid !== ownerId) {
      throw new ChatFailure('permissionDenied');
    }

    const body = input.text.trim();
    if (body.length === 0) {
      return;
    }
    if (body.length > maxMessageLength) {
      throw new ChatFailure('messageTooLong');
    }

    const recipient = user.uid === buyerId ? ownerId : buyerId;
    const conversation = doc(
      db,
      'conversations',
      conversationIdFor(listingId, buyerId),
    );
    const batch = writeBatch(db);
    batch.set(
      conversation,
      {
        // Always [buyer, owner], in this order: the rules refuse an update
        // that changes the array, and arrays are compared in order.
        participantIds: [buyerId, ownerId],
        listingId,
        lastMessage: body,
        lastMessageAt: serverTimestamp(),
        unread: { [recipient]: increment(1) },
      },
      { merge: true },
    );
    batch.set(doc(collection(conversation, 'messages')), {
      senderId: user.uid,
      text: body,
      createdAt: serverTimestamp(),
    });

    try {
      await batch.commit();
    } catch (error) {
      throw new ChatFailure(mapChatCode(errorCodeOf(error)));
    }
  }

  /**
   * Sets the unread counter of the signed-in user to 0. Does nothing if the
   * conversation does not exist yet (it is created with the first message).
   */
  async markRead(conversationId: string): Promise<void> {
    const user = auth.currentUser;
    if (user === null) {
      return;
    }
    try {
      await updateDoc(doc(db, 'conversations', conversationId), {
        [`unread.${user.uid}`]: 0,
      });
    } catch (error) {
      const code = errorCodeOf(error);
      if (code === 'not-found') {
        return;
      }
      throw new ChatFailure(mapChatCode(code));
    }
  }

  /** Public name of a user (`users/{uid}`), or null if there is none. */
  async getUserName(uid: string): Promise<string | null> {
    if (uid.length === 0) {
      return null;
    }
    try {
      const snapshot = await getDoc(doc(db, 'users', uid));
      const name = snapshot.data()?.displayName;
      if (typeof name !== 'string' || name.trim().length === 0) {
        return null;
      }
      return name.trim();
    } catch (error) {
      throw new ChatFailure(mapChatCode(errorCodeOf(error)));
    }
  }
}

export const chatRepository = new ChatRepository();