import type { DocumentData } from 'firebase/firestore';

/** Longest message accepted by the rules (see firebase/firestore.rules). */
export const maxMessageLength = 2000;

/** How many messages a chat screen loads (VST-45). */
export const messagesPageSize = 50;

/**
 * Conversation id: one conversation per listing and per buyer
 * (docs/data-model.md). Neither part contains an underscore.
 */
export function conversationIdFor(listingId: string, buyerId: string): string {
  return `${listingId}_${buyerId}`;
}

/** Splits a conversation id back into its two parts, or null. */
export function parseConversationId(
  id: string,
): { listingId: string; buyerId: string } | null {
  const cut = id.lastIndexOf('_');
  if (cut <= 0 || cut === id.length - 1) {
    return null;
  }
  return { listingId: id.substring(0, cut), buyerId: id.substring(cut + 1) };
}

export type TextDir = 'ltr' | 'rtl';

function isArabicDigit(code: number): boolean {
  return (
    (code >= 0x0660 && code <= 0x0669) || (code >= 0x06f0 && code <= 0x06f9)
  );
}

function isRtlLetter(code: number): boolean {
  return (
    (code >= 0x0590 && code <= 0x08ff) ||
    (code >= 0xfb1d && code <= 0xfdff) ||
    (code >= 0xfe70 && code <= 0xfeff)
  );
}

function isLtrLetter(code: number): boolean {
  return (
    (code >= 0x41 && code <= 0x5a) ||
    (code >= 0x61 && code <= 0x7a) ||
    (code >= 0xc0 && code <= 0x24f && code !== 0xd7 && code !== 0xf7)
  );
}

/**
 * Text direction that follows the message itself, not the app language.
 * The first letter decides. Text without letters (digits, emoji) follows
 * the fallback.
 */
export function textDirectionFor(
  text: string,
  fallback: TextDir = 'ltr',
): TextDir {
  for (const char of text) {
    const code = char.codePointAt(0) ?? 0;
    if (isArabicDigit(code)) {
      continue;
    }
    if (isRtlLetter(code)) {
      return 'rtl';
    }
    if (isLtrLetter(code)) {
      return 'ltr';
    }
  }
  return fallback;
}

/** One conversation, as read from the `conversations` collection. */
export type Conversation = {
  id: string;
  listingId: string;
  /** Exactly 2 uids: [buyerId, ownerId]. */
  participantIds: string[];
  lastMessage: string;
  /** Null for a moment right after a send (the server has not answered). */
  lastMessageAt: Date | null;
  /** Unread messages per user: uid -> count. */
  unread: Record<string, number>;
};

/** One message of a conversation. */
export type ChatMessage = {
  id: string;
  senderId: string;
  text: string;
  /** Null while the message is still being sent. */
  createdAt: Date | null;
};

function toDate(value: unknown): Date | null {
  if (
    typeof value === 'object' &&
    value !== null &&
    typeof (value as { toDate?: unknown }).toDate === 'function'
  ) {
    return (value as { toDate: () => Date }).toDate();
  }
  return null;
}

export function conversationFromData(
  id: string,
  data: DocumentData | undefined,
): Conversation {
  const raw = data ?? {};
  const unread: Record<string, number> = {};
  if (typeof raw.unread === 'object' && raw.unread !== null) {
    for (const [uid, count] of Object.entries(raw.unread)) {
      if (typeof count === 'number') {
        unread[uid] = Math.trunc(count);
      }
    }
  }
  return {
    id,
    listingId: typeof raw.listingId === 'string' ? raw.listingId : '',
    participantIds: Array.isArray(raw.participantIds)
      ? raw.participantIds.filter(
          (item: unknown): item is string => typeof item === 'string',
        )
      : [],
    lastMessage: typeof raw.lastMessage === 'string' ? raw.lastMessage : '',
    lastMessageAt: toDate(raw.lastMessageAt),
    unread,
  };
}

export function messageFromData(
  id: string,
  data: DocumentData | undefined,
): ChatMessage {
  const raw = data ?? {};
  return {
    id,
    senderId: typeof raw.senderId === 'string' ? raw.senderId : '',
    text: typeof raw.text === 'string' ? raw.text : '',
    createdAt: toDate(raw.createdAt),
  };
}

/** The other person of the conversation, seen from myUid. */
export function otherUserId(conversation: Conversation, myUid: string): string {
  return conversation.participantIds.find(id => id !== myUid) ?? '';
}

export function unreadFor(conversation: Conversation, uid: string): number {
  return conversation.unread[uid] ?? 0;
}

/**
 * Newest conversation first. A conversation whose time is still null was
 * just written by this phone, so it is the newest.
 */
export function sortNewestFirst(conversations: Conversation[]): Conversation[] {
  return [...conversations].sort((a, b) => {
    const ta = a.lastMessageAt;
    const tb = b.lastMessageAt;
    if (ta === null && tb === null) {
      return 0;
    }
    if (ta === null) {
      return -1;
    }
    if (tb === null) {
      return 1;
    }
    return tb.getTime() - ta.getTime();
  });
}

/** Unread messages of uid over all the conversations (chat icon badge). */
export function totalUnread(conversations: Conversation[], uid: string): number {
  return conversations.reduce((total, c) => total + unreadFor(c, uid), 0);
}