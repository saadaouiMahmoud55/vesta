import * as Notifications from 'expo-notifications';
import { Platform } from 'react-native';

const CHANNEL_ID = 'messages';

// Show the notification even when the app is open (this is the banner).
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowBanner: true,
    shouldShowList: true,
    shouldPlaySound: false,
    shouldSetBadge: false,
  }),
});

/**
 * Creates the Android channel, then asks for the permission (Android 13+
 * needs the channel first). Returns false when the user refuses: the app
 * keeps working, only the system notification is skipped (the badge stays).
 */
export async function prepareNotifications(
  channelName: string,
): Promise<boolean> {
  try {
    if (Platform.OS === 'android') {
      await Notifications.setNotificationChannelAsync(CHANNEL_ID, {
        name: channelName,
        importance: Notifications.AndroidImportance.DEFAULT,
      });
    }
    const current = await Notifications.getPermissionsAsync();
    if (current.granted) {
      return true;
    }
    if (!current.canAskAgain) {
      return false;
    }
    const asked = await Notifications.requestPermissionsAsync();
    return asked.granted;
  } catch {
    return false;
  }
}

/** Local notification for a new message. No server push (see README). */
export async function showMessageAlert(
  title: string,
  body: string,
  conversationId: string,
): Promise<void> {
  try {
    const permission = await Notifications.getPermissionsAsync();
    if (!permission.granted) {
      return;
    }
    await Notifications.scheduleNotificationAsync({
      content: { title, body, data: { conversationId } },
      trigger: null,
    });
  } catch {
    // An alert that cannot be shown must never crash the app.
  }
}
