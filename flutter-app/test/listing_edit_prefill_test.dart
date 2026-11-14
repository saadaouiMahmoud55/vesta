import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutterapp/features/listings/listing.dart';
import 'package:flutterapp/features/listings/listing_controller.dart';
import 'package:flutterapp/features/listings/listing_repository.dart';
import 'package:flutterapp/features/listings/publish_listing_screen.dart';
import 'package:flutterapp/l10n/generated/app_localizations.dart';

const _png =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

const _existing = Listing(
  id: 'l1',
  ownerId: 'u1',
  title: 'Sea view flat',
  description: 'Bright flat close to the beach.',
  price: 120000,
  currency: 'TND',
  listingType: 'sale',
  propertyType: 'apartment',
  city: 'Sousse',
  photoCount: 1,
  status: 'available',
);

class FakeRepo extends ListingRepository {
  int created = 0;
  int updated = 0;

  @override
  Future<Listing?> getListing(String id) async => _existing;

  @override
  Future<List<String>> getPhotos(String id) async => [_png];

  @override
  Future<({String phone, bool whatsapp})?> getContact(String id) async =>
      (phone: '+21620123456', whatsapp: true);

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
  }
}

Future<FakeRepo> _pump(WidgetTester tester) async {
  final fake = FakeRepo();
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/home',
        builder: (_, _) => Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => context.push('/edit'),
              child: const Text('Open edit'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/edit',
        builder: (_, _) => const PublishListingScreen(listingId: 'l1'),
      ),
    ],
    initialLocation: '/home',
  );
  addTearDown(router.dispose);

  tester.view.physicalSize = const Size(800, 6000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [listingRepositoryProvider.overrideWithValue(fake)],
      child: MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Open edit'));
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  testWidgets('edit form is pre-filled with the existing listing', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Sea view flat'), findsOneWidget);
    expect(find.text('Bright flat close to the beach.'), findsOneWidget);
    expect(find.text('120000'), findsOneWidget);
    expect(find.text('Sousse'), findsOneWidget);
    expect(find.text('20123456'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is MemoryImage,
      ),
      findsOneWidget,
    );
  });

  testWidgets('saving updates the listing and creates no second one', (
    tester,
  ) async {
    final fake = await _pump(tester);

    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(fake.updated, 1);
    expect(fake.created, 0);
  });
}
