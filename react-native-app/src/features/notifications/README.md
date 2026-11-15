# Notifications

Notification screens and controllers belong here. Screens call a controller; controllers call repositories in `src/data/`; repositories access Firebase. Screens never access Firebase directly.

## Limits

- No server push: there is no backend that sends notifications (same as the Flutter app, VST-99). An alert is a local notification shown when the Firestore listener sees a higher unread counter, so it only works while the app is running (open or in the background). A closed app gets nothing until it is opened again.
- The first snapshot after sign-in never alerts: messages already unread are shown by the badge only.
- If the user refuses the permission, no system notification is shown; the badge still works.
- Expo Go (SDK 57, Android) shows a warning that `expo-notifications` is not fully supported. The badge worked, but no local notification was shown in Expo Go; a development build is needed to test it.
