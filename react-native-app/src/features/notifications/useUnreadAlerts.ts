import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { watchUnreadConversations } from '../../data/repositories/unreadRepository';
import { useAuth } from '../auth/authController';
import {
  newMessageAlerts,
  toSnapshot,
  totalUnread,
  UnreadSnapshot,
} from './notificationAlerts';
import { prepareNotifications, showMessageAlert } from './notificationService';

/**
 * Listens to the unread counters while the user is signed in: returns the
 * total for the badge and shows a local notification for each new message.
 */
export function useUnreadAlerts(): number {
  const { isSignedIn } = useAuth();
  const { t } = useTranslation();
  const [count, setCount] = useState(0);
  const previous = useRef<UnreadSnapshot | null>(null);

  useEffect(() => {
    previous.current = null;
    if (!isSignedIn) {
      setCount(0);
      return undefined;
    }
    prepareNotifications(t('chatTitle')).catch(() => undefined);
    return watchUnreadConversations(
      items => {
        const alerts = newMessageAlerts(previous.current, items);
        previous.current = toSnapshot(items);
        setCount(totalUnread(items));
        for (const alert of alerts) {
          showMessageAlert(
            t('notificationsTitle'),
            alert.lastMessage,
            alert.id,
          ).catch(() => undefined);
        }
      },
      () => {
        // Listener error: keep the last badge, no alert.
      },
    );
  }, [isSignedIn, t]);

  return count;
}
