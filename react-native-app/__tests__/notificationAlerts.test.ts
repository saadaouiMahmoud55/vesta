import {
  newMessageAlerts,
  toSnapshot,
  totalUnread,
} from '../src/features/notifications/notificationAlerts';
import { UnreadConversation } from '../src/data/repositories/unreadRepository';

const make = (id: string, unread: number): UnreadConversation => ({
  id,
  listingId: 'l1',
  lastMessage: 'Bonjour',
  unread,
});

test('the first snapshot never alerts', () => {
  expect(newMessageAlerts(null, [make('a', 3)])).toEqual([]);
});

test('a higher unread count alerts', () => {
  const previous = toSnapshot([make('a', 1), make('b', 0)]);
  const next = [make('a', 2), make('b', 0)];
  expect(newMessageAlerts(previous, next).map(item => item.id)).toEqual(['a']);
});

test('opening a chat (count back to 0) does not alert', () => {
  const previous = toSnapshot([make('a', 2)]);
  expect(newMessageAlerts(previous, [make('a', 0)])).toEqual([]);
});

test('a new conversation with an unread message alerts', () => {
  const previous = toSnapshot([make('a', 0)]);
  const next = [make('a', 0), make('b', 1)];
  expect(newMessageAlerts(previous, next).map(item => item.id)).toEqual(['b']);
});

test('an unchanged count does not alert', () => {
  const previous = toSnapshot([make('a', 2)]);
  expect(newMessageAlerts(previous, [make('a', 2)])).toEqual([]);
});

test('totalUnread adds the counts', () => {
  expect(totalUnread([make('a', 2), make('b', 3), make('c', 0)])).toBe(5);
});
