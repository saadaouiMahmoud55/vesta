# Profile

Not implemented in the React Native version. The Profile tab in `src/navigation/MainTabs.tsx` is a placeholder screen (it only shows the unread-message badge). Profile, edit profile, My listings, settings and account deletion exist in the Flutter app only (`flutter-app/lib/features/profile`, `flutter-app/lib/features/settings`).

To add it later, replace `ProfileTab` in `MainTabs.tsx` with a real screen. Keep the same flow as the other modules: screen → controller → repository in `src/data/repositories/` → Firebase. A screen never calls Firebase directly. The `users/{uid}` and `users/{uid}/private/contact` documents are already used by `authRepository`.
