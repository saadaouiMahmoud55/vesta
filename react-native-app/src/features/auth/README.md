# Authentication (VST-37)

Port of the Flutter authentication (VST-36): same screens, rules, error messages and Firestore fields.

`LoginScreen` / `SignUpScreen` → `AuthController` (`useAuth()`, context in `authController.tsx`) → `AuthRepository` (`src/data/repositories/authRepository.ts`) → Firebase Auth and Firestore. A screen never calls Firebase.

- Sign up creates the Auth account, then `users/{uid}` (`displayName`, `createdAt`) and `users/{uid}/private/contact` (`email`) in one batch. If the profile cannot be saved, the new Auth account is deleted.
- Password: 8 characters or more. Errors are mapped in `src/data/repositories/authErrors.ts` (same cases as Flutter) and shown with translation keys.
- The session is kept in AsyncStorage (`src/data/firebase.ts`). The root guard in `App.tsx` shows the auth stack when signed out.
- Not in this ticket (also in Flutter): forgot password and the email verification banner (VST-95), guest browsing (VST-72).
