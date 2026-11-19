import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../listings/listing.dart';
import '../listings/listing_controller.dart';
import 'chat_models.dart';
import 'chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(),
);

/// Uid of the signed-in user (null for a guest). Screens use this instead of
/// reading Firebase directly, so tests can replace it.
final myUidProvider = Provider<String?>(
  (ref) => ref.watch(authStateProvider).value?.uid,
);

/// Live conversations of the signed-in user, newest first. Restarts by
/// itself when the user signs in or out, and stops listening when the list
/// screen is closed (no leaked listener).
final conversationsProvider =
    StreamProvider.autoDispose<List<Conversation>>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(chatRepositoryProvider).watchConversations();
});

/// Number of unread messages, for the badge on the chat icon and on the bell
/// (the bell opens the conversations that hold these messages, VST-99). 0 for a guest
/// or while the list is loading. It reuses [conversationsProvider], so no
/// second Firestore listener is opened.
final unreadTotalProvider = Provider<int>((ref) {
  final uid = ref.watch(myUidProvider);
  if (uid == null) return 0;
  final conversations = ref.watch(conversationsProvider).value;
  return conversations == null ? 0 : totalUnread(conversations, uid);
});

/// Public name of a user, for the conversation list and the chat header.
final userNameProvider =
    FutureProvider.autoDispose.family<String?, String>((ref, uid) {
  return ref.watch(chatRepositoryProvider).getUserName(uid);
});

/// Listing a conversation is about (null if it was deleted).
final conversationListingProvider =
    FutureProvider.autoDispose.family<Listing?, String>((ref, listingId) {
  return ref.watch(listingRepositoryProvider).getListing(listingId);
});

/// Live messages of one conversation, newest first (last 50 only). The
/// listener stops when the chat screen is closed (autoDispose): no leak.
final messagesProvider = StreamProvider.autoDispose
    .family<List<ChatMessage>, String>((ref, conversationId) {
  ref.watch(authStateProvider);
  return ref.watch(chatRepositoryProvider).watchMessages(conversationId);
});

/// How long the screen waits before telling the user the message is still
/// in the queue (offline). The message itself is not lost: Firestore sends it
/// when the network is back.
const sendWaitLimit = Duration(seconds: 8);

/// Sends [text] in the conversation [conversationId] and reports what the
/// screen should show. Returns null when the message reached the server, or
/// the [ChatError] otherwise.
///
/// VST-50 hook: the in-app alert for the other person is created from here
/// (after a successful send), not in the screen.
Future<ChatError?> sendChatMessage(
  WidgetRef ref, {
  required String conversationId,
  required String ownerId,
  required String text,
}) async {
  final ids = parseConversationId(conversationId);
  if (ids == null) return ChatError.unknown;
  try {
    await ref
        .read(chatRepositoryProvider)
        .sendMessage(
          listingId: ids.listingId,
          buyerId: ids.buyerId,
          ownerId: ownerId,
          text: text,
        )
        .timeout(sendWaitLimit);
    return null;
  } on TimeoutException {
    return ChatError.noNetwork;
  } on ChatFailure catch (e) {
    return e.error;
  } catch (_) {
    return ChatError.unknown;
  }
}
