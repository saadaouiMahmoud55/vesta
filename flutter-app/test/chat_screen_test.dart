import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/features/chat/chat_controller.dart';
import 'package:flutterapp/features/chat/chat_models.dart';
import 'package:flutterapp/features/chat/chat_repository.dart';
import 'package:flutterapp/features/chat/chat_screen.dart';
import 'package:flutterapp/features/listings/listing.dart';
import 'package:flutterapp/l10n/generated/app_localizations.dart';

const _listing = Listing(
  id: 'l1',
  ownerId: 'owner1',
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

const _conversationId = 'l1_buyer1';

/// A conversation that already exists (at least one message was sent).
const _existing = Conversation(
  id: _conversationId,
  listingId: 'l1',
  participantIds: ['buyer1', 'owner1'],
  lastMessage: 'Hi',
  lastMessageAt: null,
);

/// Replaces Firestore: records what the screen sends and what it marks read.
class _FakeChatRepository extends ChatRepository {
  final sent = <String>[];
  final read = <String>[];
  ChatFailure? failWith;

  @override
  Future<void> sendMessage({
    required String listingId,
    required String buyerId,
    required String ownerId,
    required String text,
  }) async {
    if (failWith != null) throw failWith!;
    sent.add('$listingId|$buyerId|$ownerId|$text');
  }

  @override
  Future<void> markRead(String conversationId) async {
    read.add(conversationId);
  }
}

Future<_FakeChatRepository> _pump(
  WidgetTester tester, {
  String? myUid = 'buyer1',
  List<ChatMessage> messages = const [],
  List<Conversation>? conversations,
  Locale locale = const Locale('en'),
  ChatFailure? failWith,
}) async {
  final repository = _FakeChatRepository()..failWith = failWith;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        myUidProvider.overrideWithValue(myUid),
        chatRepositoryProvider.overrideWithValue(repository),
        messagesProvider(_conversationId)
            .overrideWith((ref) => Stream.value(messages)),
        conversationsProvider.overrideWith(
          (ref) => Stream.value(conversations ?? [_existing]),
        ),
        conversationListingProvider('l1').overrideWith((ref) async => _listing),
        userNameProvider('owner1').overrideWith((ref) async => 'Sami'),
        userNameProvider('buyer1').overrideWith((ref) async => 'Lina'),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: ChatScreen(conversationId: _conversationId),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  testWidgets(
      'a conversation that does not exist yet shows the empty state, '
      'not a spinner, and never reads its messages', (tester) async {
    var messagesRead = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myUidProvider.overrideWithValue('buyer1'),
          chatRepositoryProvider.overrideWithValue(_FakeChatRepository()),
          messagesProvider(_conversationId).overrideWith((ref) {
            messagesRead++;
            return const Stream<List<ChatMessage>>.empty();
          }),
          conversationsProvider.overrideWith(
            (ref) => Stream.value(const <Conversation>[]),
          ),
          conversationListingProvider('l1')
              .overrideWith((ref) async => _listing),
          userNameProvider('owner1').overrideWith((ref) async => 'Sami'),
          userNameProvider('buyer1').overrideWith((ref) async => 'Lina'),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(
            body: ChatScreen(conversationId: _conversationId),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No messages yet. Say hello!'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(messagesRead, 0);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('shows the other person, the listing and an empty state',
      (tester) async {
    await _pump(tester);
    expect(find.text('Sami'), findsOneWidget);
    expect(find.text('Sea view flat'), findsOneWidget);
    expect(find.text('No messages yet. Say hello!'), findsOneWidget);
  });

  testWidgets('shows the messages of both people', (tester) async {
    await _pump(
      tester,
      messages: [
        ChatMessage(
          id: 'm2',
          senderId: 'owner1',
          text: 'Yes, it is available',
          createdAt: DateTime(2026, 11, 5, 14, 5),
        ),
        ChatMessage(
          id: 'm1',
          senderId: 'buyer1',
          text: 'Is it still available?',
          createdAt: DateTime(2026, 11, 5, 14, 0),
        ),
      ],
    );
    expect(find.text('Is it still available?'), findsOneWidget);
    expect(find.text('Yes, it is available'), findsOneWidget);
  });

  testWidgets('a message not yet on the server shows "Sending…"',
      (tester) async {
    await _pump(
      tester,
      messages: const [
        ChatMessage(
          id: 'm1',
          senderId: 'buyer1',
          text: 'Hello',
          createdAt: null,
        ),
      ],
    );
    expect(find.text('Sending…'), findsOneWidget);
  });

  testWidgets('the send button waits for some text, then sends and clears',
      (tester) async {
    final repository = await _pump(tester);

    IconButton button() => tester.widget<IconButton>(find.byType(IconButton));
    expect(button().onPressed, isNull);

    await tester.enterText(find.byType(TextField), '  Hello  ');
    await tester.pump();
    expect(button().onPressed, isNotNull);

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    // The text is trimmed; the owner comes from the listing, the buyer from the id.
    expect(repository.sent, ['l1|buyer1|owner1|Hello']);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty);
  });

  testWidgets('a failed send keeps the text and shows an error',
      (tester) async {
    await _pump(
      tester,
      failWith: const ChatFailure(ChatError.permissionDenied),
    );
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.pump();
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(find.text('Message not sent, try again'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Hello');
  });

  testWidgets('an offline send explains that the message waits',
      (tester) async {
    await _pump(
      tester,
      failWith: const ChatFailure(ChatError.noNetwork),
    );
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.pump();
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(
      find.text('Not sent yet. It will be sent when you are back online.'),
      findsOneWidget,
    );
  });

  testWidgets('opening the chat clears my unread counter', (tester) async {
    final repository = await _pump(
      tester,
      conversations: [
        const Conversation(
          id: _conversationId,
          listingId: 'l1',
          participantIds: ['buyer1', 'owner1'],
          lastMessage: 'Hi',
          lastMessageAt: null,
          unread: {'buyer1': 2},
        ),
      ],
    );
    expect(repository.read, contains(_conversationId));
  });

  testWidgets('an Arabic message keeps its own direction', (tester) async {
    await _pump(
      tester,
      messages: const [
        ChatMessage(
          id: 'm1',
          senderId: 'owner1',
          text: 'مرحبا، الشقة متاحة',
          createdAt: null,
        ),
      ],
    );
    final text = tester.widget<Text>(find.text('مرحبا، الشقة متاحة'));
    expect(text.textDirection, TextDirection.rtl);
  });

  testWidgets('texts are translated in French and Arabic', (tester) async {
    await _pump(tester, locale: const Locale('fr'));
    expect(find.text('Aucun message. Dites bonjour !'), findsOneWidget);

    await _pump(tester, locale: const Locale('ar'));
    expect(find.text('ما فما حتى رسالة توا. ابدا المحادثة!'), findsOneWidget);
  });
}
