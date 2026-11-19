import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'listing.dart';
import 'listing_repository.dart';

final listingRepositoryProvider = Provider<ListingRepository>(
  (ref) => ListingRepository(),
);

/// Form validation errors. The screen turns them into translated messages.
enum ListingFieldError {
  titleRequired,
  descriptionRequired,
  priceInvalid,
  cityRequired,
  rentPeriodRequired,
  numberInvalid,
  guestsInvalid,
  roomsInvalid,
}

ListingFieldError? validateTitle(String? v) =>
    (v ?? '').trim().isEmpty ? ListingFieldError.titleRequired : null;

ListingFieldError? validateDescription(String? v) =>
    (v ?? '').trim().isEmpty ? ListingFieldError.descriptionRequired : null;

ListingFieldError? validateCity(String? v) =>
    (v ?? '').trim().isEmpty ? ListingFieldError.cityRequired : null;

/// Highest price accepted for a listing, in TND (VST-104).
/// Keep in sync with the price rule in firebase/firestore.rules.
const maxListingPrice = 50000000;

/// Price must be a finite number greater than 0 and at most
/// [maxListingPrice]. `num.tryParse` accepts "NaN" and "Infinity", and NaN
/// passes every comparison below, so it is rejected with [num.isFinite].
ListingFieldError? validatePrice(String? v) {
  final price = num.tryParse((v ?? '').trim());
  return (price == null ||
          !price.isFinite ||
          price <= 0 ||
          price > maxListingPrice)
      ? ListingFieldError.priceInvalid
      : null;
}

/// Optional number (bedrooms, bathrooms, area): empty is fine,
/// otherwise it must be a number >= 0.
ListingFieldError? validateOptionalNumber(String? v) {
  final text = (v ?? '').trim();
  if (text.isEmpty) return null;
  final n = num.tryParse(text);
  return (n == null || n < 0) ? ListingFieldError.numberInvalid : null;
}
/// Guests: optional, a whole number from 1 to [maxGuestsLimit].
ListingFieldError? validateGuests(String? v) {
  final text = (v ?? '').trim();
  if (text.isEmpty) return null;
  final n = int.tryParse(text);
  return (n == null || n < 1 || n > maxGuestsLimit)
      ? ListingFieldError.guestsInvalid
      : null;
}

/// Bedrooms and bathrooms: optional, a whole number from 0 to [maxRoomsLimit].
ListingFieldError? validateRooms(String? v) {
  final text = (v ?? '').trim();
  if (text.isEmpty) return null;
  final n = int.tryParse(text);
  return (n == null || n < 0 || n > maxRoomsLimit)
      ? ListingFieldError.roomsInvalid
      : null;
}

/// Rent period is required only for a rental.
ListingFieldError? validateRentPeriod(String? listingType, String? period) =>
    (listingType == 'rent' && period == null)
        ? ListingFieldError.rentPeriodRequired
        : null;

class PublishState {
  const PublishState({this.isLoading = false, this.error, this.publishedId});

  final bool isLoading;
  final ListingError? error;
  final String? publishedId; // set on success
}

class ListingController extends Notifier<PublishState> {
  @override
  PublishState build() => const PublishState();

  ListingRepository get _repository => ref.read(listingRepositoryProvider);

  /// Returns true when the listing was created.
  Future<bool> publish({
    required NewListing listing,
    required List<String> photosBase64,
  }) async {
    if (state.isLoading) return false; // no double submit
    state = const PublishState(isLoading: true);
    try {
      final id = await _repository.createListing(
        listing: listing,
        photosBase64: photosBase64,
      );
      state = PublishState(publishedId: id);
      return true;
    } on ListingFailure catch (e) {
      state = PublishState(error: e.error);
    } catch (_) {
      state = const PublishState(error: ListingError.unknown);
    }
    return false;
  }

  /// Returns true when the listing edit was saved.
  Future<bool> update({
    required String listingId,
    required NewListing listing,
    required List<String> photosBase64,
    required List<String> originalPhotos,
  }) async {
    if (state.isLoading) return false;
    state = const PublishState(isLoading: true);
    try {
      await _repository.updateListing(
        listingId: listingId,
        listing: listing,
        photosBase64: photosBase64,
        originalPhotos: originalPhotos,
      );
      state = const PublishState();
      return true;
    } on ListingFailure catch (e) {
      state = PublishState(error: e.error);
    } catch (_) {
      state = const PublishState(error: ListingError.unknown);
    }
    return false;
  }

  void reset() => state = const PublishState();
}

final listingControllerProvider =
    NotifierProvider<ListingController, PublishState>(ListingController.new);

/// One listing with its decoded photos, ready for the details screen.
class ListingDetail {
  const ListingDetail({required this.listing, required this.photos});

  final Listing listing;
  final List<Uint8List> photos;
}

/// Loads one listing and its photos. Null when the listing does not exist.
/// Decoding happens here, once, so the screen never decodes in `build`.
final listingDetailProvider =
    FutureProvider.autoDispose.family<ListingDetail?, String>((ref, id) async {
  final repository = ref.read(listingRepositoryProvider);
  final listing = await repository.getListing(id);
  if (listing == null) return null;

  final encoded = await repository.getPhotos(id);
  final photos = <Uint8List>[];
  for (final text in encoded) {
    try {
      photos.add(base64Decode(text));
    } on FormatException {
      // A damaged photo is skipped, the others still show.
    }
  }
  return ListingDetail(listing: listing, photos: photos);
});
