import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/utils/phone_utils.dart';
import '../auth/auth_controller.dart';
import '../listings/listing_controller.dart';
import '../listings/listing_repository.dart';
import '../listings/listing.dart';
import '../listings/photo_service.dart';
import 'user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);

/// Public profile of the signed-in user (null when signed out), live.
final myProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchProfile(user.uid);
});

/// Listings of the signed-in user only, newest first, live.
final myListingsProvider = StreamProvider<List<Listing>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(listingRepositoryProvider).watchMyListings();
});

/// Name validation, used by the edit form.
ProfileError? validateDisplayName(String? value) =>
    (value ?? '').trim().isEmpty ? ProfileError.nameRequired : null;

/// Phone is optional, but if given it must be a Tunisian number.
ProfileError? validatePhone(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return null;
  return isValidTunisianPhone(text) ? null : ProfileError.phoneInvalid;
}

class ProfileFormState {
  const ProfileFormState({this.isLoading = false, this.error, this.photoError});

  final bool isLoading;
  final ProfileError? error;
  final PhotoError? photoError;
}

class ProfileController extends Notifier<ProfileFormState> {
  final PhotoService _photos = PhotoService();

  @override
  ProfileFormState build() => const ProfileFormState();

  UserRepository get _users => ref.read(userRepositoryProvider);
  ListingRepository get _listings => ref.read(listingRepositoryProvider);

  /// Opens the picker and returns the compressed square photo (base64),
  /// or null if cancelled or failed (then [photoError] is set).
  Future<String?> pickPhoto(ImageSource source) async {
    state = const ProfileFormState();
    try {
      return await _photos.pickProfilePhoto(source: source);
    } on PhotoFailure catch (e) {
      state = ProfileFormState(photoError: e.error);
    } catch (_) {
      state = const ProfileFormState(photoError: PhotoError.readFailed);
    }
    return null;
  }

  /// Returns true when the profile was saved.
  Future<bool> save({
    required String displayName,
    String? photoBase64,
    bool removePhoto = false,
    String? phone,
  }) async {
    final invalid = validateDisplayName(displayName) ?? validatePhone(phone);
    if (invalid != null) {
      state = ProfileFormState(error: invalid);
      return false;
    }
    return _run(
      () => _users.updateProfile(
        displayName: displayName,
        photoBase64: photoBase64,
        removePhoto: removePhoto,
        phone: phone,
      ),
    );
  }

  /// Returns true when the listing and its photos were deleted.
  Future<bool> deleteListing(Listing listing) =>
      _run(() => _listings.deleteListing(listing));

  /// Returns true when the status was changed.
  Future<bool> setStatus(Listing listing, String status) =>
      _run(() => _listings.updateStatus(listing, status));
  void clearError() => state = const ProfileFormState();

  Future<bool> _run(Future<void> Function() action) async {
    if (state.isLoading) return false; // no double submit
    state = const ProfileFormState(isLoading: true);
    try {
      await action();
      state = const ProfileFormState();
      return true;
    } on ProfileFailure catch (e) {
      state = ProfileFormState(error: e.error);
    } on ListingFailure catch (e) {
      state = ProfileFormState(error: _fromListing(e.error));
    } catch (_) {
      state = const ProfileFormState(error: ProfileError.unknown);
    }
    return false;
  }

  ProfileError _fromListing(ListingError error) {
    switch (error) {
      case ListingError.noNetwork:
        return ProfileError.noNetwork;
      case ListingError.permissionDenied:
        return ProfileError.permissionDenied;
      case ListingError.notSignedIn:
        return ProfileError.notSignedIn;
      default:
        return ProfileError.unknown;
    }
  }
}

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileFormState>(
      ProfileController.new,
    );
