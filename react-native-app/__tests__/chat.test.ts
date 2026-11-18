import {
  ChatMessage,
  Conversation,
  conversationFromData,
  conversationIdFor,
  maxMessageLength,
  messageFromData,
  messagesPageSize,
  otherUserId,
  parseConversationId,
  sortNewestFirst,
  textDirectionFor,
  totalUnread,
  unreadFor,
} from '../src/data/models/chat';
import {
  ChatFailure,
  chatErrorKey,
  mapChatCode,
} from '../src/data/repositories/chatErrors';

// Arabic "hello" (marhaba), written with escapes to avoid encoding problems.
const arabic = '\u0645\u0631\u062d\u0628\u0627';

const conversation = (
  id: string,
  lastMessageAt: Date | null,
  unread: Record<string, number> = {},
): Conversation => ({
  id,
  listingId: 'l1',
  participantIds: ['buyer', 'owner'],
  lastMessage: '',
  lastMessageAt,
  unread,
});

describe('chat models (same rules as the Flutter chat)', () => {
  it('keeps the same limits as Flutter', () => {
    expect(maxMessageLength).toBe(2000);
    expect(messagesPageSize).toBe(50);
  });

  it('builds and splits the conversation id', () => {
    expect(conversationIdFor('l1', 'u1')).toBe('l1_u1');
    expect(parseConversationId('l1_u1')).toEqual({
      listingId: 'l1',
      buyerId: 'u1',
    });
  });

  it('refuses an id that is not a conversation id', () => {
    expect(parseConversationId('nounderscore')).toBeNull();
    expect(parseConversationId('_u1')).toBeNull();
    expect(parseConversationId('l1_')).toBeNull();
  });

  it('follows the first letter for the text direction', () => {
    expect(textDirectionFor('Salut')).toBe('ltr');
    expect(textDirectionFor('\u00e9t\u00e9')).toBe('ltr');
    expect(textDirectionFor(arabic)).toBe('rtl');
  });

  it('decides the direction of mixed text with the first letter', () => {
    expect(textDirectionFor(`Salut ${arabic}`)).toBe('ltr');
    expect(textDirectionFor(`${arabic} Salut`)).toBe('rtl');
    expect(textDirectionFor(`\u0661\u0662 ${arabic}`)).toBe('rtl');
  });

  it('uses the fallback for text without letters', () => {
    expect(textDirectionFor('123')).toBe('ltr');
    expect(textDirectionFor('123', 'rtl')).toBe('rtl');
    expect(textDirectionFor('')).toBe('ltr');
    expect(textDirectionFor('\u0661\u0662', 'rtl')).toBe('rtl');
  });

  it('sorts newest first and puts a pending send (null) first', () => {
    const sorted = sortNewestFirst([
      conversation('a', new Date(1000)),
      conversation('b', new Date(3000)),
      conversation('c', null),
      conversation('d', new Date(2000)),
    ]);
    expect(sorted.map(item => item.id)).toEqual(['c', 'b', 'd', 'a']);
  });

  it('finds the other person of a conversation', () => {
    const item = conversation('a', null);
    expect(otherUserId(item, 'buyer')).toBe('owner');
    expect(otherUserId(item, 'owner')).toBe('buyer');
    expect(otherUserId({ ...item, participantIds: [] }, 'buyer')).toBe('');
  });

  it('counts the unread messages', () => {
    const list = [
      conversation('a', null, { buyer: 2, owner: 1 }),
      conversation('b', null, { buyer: 3 }),
      conversation('c', null),
    ];
    expect(unreadFor(list[0], 'buyer')).toBe(2);
    expect(unreadFor(list[2], 'buyer')).toBe(0);
    expect(totalUnread(list, 'buyer')).toBe(5);
    expect(totalUnread(list, 'owner')).toBe(1);
  });

  it('reads a conversation document and ignores bad values', () => {
    const date = new Date(5000);
    const item = conversationFromData('l1_buyer', {
      listingId: 'l1',
      participantIds: ['buyer', 'owner', 5],
      lastMessage: 'Hi',
      lastMessageAt: { toDate: () => date },
      unread: { owner: 2, buyer: 'x' },
    });
    expect(item).toEqual({
      id: 'l1_buyer',
      listingId: 'l1',
      participantIds: ['buyer', 'owner'],
      lastMessage: 'Hi',
      lastMessageAt: date,
      unread: { owner: 2 },
    });
  });

  it('uses safe defaults for empty documents', () => {
    expect(conversationFromData('x', undefined)).toEqual({
      id: 'x',
      listingId: '',
      participantIds: [],
      lastMessage: '',
      lastMessageAt: null,
      unread: {},
    });
    const message: ChatMessage = messageFromData('m1', undefined);
    expect(message).toEqual({
      id: 'm1',
      senderId: '',
      text: '',
      createdAt: null,
    });
  });
});

describe('chat errors (same mapping as the Flutter ChatRepository)', () => {
  it('maps the Firestore codes', () => {
    expect(mapChatCode('permission-denied')).toBe('permissionDenied');
    expect(mapChatCode('unavailable')).toBe('noNetwork');
    expect(mapChatCode('deadline-exceeded')).toBe('noNetwork');
    expect(mapChatCode('network-request-failed')).toBe('noNetwork');
    expect(mapChatCode('unauthenticated')).toBe('notSignedIn');
    expect(mapChatCode('something-new')).toBe('unknown');
  });

  it('gives a translation key for every error', () => {
    expect(chatErrorKey('ownListing')).toBe('chatOwnListing');
    expect(chatErrorKey('noNetwork')).toBe('chatSendError');
    expect(chatErrorKey('messageTooLong')).toBe('chatSendFailed');
    expect(chatErrorKey('permissionDenied')).toBe('chatSendFailed');
    expect(chatErrorKey('notSignedIn')).toBe('chatContactError');
    expect(chatErrorKey('unknown')).toBe('chatContactError');
  });

  it('carries the error in a ChatFailure', () => {
    const failure = new ChatFailure('ownListing');
    expect(failure).toBeInstanceOf(Error);
    expect(failure.error).toBe('ownListing');
  });
});