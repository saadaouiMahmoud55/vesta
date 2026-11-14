import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/core/theme/app_colors.dart';
import 'package:flutterapp/core/widgets/app_text_field.dart';
import 'package:flutterapp/core/widgets/offer_type_badge.dart';
import 'package:flutterapp/core/widgets/price_text.dart';
import 'package:flutterapp/core/widgets/rtl_helpers.dart';
import 'package:flutterapp/features/favorites/favorite_button.dart';
import 'package:flutterapp/features/listings/listing.dart';
import 'package:flutterapp/features/listings/listing_card.dart';
import 'package:flutterapp/l10n/generated/app_localizations.dart';

const _sale = Listing(
  id: 'l1',
  ownerId: 'u1',
  title: 'Villa in Hammamet',
  description: '',
  price: 650000,
  currency: 'TND',
  listingType: 'sale',
  propertyType: 'villa',
  city: 'Hammamet',
  status: 'available',
  photoCount: 0,
  bedrooms: 4,
  bathrooms: 3,
  areaSqm: 220,
);

const _rent = Listing(
  id: 'l1',
  ownerId: 'u1',
  title: 'Flat in La Marsa',
  description: '',
  price: 1200,
  currency: 'TND',
  listingType: 'rent',
  rentPeriod: 'month',
  propertyType: 'apartment',
  city: 'La Marsa',
  status: 'available',
  photoCount: 0,
);

const _stay = Listing(
  id: 'l1',
  ownerId: 'u1',
  title: 'Riad in Tozeur',
  description: '',
  price: 120,
  currency: 'TND',
  listingType: 'rent',
  rentPeriod: 'night',
  propertyType: 'riad',
  city: 'Tozeur',
  status: 'available',
  photoCount: 0,
);

const _soldHouse = Listing(
  id: 'l1',
  ownerId: 'u1',
  title: 'Sold house',
  description: '',
  price: 300000,
  currency: 'TND',
  listingType: 'sale',
  propertyType: 'house',
  city: 'Sfax',
  status: 'sold',
  photoCount: 0,
);

/// Shows [child] in a small app with the real translations. No Firebase.
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        listingCoverPhotoProvider('l1')
            .overrideWith((ref) => Future<String?>.value(null)),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(width: 400, child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('keyFactsOf', () {
    test('lists bedrooms, bathrooms and area when they are filled', () {
      final facts = keyFactsOf(_sale);
      expect(facts.map((fact) => fact.value), ['4', '3', '220 m²']);
      expect(facts[0].icon, Icons.bed_outlined);
      expect(facts[1].icon, Icons.bathtub_outlined);
      expect(facts[2].icon, Icons.square_foot);
    });

    test('skips the facts that are empty', () {
      const onlyArea = Listing(
        id: 'l2',
        ownerId: 'u1',
        title: 'Land',
        description: '',
        price: 90000,
        currency: 'TND',
        listingType: 'sale',
        propertyType: 'land',
        city: 'Nabeul',
        status: 'available',
        photoCount: 0,
        areaSqm: 85.5,
      );
      expect(keyFactsOf(onlyArea).map((fact) => fact.value), ['85.5 m²']);
    });

    test('is empty when nothing is filled', () {
      expect(keyFactsOf(_rent), isEmpty);
    });

    test('a whole number has no decimal', () {
      const twoRooms = Listing(
        id: 'l3',
        ownerId: 'u1',
        title: 'Studio',
        description: '',
        price: 700,
        currency: 'TND',
        listingType: 'rent',
        rentPeriod: 'month',
        propertyType: 'studio',
        city: 'Tunis',
        status: 'available',
        photoCount: 0,
        bedrooms: 2.0,
      );
      expect(keyFactsOf(twoRooms).single.value, '2');
    });
  });

  group('PriceText', () {
    testWidgets('a sale has no unit', (tester) async {
      await _pump(tester, const PriceText(price: 650000, currency: 'TND'));
      expect(find.text('TND 650,000', findRichText: true), findsOneWidget);
    });

    testWidgets('shows the unit of a rent and of a stay', (tester) async {
      await _pump(
        tester,
        const Column(
          children: [
            PriceText(price: 1200, currency: 'TND', period: 'month'),
            PriceText(price: 120, currency: 'TND', period: 'night'),
            PriceText(price: 12000, currency: 'TND', period: 'year'),
          ],
        ),
      );
      expect(
        find.text('TND 1,200 / month', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('TND 120 / night', findRichText: true), findsOneWidget);
      expect(
        find.text('TND 12,000 / year', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('uses TND when the currency is empty', (tester) async {
      await _pump(tester, const PriceText(price: 100, currency: ''));
      expect(find.text('TND 100', findRichText: true), findsOneWidget);
    });

    testWidgets('translates the unit in French', (tester) async {
      await _pump(
        tester,
        const PriceText(price: 120, currency: 'TND', period: 'night'),
        locale: const Locale('fr'),
      );
      expect(find.text('TND 120 / nuit', findRichText: true), findsOneWidget);
    });

    testWidgets('stays left-to-right in Arabic', (tester) async {
      await _pump(
        tester,
        const PriceText(price: 120, currency: 'TND', period: 'night'),
        locale: const Locale('ar'),
      );
      expect(find.text('TND 120 / ليلة', findRichText: true), findsOneWidget);
      final direction = tester.widget<Directionality>(
        find
            .descendant(
              of: find.byType(PriceText),
              matching: find.byType(Directionality),
            )
            .first,
      );
      expect(direction.textDirection, TextDirection.ltr);
    });
  });

  group('OfferTypeBadge', () {
    test('uses the color of each offer type', () {
      expect(OfferTypeBadge.colorOf(OfferType.stay), AppColors.primary);
      expect(OfferTypeBadge.colorOf(OfferType.rent), AppColors.navy);
      expect(OfferTypeBadge.colorOf(OfferType.sale), AppColors.terracotta);
    });

    testWidgets('shows the English labels', (tester) async {
      await _pump(
        tester,
        const Column(
          children: [
            OfferTypeBadge(type: OfferType.sale),
            OfferTypeBadge(type: OfferType.rent),
            OfferTypeBadge(type: OfferType.stay),
          ],
        ),
      );
      expect(find.text('For sale'), findsOneWidget);
      expect(find.text('For rent'), findsOneWidget);
      expect(find.text('Stay'), findsOneWidget);
    });

    testWidgets('shows the French and Arabic labels', (tester) async {
      await _pump(
        tester,
        const OfferTypeBadge(type: OfferType.stay),
        locale: const Locale('fr'),
      );
      expect(find.text('Séjour'), findsOneWidget);

      await _pump(
        tester,
        const OfferTypeBadge(type: OfferType.sale),
        locale: const Locale('ar'),
      );
      expect(find.text('للبيع'), findsOneWidget);
    });

    testWidgets('paints the ribbon with the color of the type', (tester) async {
      await _pump(tester, const OfferTypeBadge(type: OfferType.sale));
      final ribbon = tester.widget<Container>(
        find.descendant(
          of: find.byType(OfferTypeBadge),
          matching: find.byType(Container),
        ),
      );
      expect((ribbon.decoration as BoxDecoration).color, AppColors.terracotta);
    });
  });

  group('ListingCard', () {
    testWidgets('shows a sale: ribbon, key facts and price without unit', (
      tester,
    ) async {
      await _pump(
        tester,
        const ListingCard(listing: _sale, showFavorite: false),
      );
      expect(find.text('Villa in Hammamet'), findsOneWidget);
      expect(find.text('Hammamet'), findsOneWidget);
      expect(find.text('For sale'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('220 m²'), findsOneWidget);
      expect(find.text('TND 650,000', findRichText: true), findsOneWidget);
    });

    testWidgets('shows a rent per month and a stay per night', (tester) async {
      await _pump(
        tester,
        const ListingCard(listing: _rent, showFavorite: false),
      );
      expect(find.text('For rent'), findsOneWidget);
      expect(
        find.text('TND 1,200 / month', findRichText: true),
        findsOneWidget,
      );

      await _pump(
        tester,
        const ListingCard(listing: _stay, showFavorite: false),
      );
      expect(find.text('Stay'), findsOneWidget);
      expect(find.text('TND 120 / night', findRichText: true), findsOneWidget);
    });

    testWidgets('shows no heart when showFavorite is false', (tester) async {
      await _pump(
        tester,
        const ListingCard(listing: _sale, showFavorite: false),
      );
      expect(find.byType(FavoriteButton), findsNothing);
    });

    testWidgets('marks an unavailable listing', (tester) async {
      await _pump(
        tester,
        const ListingCard(listing: _soldHouse, showFavorite: false),
      );
      expect(find.text('This listing is no longer available'), findsOneWidget);
    });

    testWidgets('calls onTap when it is tapped', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        ListingCard(listing: _sale, showFavorite: false, onTap: () => taps++),
      );
      await tester.tap(find.byType(InkWell));
      expect(taps, 1);
    });

    testWidgets('translates the ribbon and the unit in Arabic', (tester) async {
      await _pump(
        tester,
        const ListingCard(listing: _stay, showFavorite: false),
        locale: const Locale('ar'),
      );
      expect(find.text('إقامة'), findsOneWidget);
      expect(find.text('TND 120 / ليلة', findRichText: true), findsOneWidget);
    });
  });
  group('AppTextField with ltr', () {
    Future<void> pumpField(WidgetTester tester, {required bool ltr}) {
      return tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: AppTextField(
                label: '+216',
                hintText: '+216 20 123 456',
                ltr: ltr,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('keeps the label and the hint left-to-right in RTL', (
      tester,
    ) async {
      await pumpField(tester, ltr: true);

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration?.hintTextDirection, TextDirection.ltr);

      final labelDirection = tester.widget<Directionality>(
        find
            .ancestor(
              of: find.text('+216'),
              matching: find.byType(Directionality),
            )
            .first,
      );
      expect(labelDirection.textDirection, TextDirection.ltr);
    });

    testWidgets('does not change the hint and the label without ltr', (
      tester,
    ) async {
      await pumpField(tester, ltr: false);

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration?.hintTextDirection, isNull);
      expect(find.byType(LtrText), findsNothing);
    });
  });
}
