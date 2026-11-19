import 'dart:ui' show TextDirection;

import 'package:cloud_firestore/cloud_firestore.dart';

/// Longest message accepted by the rules (see firebase/firestore.rules).
const maxMessageLength = 2000;

/// How many messages a chat screen loads (VST-44).
const messagesPageSize = 50;

/// Conversation id: one conversation per listing and per buyer
/// (docs/data-model.md). Neither part contains an underscore: Firestore
/// auto-ids and Firebase uids are letters and digits only.
String conversationIdFor(String listingId, String buyerId) =>
    '${listingId}_$buyerId';

/// Splits a conversation id back into its two parts, or null if it is not one.
({String listingId, String buyerId})? parseConversationId(String id) {
  final cut = id.lastIndexOf('_');
  if (cut <= 0 || cut == id.length - 1) return null;
  return (listingId: id.substring(0, cut), buyerId: id.substring(cut + 1));
}

/// Text direction that follows the message itself, not the app language:
/// people write Arabic, French and English, sometimes mixed (VST-44).
/// The first letter decides (the Unicode "first strong character" rule), so
/// "Salut مرحبا" is left to right and "مرحبا Salut" is right to left.
/// Text without letters (digits, emoji) follows [fallback].
TextDirection textDirectionFor(
  String text, {
  TextDirection fallback = TextDirection.ltr,
}) {
  for (final rune in text.runes) {
    if (_isArabicDigit(rune)) continue; // digits are neutral
    if (_isRtlLetter(rune)) return TextDirection.rtl;
    if (_isLtrLetter(rune)) return TextDirection.ltr;
  }
  return fallback;
}

/// Arabic-Indic digits (٠-٩) and the Persian ones (۰-۹): they sit inside the
/// Arabic block but are numbers, not letters.
bool _isArabicDigit(int rune) =>
    (rune >= 0x0660 && rune <= 0x0669) || (rune >= 0x06F0 && rune <= 0x06F9);

/// Hebrew, Arabic, Syriac, Thaana, N'Ko... and the Arabic presentation forms.
bool _isRtlLetter(int rune) =>
    (rune >= 0x0590 && rune <= 0x08FF) ||
    (rune >= 0xFB1D && rune <= 0xFDFF) ||
    (rune >= 0xFE70 && rune <= 0xFEFF);

/// Latin letters, with the accents used in French (é, à, ç...).
bool _isLtrLetter(int rune) =>
    (rune >= 0x41 && rune <= 0x5A) ||
    (rune >= 0x61 && rune <= 0x7A) ||
    (rune >= 0xC0 && rune <= 0x24F && rune != 0xD7 && rune != 0xF7);

/// One conversation, as read from the `conversations` collection.
class Conversation {
  const Conversation({
    required this.id,
    required this.listingId,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unread = const {},
  });

  final String id;
  final String listingId;

  /// Exactly 2 uids: `[buyerId, ownerId]`.
  final List<String> participantIds;
  final String lastMessage;

  /// Null for a moment right after a send (the server has not answered yet).
  final DateTime? lastMessageAt;

  /// Unread messages per user: `uid -> count`.
  final Map<String, int> unread;

  factory Conversation.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final rawUnread = data['unread'];
    return Conversation(
      id: doc.id,
      listingId: (data['listingId'] as String?) ?? '',
      participantIds: [
        for (final id in (data['participantIds'] as List?) ?? const [])
          if (id is String) id,
      ],
      lastMessage: (data['lastMessage'] as String?) ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      unread: {
        if (rawUnread is Map)
          for (final entry in rawUnread.entries)
            if (entry.key is String && entry.value is num)
              entry.key as String: (entry.value as num).toInt(),
      },
    );
  }

  /// The other person of the conversation, seen from [myUid].
  String otherUserId(String myUid) =>
      participantIds.firstWhere((id) => id != myUid, orElse: () => '');

  int unreadFor(String uid) => unread[uid] ?? 0;
}

/// Newest conversation first. A conversation whose time is still null was
/// just written by this phone, so it is the newest.
List<Conversation> sortNewestFirst(Iterable<Conversation> conversations) {
  final list = conversations.toList();
  list.sort((a, b) {
    final ta = a.lastMessageAt;
    final tb = b.lastMessageAt;
    if (ta == null && tb == null) return 0;
    if (ta == null) return -1;
    if (tb == null) return 1;
    return tb.compareTo(ta);
  });
  return list;
}

/// Unread messages of [uid] over all the conversations (for the badge on the
/// chat icon).
int totalUnread(Iterable<Conversation> conversations, String uid) =>
    conversations.fold(0, (total, c) => total + c.unreadFor(uid));

/// One message of a conversation.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String text;

  /// Null while the message is still being sent.
  final DateTime? createdAt;

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return ChatMessage(
      id: doc.id,
      senderId: (data['senderId'] as String?) ?? '',
      text: (data['text'] as String?) ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// The conversations that have messages the user has not read yet: the
/// content of the notification center (VST-99). Same order as the input.
List<Conversation> unreadConversations(
  Iterable<Conversation> conversations,
  String uid,
) => [
  for (final c in conversations)
    if (c.unreadFor(uid) > 0) c,
];
