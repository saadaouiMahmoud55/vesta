import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/features/chat/chat_controller.dart';
import 'package:flutterapp/features/listings/listing.dart';
import 'package:flutterapp/features/listings/listing_controller.dart';
import 'package:flutterapp/features/listings/listing_detail_screen.dart';
import 'package:flutterapp/l10n/generated/app_localizations.dart';

const _sale = Listing(
  id: 'l1',
  ownerId: 'u1',
  title: 'Sea view flat',
  description: 'Bright flat close to the beach.',
  price: 120000,
  currency: 'TND',
  listingType: 'sale',
  propertyType: 'apartment',
  city: 'Sousse',
  bedrooms: 2,
  bathrooms: 1,
  areaSqm: 85,
  photoCount: 0,
  status: 'available',
);

const _rent = Listing(
  id: 'l1',
  ownerId: 'u1',
  title: 'Studio near the station',
  description: 'Quiet studio.',
  price: 900,
  currency: 'TND',
  listingType: 'rent',
  rentPeriod: 'month',
  propertyType: 'studio',
  city: 'Tunis',
  photoCount: 0,
  status: 'available',
);

const _sold = Listing(
  id: 'l1',
  ownerId: 'u1',
  title: 'Sold house',
  description: 'Already sold.',
  price: 300000,
  currency: 'TND',
  listingType: 'sale',
  propertyType: 'house',
  city: 'Sfax',
  photoCount: 0,
  status: 'sold',
);

const _stay = Listing(
  id: 'l1',
  ownerId: 'u1',
  title: 'Beach house stay',
  description: 'Close to the sea.',
  price: 150,
  currency: 'TND',
  listingType: 'rent',
  rentPeriod: 'night',
  propertyType: 'house',
  city: 'Djerba',
  photoCount: 0,
  status: 'available',
);

/// Shows the details screen with a fake loader, so no Firebase is needed.
Future<void> _pumpDetail(
  WidgetTester tester,
  Future<ListingDetail?> Function() load, {
  Locale locale = const Locale('en'),
  bool settle = true,
  String? myUid,
}) async {
  // Tall test screen: the 4:3 photo area is 600 px high on an 800 px wide
  // screen and would hide the texts below it from the lazy ListView.
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        listingDetailProvider('l1').overrideWith((ref) => load()),
        myUidProvider.overrideWithValue(myUid),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: ListingDetailScreen(listingId: 'l1')),
      ),
    ),
  );
  if (settle) await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows a loader, then the sale listing', (tester) async {
    await _pumpDetail(
      tester,
      () async => const ListingDetail(listing: _sale, photos: []),
      settle: false,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Sea view flat'), findsOneWidget);
    expect(find.text('Sousse'), findsOneWidget);
    expect(find.text('Bright flat close to the beach.'), findsOneWidget);
    expect(find.textContaining('120'), findsOneWidget);
    // "At a glance" tiles: the value and the label are separate texts.
    expect(find.text('Bedrooms'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Bathrooms'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('85'), findsOneWidget);
    expect(find.text('No photo'), findsOneWidget);
  });

  testWidgets('shows the unit for a monthly rental', (tester) async {
    await _pumpDetail(
      tester,
      () async => const ListingDetail(listing: _rent, photos: []),
    );
    expect(find.text('Studio near the station'), findsOneWidget);
    expect(find.textContaining('/ month'), findsOneWidget);
  });

  testWidgets('shows a banner when the listing is unavailable',
      (tester) async {
    await _pumpDetail(
      tester,
      () async => const ListingDetail(listing: _sold, photos: []),
    );
    expect(find.text('This listing is no longer available'), findsOneWidget);
  });

  testWidgets('shows the unit for a stay (per night)', (tester) async {
    await _pumpDetail(
      tester,
      () async => const ListingDetail(listing: _stay, photos: []),
    );
    expect(find.textContaining('/ night'), findsOneWidget);
  });

  testWidgets('shows no banner for an available listing', (tester) async {
    await _pumpDetail(
      tester,
      () async => const ListingDetail(listing: _sale, photos: []),
    );
    expect(find.text('This listing is no longer available'), findsNothing);
  });

  testWidgets('shows a message when the listing does not exist',
      (tester) async {
    await _pumpDetail(tester, () async => null);
    expect(find.text('Listing not found'), findsOneWidget);
  });

  testWidgets('shows an error message and a retry button', (tester) async {
    await _pumpDetail(tester, () async => throw Exception('boom'));
    expect(find.text('Could not load this listing.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('texts are translated in French and Arabic', (tester) async {
    await _pumpDetail(tester, () async => null, locale: const Locale('fr'));
    expect(find.text('Annonce introuvable'), findsOneWidget);

    await _pumpDetail(tester, () async => null, locale: const Locale('ar'));
    expect(find.text('الإعلان غير موجود'), findsOneWidget);
  });

  testWidgets('a guest sees Contact owner (VST-44)', (tester) async {
    await _pumpDetail(
      tester,
      () async => const ListingDetail(listing: _sale, photos: []),
    );
    expect(find.text('Contact owner'), findsOneWidget);
  });

  testWidgets('another user sees Contact owner (VST-44)', (tester) async {
    await _pumpDetail(
      tester,
      () async => const ListingDetail(listing: _sale, photos: []),
      myUid: 'someone-else',
    );
    expect(find.text('Contact owner'), findsOneWidget);
  });

  testWidgets('the owner does not see Contact owner (VST-44)', (tester) async {
    await _pumpDetail(
      tester,
      () async => const ListingDetail(listing: _sale, photos: []),
      myUid: 'u1',
    );
    expect(find.text('Sea view flat'), findsOneWidget);
    expect(find.text('Contact owner'), findsNothing);
  });
}
