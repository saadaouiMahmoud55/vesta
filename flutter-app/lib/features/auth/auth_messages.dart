import '../../l10n/generated/app_localizations.dart';
import 'auth_repository.dart';

/// Turns an [AuthError] into a translated message (no hard-coded text).
String authErrorMessage(AppLocalizations l10n, AuthError error) {
  return switch (error) {
    AuthError.invalidEmail => l10n.authErrorInvalidEmail,
    AuthError.passwordTooShort => l10n.authErrorPasswordShort,
    AuthError.nameRequired => l10n.authErrorNameRequired,
    AuthError.emailInUse => l10n.authErrorEmailInUse,
    AuthError.wrongPassword => l10n.authErrorWrongPassword,
    AuthError.noNetwork => l10n.authErrorNoNetwork,
    AuthError.tooManyRequests => l10n.authErrorTooManyRequests,
    AuthError.unknown => l10n.authErrorUnknown,
  };
}

String? authErrorOrNull(AppLocalizations l10n, AuthError? error) =>
    error == null ? null : authErrorMessage(l10n, error);
