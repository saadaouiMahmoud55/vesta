import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/features/chat/chat_controller.dart';
import 'package:flutterapp/features/listings/listing.dart';
import 'package:flutterapp/features/listings/listing_controller.dart';
import 'package:flutterapp/features/listings/listing_detail_screen.dart';
import 'package:flutterapp/l10n/generated/app_localizations.dart';

const _full = Listing(
  id: 'l1',
  ownerId: 'u1',
  title: 'Guest house test',
  description: 'Quiet house near the beach.',
  price: 180,
  currency: 'TND',
  listingType: 'rent',
  rentPeriod: 'night',
  propertyType: 'guest_house',
  city: 'Hammamet',
  photoCount: 0,
  status: 'available',
  maxGuests: 6,
  bedrooms: 3,
  bathrooms: 2,
  areaSqm: 120,
  amenities: ['wifi', 'pool', 'garden'],
  checkIn: '14:00',
  checkOut: '11:00',
  houseRules: ['no_smoking', 'quiet_hours'],
);

// An old listing: none of the VST-81 fields.
const _plain = Listing(
  id: 'l1',
  ownerId: 'u1',
  title: 'Old listing',
  description: 'Short text.',
  price: 120000,
  currency: 'TND',
  listingType: 'sale',
  propertyType: 'apartment',
  city: 'Sousse',
  photoCount: 0,
  status: 'available',
);

final _longText = List.filled(200, 'word').join(' ');

Future<void> _pump(
  WidgetTester tester,
  Listing listing, {
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // A guest: the screen reads the signed-in user (Contact owner, VST-44).
        myUidProvider.overrideWithValue(null),
        listingDetailProvider('l1').overrideWith(
          (ref) async => ListingDetail(listing: listing, photos: const []),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: ListingDetailScreen(listingId: 'l1')),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows facts, ticked amenities, times and rules',
      (tester) async {
    await _pump(tester, _full);

    expect(find.text('At a glance'), findsOneWidget);
    expect(find.text('Guests'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('120'), findsOneWidget);

    expect(find.text('Amenities'), findsOneWidget);
    expect(find.text('Wi-Fi'), findsOneWidget);
    expect(find.text('Pool'), findsOneWidget);
    expect(find.text('Garden'), findsOneWidget);
    // Not ticked by the owner: not shown.
    expect(find.text('Heating'), findsNothing);
    expect(find.text('TV'), findsNothing);

    expect(find.text('14:00'), findsOneWidget);
    expect(find.text('11:00'), findsOneWidget);

    expect(find.text('House rules'), findsOneWidget);
    expect(find.text('No smoking'), findsOneWidget);
    expect(find.text('Quiet hours'), findsOneWidget);
    expect(find.text('No pets'), findsNothing);
  });

  testWidgets('an old listing shows none of the new blocks', (tester) async {
    await _pump(tester, _plain);

    expect(find.text('Old listing'), findsOneWidget);
    expect(find.text('At a glance'), findsNothing);
    expect(find.text('Amenities'), findsNothing);
    expect(find.text('House rules'), findsNothing);
    expect(find.text('Check-in time'), findsNothing);
  });

  testWidgets('a long description can be expanded', (tester) async {
    await _pump(tester, _plain.copyWithDescription(_longText));

    expect(find.text('Read more'), findsOneWidget);
    await tester.tap(find.text('Read more'));
    await tester.pumpAndSettle();
    expect(find.text('Read less'), findsOneWidget);
    expect(find.text('Read more'), findsNothing);
  });

  testWidgets('a short description has no Read more button', (tester) async {
    await _pump(tester, _plain);
    expect(find.text('Read more'), findsNothing);
  });

  testWidgets('Arabic layout has no overflow', (tester) async {
    await _pump(
      tester,
      _full.copyWithDescription(_longText),
      locale: const Locale('ar'),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(Chip), findsWidgets);
  });
}

extension on Listing {
  /// Same listing, other description (test helper).
  Listing copyWithDescription(String text) => Listing(
        id: id,
        ownerId: ownerId,
        title: title,
        description: text,
        price: price,
        currency: currency,
        listingType: listingType,
        rentPeriod: rentPeriod,
        propertyType: propertyType,
        city: city,
        status: status,
        photoCount: photoCount,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        areaSqm: areaSqm,
        maxGuests: maxGuests,
        amenities: amenities,
        checkIn: checkIn,
        checkOut: checkOut,
        houseRules: houseRules,
      );
}
