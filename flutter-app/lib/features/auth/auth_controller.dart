import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

/// Current Firebase user (null when signed out). Used by the router guard.
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

// Field validation, shared by Login and Sign up.
AuthError? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  return valid ? null : AuthError.invalidEmail;
}

AuthError? validatePassword(String? value) =>
    (value ?? '').length >= 8 ? null : AuthError.passwordTooShort;

AuthError? validateName(String? value) =>
    (value ?? '').trim().isEmpty ? AuthError.nameRequired : null;

class AuthFormState {
  const AuthFormState({this.isLoading = false, this.error});

  final bool isLoading;
  final AuthError? error;
}

class AuthController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<bool> signIn(String email, String password) =>
      _run(() => _repository.signIn(email.trim(), password));

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) =>
      _run(
        () => _repository.signUp(
          email: email.trim(),
          password: password,
          displayName: displayName.trim(),
        ),
      );

  Future<void> signOut() => _repository.signOut();

  Future<bool> deleteAccount(String password) =>
      _run(() => _repository.deleteAccount(password));

  Future<bool> _run(Future<void> Function() action) async {
    if (state.isLoading) return false; // no double submit
    state = const AuthFormState(isLoading: true);
    try {
      await action();
      state = const AuthFormState();
      return true;
    } on AuthFailure catch (e) {
      state = AuthFormState(error: e.error);
    } catch (_) {
      state = const AuthFormState(error: AuthError.unknown);
    }
    return false;
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthFormState>(AuthController.new);
