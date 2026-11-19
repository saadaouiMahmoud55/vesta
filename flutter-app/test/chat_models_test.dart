import 'dart:ui' show TextDirection;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/features/chat/chat_models.dart';

Conversation _conv(String id, DateTime? at, {Map<String, int>? unread}) =>
    Conversation(
      id: id,
      listingId: 'l1',
      participantIds: const ['buyer', 'owner'],
      lastMessage: '',
      lastMessageAt: at,
      unread: unread ?? const {},
    );

void main() {
  group('conversation id (VST-44)', () {
    test('is {listingId}_{buyerId}', () {
      expect(conversationIdFor('l1', 'u9'), 'l1_u9');
    });

    test('can be split back', () {
      final parts = parseConversationId('abc123_uid456');
      expect(parts?.listingId, 'abc123');
      expect(parts?.buyerId, 'uid456');
    });

    test('rejects ids that are not conversation ids', () {
      expect(parseConversationId('nounderscore'), isNull);
      expect(parseConversationId('_buyer'), isNull);
      expect(parseConversationId('listing_'), isNull);
      expect(parseConversationId(''), isNull);
    });
  });

  group('Conversation', () {
    test('otherUserId gives the other participant', () {
      final c = _conv('l1_buyer', null);
      expect(c.otherUserId('buyer'), 'owner');
      expect(c.otherUserId('owner'), 'buyer');
    });

    test('unreadFor is 0 when nothing is stored', () {
      final c = _conv('l1_buyer', null, unread: const {'owner': 3});
      expect(c.unreadFor('owner'), 3);
      expect(c.unreadFor('buyer'), 0);
    });
  });

  group('sortNewestFirst', () {
    test('newest first, and a pending (null) time counts as the newest', () {
      final old = _conv('old', DateTime(2026, 11, 1));
      final recent = _conv('recent', DateTime(2026, 11, 4));
      final pending = _conv('pending', null);

      final sorted = sortNewestFirst([old, pending, recent]);
      expect(sorted.map((c) => c.id), ['pending', 'recent', 'old']);
    });

    test('does not change the list it receives', () {
      final input = [
        _conv('a', DateTime(2026, 11, 1)),
        _conv('b', DateTime(2026, 11, 2)),
      ];
      sortNewestFirst(input);
      expect(input.map((c) => c.id), ['a', 'b']);
    });
  });

  group('textDirectionFor', () {
    test('Arabic is right to left', () {
      expect(textDirectionFor('مرحبا، هل الشقة متوفرة؟'), TextDirection.rtl);
    });

    test('French and English are left to right', () {
      expect(textDirectionFor('Bonjour, est-elle libre ?'), TextDirection.ltr);
      expect(textDirectionFor('Is it still available?'), TextDirection.ltr);
    });

    test('the first letter decides for mixed text', () {
      expect(textDirectionFor('Salut مرحبا'), TextDirection.ltr);
      expect(textDirectionFor('مرحبا Salut'), TextDirection.rtl);
      expect(textDirectionFor('12 مرحبا'), TextDirection.rtl);
      expect(textDirectionFor('Éric, ça va ?'), TextDirection.ltr);
    });

    test('Arabic-Indic digits are neutral, not right to left', () {
      expect(textDirectionFor('٣٢١'), TextDirection.ltr);
      expect(textDirectionFor('٣٢١ Salut'), TextDirection.ltr);
      expect(textDirectionFor('٣٢١ مرحبا'), TextDirection.rtl);
      expect(
        textDirectionFor('٣٢١', fallback: TextDirection.rtl),
        TextDirection.rtl,
      );
    });

    test('text without letters follows the fallback', () {
      expect(textDirectionFor('12345'), TextDirection.ltr);
      expect(
        textDirectionFor('12345', fallback: TextDirection.rtl),
        TextDirection.rtl,
      );
      expect(textDirectionFor('   '), TextDirection.ltr);
    });
  });

  group('totalUnread', () {
    Conversation conv(String id, Map<String, int> unread) => Conversation(
          id: id,
          listingId: 'l',
          participantIds: const ['a', 'b'],
          lastMessage: '',
          lastMessageAt: null,
          unread: unread,
        );

    test('adds my counters only', () {
      final list = [
        conv('1', {'a': 2, 'b': 5}),
        conv('2', {'a': 1}),
        conv('3', {'b': 4}),
      ];
      expect(totalUnread(list, 'a'), 3);
      expect(totalUnread(list, 'b'), 9);
    });

    test('nothing unread gives 0', () {
      expect(totalUnread(const [], 'a'), 0);
      expect(totalUnread([conv('1', const {})], 'a'), 0);
    });
  });
}
