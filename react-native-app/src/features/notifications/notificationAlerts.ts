import { UnreadConversation } from '../../data/repositories/unreadRepository';

/** Unread count by conversation id, from the previous snapshot. */
export type UnreadSnapshot = Record<string, number>;

export function toSnapshot(items: UnreadConversation[]): UnreadSnapshot {
  const snapshot: UnreadSnapshot = {};
  for (const item of items) {
    snapshot[item.id] = item.unread;
  }
  return snapshot;
}

/**
 * Conversations that received a new message since the previous snapshot.
 * The first snapshot (previous === null) never alerts: messages that were
 * already unread when the app opened are shown by the badge only.
 */
export function newMessageAlerts(
  previous: UnreadSnapshot | null,
  items: UnreadConversation[],
): UnreadConversation[] {
  if (previous === null) {
    return [];
  }
  return items.filter(item => item.unread > (previous[item.id] ?? 0));
}

/** Number shown on the unread badge. */
export function totalUnread(items: UnreadConversation[]): number {
  return items.reduce((sum, item) => sum + item.unread, 0);
}
