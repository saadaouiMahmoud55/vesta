import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/features/listings/listing_controller.dart';
import 'package:flutterapp/features/listings/listing_repository.dart';

/// Counts the calls. Never touches Firebase.
class FakeListingRepository extends ListingRepository {
  int created = 0;
  int updated = 0;
  String? updatedId;

  @override
  Future<String> createListing({
    required NewListing listing,
    required List<String> photosBase64,
  }) async {
    created++;
    return 'new-id';
  }

  @override
  Future<void> updateListing({
    required String listingId,
    required NewListing listing,
    required List<String> photosBase64,
    required List<String> originalPhotos,
  }) async {
    updated++;
    updatedId = listingId;
  }
}

NewListing _listing() => const NewListing(
  title: 'Villa',
  description: 'Belle villa',
  price: 450000,
  listingType: 'sale',
  propertyType: 'villa',
  city: 'Tunis',
);

void main() {
  test('saving an edit updates the listing and creates no second one', () async {
    final fake = FakeListingRepository();
    final container = ProviderContainer(
      overrides: [listingRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    final ok = await container.read(listingControllerProvider.notifier).update(
      listingId: 'abc',
      listing: _listing(),
      photosBase64: ['p0'],
      originalPhotos: ['p0'],
    );

    expect(ok, isTrue);
    expect(fake.updated, 1);
    expect(fake.updatedId, 'abc');
    expect(fake.created, 0);
  });
}
