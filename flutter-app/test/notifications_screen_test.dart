import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/features/chat/chat_controller.dart';
import 'package:flutterapp/features/chat/chat_models.dart';
import 'package:flutterapp/features/listings/listing.dart';
import 'package:flutterapp/features/notifications/notifications_screen.dart';
import 'package:flutterapp/l10n/generated/app_localizations.dart';

const _listing = Listing(
  id: 'l1',
  ownerId: 'owner1',
  title: 'Sea view flat',
  description: '',
  price: 120000,
  currency: 'TND',
  listingType: 'sale',
  propertyType: 'apartment',
  city: 'Sousse',
  status: 'available',
  photoCount: 0,
);

Conversation _conversation(String id, {int unreadForMe = 0}) => Conversation(
  id: id,
  listingId: 'l1',
  participantIds: const ['buyer1', 'owner1'],
  lastMessage: 'Message of $id',
  lastMessageAt: null,
  unread: {'buyer1': unreadForMe, 'owner1': 5},
);

Future<void> _pump(
  WidgetTester tester, {
  String? myUid = 'buyer1',
  List<Conversation> conversations = const [],
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        myUidProvider.overrideWithValue(myUid),
        conversationsProvider.overrideWith((ref) => Stream.value(conversations)),
        conversationListingProvider('l1').overrideWith((ref) async => _listing),
        userNameProvider('owner1').overrideWith((ref) async => 'Sami'),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: NotificationsScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('the unread total (chat icon and bell) counts all unread messages',
      () async {
    final container = ProviderContainer(
      overrides: [
        myUidProvider.overrideWithValue('buyer1'),
        conversationsProvider.overrideWith(
          (ref) => Stream.value([
            _conversation('a', unreadForMe: 3),
            _conversation('b'),
            _conversation('c', unreadForMe: 1),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);
    // The provider is autoDispose: listen to keep it alive while we wait.
    final subscription = container.listen(conversationsProvider, (_, _) {});
    addTearDown(subscription.close);
    await container.read(conversationsProvider.future);
    // 3 + 1 messages (2 conversations): both icons show 4.
    expect(container.read(unreadTotalProvider), 4);
  });

  test('unreadConversations keeps only what I have not read, in order', () {
    final shown = unreadConversations([
      _conversation('a', unreadForMe: 2),
      _conversation('b'),
      _conversation('c', unreadForMe: 1),
    ], 'buyer1');
    expect(shown.map((c) => c.id), ['a', 'c']);
    // The other person's counter does not count for me.
    expect(unreadConversations([_conversation('b')], 'buyer1'), isEmpty);
  });

  testWidgets('shows the conversations with unread messages only',
      (tester) async {
    await _pump(
      tester,
      conversations: [
        _conversation('read'),
        _conversation('new', unreadForMe: 3),
      ],
    );
    expect(find.text('Message of new'), findsOneWidget);
    expect(find.text('Message of read'), findsNothing);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('nothing unread: friendly empty state, no "coming soon"',
      (tester) async {
    await _pump(tester, conversations: [_conversation('read')]);
    expect(find.text('No new notifications'), findsOneWidget);
    expect(find.text('Coming soon'), findsNothing);
  });

  testWidgets('the empty state is translated', (tester) async {
    await _pump(tester, locale: const Locale('fr'));
    expect(find.text('Aucune nouvelle notification'), findsOneWidget);

    await _pump(tester, locale: const Locale('ar'));
    expect(find.text('ما فما حتى إشعار جديد'), findsOneWidget);
  });
}
