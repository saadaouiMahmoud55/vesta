import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/features/chat/chat_controller.dart';
import 'package:flutterapp/features/listings/contact_buttons.dart';
import 'package:flutterapp/features/listings/listing.dart';
import 'package:flutterapp/l10n/generated/app_localizations.dart';

const _listing = Listing(
  id: 'l1',
  ownerId: 'u1',
  title: 'Sea view flat',
  description: 'Bright flat close to the beach.',
  price: 120000,
  currency: 'TND',
  listingType: 'sale',
  propertyType: 'apartment',
  city: 'Sousse',
  photoCount: 0,
  status: 'available',
);

Future<void> _pump(
  WidgetTester tester, {
  String? myUid,
  ({String phone, bool whatsapp})? contact,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        myUidProvider.overrideWithValue(myUid),
        listingContactProvider('l1').overrideWith((ref) async => contact),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: ContactButtons(listing: _listing)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a guest sees the sign-in button only', (tester) async {
    await _pump(tester);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.byIcon(Icons.call), findsNothing);
    expect(find.byIcon(Icons.chat), findsNothing);
  });

  testWidgets('signed in with WhatsApp: 2 buttons', (tester) async {
    await _pump(
      tester,
      myUid: 'someone-else',
      contact: (phone: '+21692816836', whatsapp: true),
    );
    expect(find.byIcon(Icons.call), findsOneWidget);
    expect(find.byIcon(Icons.chat), findsOneWidget);
  });

  testWidgets('signed in without WhatsApp: 1 button', (tester) async {
    await _pump(
      tester,
      myUid: 'someone-else',
      contact: (phone: '+21692816836', whatsapp: false),
    );
    expect(find.byIcon(Icons.call), findsOneWidget);
    expect(find.byIcon(Icons.chat), findsNothing);
  });

  testWidgets('signed in with no number: nothing shown', (tester) async {
    await _pump(tester, myUid: 'someone-else');
    expect(find.byIcon(Icons.call), findsNothing);
    expect(find.byIcon(Icons.chat), findsNothing);
    expect(find.byIcon(Icons.lock_outline), findsNothing);
  });
}
