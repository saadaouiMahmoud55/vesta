import '../../l10n/generated/app_localizations.dart';
import '../listings/photo_service.dart';
import 'user_repository.dart';

/// Turns a profile error into a translated message.
String profileErrorMessage(AppLocalizations l10n, ProfileError error) {
  switch (error) {
    case ProfileError.nameRequired:
      return l10n.profileErrorNameRequired;
    case ProfileError.phoneInvalid:
      return l10n.profileErrorPhoneInvalid;
    case ProfileError.noNetwork:
      return l10n.profileErrorNoNetwork;
    case ProfileError.permissionDenied:
      return l10n.profileErrorPermission;
    case ProfileError.notSignedIn:
      return l10n.profileErrorNotSignedIn;
    case ProfileError.unknown:
      return l10n.profileErrorUnknown;
  }
}

/// Turns a photo error into a translated message.
String profilePhotoErrorMessage(AppLocalizations l10n, PhotoError error) {
  switch (error) {
    case PhotoError.tooLarge:
      return l10n.profilePhotoErrorTooLarge;
    case PhotoError.readFailed:
    case PhotoError.tooManyPhotos:
      return l10n.profilePhotoErrorRead;
  }
}
