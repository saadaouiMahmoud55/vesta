import { collection, onSnapshot, query, where } from 'firebase/firestore';
import { auth, db } from '../firebase';
import { errorCodeOf } from './authErrors';

/** What the alerts need from a conversation (docs/data-model.md). */
export type UnreadConversation = {
  id: string;
  listingId: string;
  lastMessage: string;
  /** Messages the signed-in user has not read yet (own uid in `unread`). */
  unread: number;
};

/**
 * Live list of the signed-in user's conversations: participantIds
 * array-contains uid, so the rules (participants only) accept it and no
 * composite index is needed. Returns the function that stops the listener.
 */
export function watchUnreadConversations(
  onChange: (items: UnreadConversation[]) => void,
  onError: (code: string) => void,
): () => void {
  const uid = auth.currentUser?.uid;
  if (!uid) {
    onChange([]);
    return () => undefined;
  }
  return onSnapshot(
    query(
      collection(db, 'conversations'),
      where('participantIds', 'array-contains', uid),
    ),
    snapshot => {
      onChange(
        snapshot.docs.map(item => {
          const data = item.data();
          const counts = data.unread as Record<string, unknown> | undefined;
          const mine = counts?.[uid];
          return {
            id: item.id,
            listingId: typeof data.listingId === 'string' ? data.listingId : '',
            lastMessage:
              typeof data.lastMessage === 'string' ? data.lastMessage : '',
            unread: typeof mine === 'number' ? mine : 0,
          };
        }),
      );
    },
    error => onError(errorCodeOf(error)),
  );
}
