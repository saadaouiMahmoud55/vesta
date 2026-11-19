import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../listings/listing.dart';
import 'chat_models.dart';

/// Errors the UI can show. Screens turn them into translated messages.
enum ChatError {
  notSignedIn,
  ownListing,
  messageTooLong,
  noNetwork,
  permissionDenied,
  unknown,
}

class ChatFailure implements Exception {
  const ChatFailure(this.error);

  final ChatError error;
}

/// Only place that talks to the `conversations` collection (VST-44).
///
/// One conversation per listing and per buyer, id = `{listingId}_{buyerId}`
/// (docs/data-model.md). Messages are in the subcollection `messages`.
class ChatRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _db.collection('conversations');

  /// Id of the conversation between the signed-in buyer and the owner of
  /// [listing]. The conversation document itself is created with the first
  /// message (see [sendMessage]), so opening a chat writes nothing.
  ///
  /// Throws [ChatFailure] if nobody is signed in, or if the user is the owner
  /// of the listing (nobody talks to himself).
  String conversationIdForListing(Listing listing) {
    final user = _auth.currentUser;
    if (user == null) throw const ChatFailure(ChatError.notSignedIn);
    if (listing.ownerId == user.uid) {
      throw const ChatFailure(ChatError.ownListing);
    }
    return conversationIdFor(listing.id, user.uid);
  }

  /// Live list of the conversations of the signed-in user, newest first.
  /// Emits an empty list when nobody is signed in.
  Stream<List<Conversation>> watchConversations() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(const <Conversation>[]);

    return _conversations
        .where('participantIds', arrayContains: user.uid)
        .snapshots()
        // Sorted here (not in the query) so no Firestore index is needed.
        .map((snapshot) =>
            sortNewestFirst(snapshot.docs.map(Conversation.fromDoc)))
        .handleError(_rethrowAsFailure);
  }

  /// Live list of the last [limit] messages, newest first. The chat screen
  /// shows it upside down so the newest message is at the bottom.
  /// The listener stops when the stream is no longer listened to.
  Stream<List<ChatMessage>> watchMessages(
    String conversationId, {
    int limit = messagesPageSize,
  }) {
    return _conversations
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ChatMessage.fromDoc).toList())
        .handleError(_rethrowAsFailure);
  }

  /// Sends [text] from the signed-in user. The user is either the buyer or
  /// the owner of the conversation.
  ///
  /// One batch writes the message and the conversation summary together
  /// (`lastMessage`, `lastMessageAt`, +1 unread for the other person), so a
  /// conversation never shows a message that does not exist. For the very
  /// first message the same `set` also creates the conversation.
  ///
  /// Offline, the batch waits in the local queue and `commit` does not finish
  /// until the network is back: the controller shows the "sending" state and a
  /// timeout error.
  Future<void> sendMessage({
    required String listingId,
    required String buyerId,
    required String ownerId,
    required String text,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw const ChatFailure(ChatError.notSignedIn);
    if (buyerId == ownerId) throw const ChatFailure(ChatError.ownListing);
    if (user.uid != buyerId && user.uid != ownerId) {
      throw const ChatFailure(ChatError.permissionDenied);
    }

    final body = text.trim();
    if (body.isEmpty) return;
    if (body.length > maxMessageLength) {
      throw const ChatFailure(ChatError.messageTooLong);
    }

    final recipient = user.uid == buyerId ? ownerId : buyerId;
    final conversation =
        _conversations.doc(conversationIdFor(listingId, buyerId));
    final batch = _db.batch();
    batch.set(
      conversation,
      {
        // Always [buyer, owner], in this order: the rules refuse an update
        // that changes the array, and arrays are compared in order.
        'participantIds': [buyerId, ownerId],
        'listingId': listingId,
        'lastMessage': body,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unread': {recipient: FieldValue.increment(1)},
      },
      SetOptions(merge: true),
    );
    batch.set(conversation.collection('messages').doc(), {
      'senderId': user.uid,
      'text': body,
      'createdAt': FieldValue.serverTimestamp(),
    });

    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      throw ChatFailure(_mapCode(e.code));
    }
  }

  /// Sets the unread counter of the signed-in user to 0 for [conversationId].
  /// Only touches `unread.{uid}`: the rules allow it because the participants
  /// and the listing stay the same. Does nothing if the conversation does not
  /// exist yet (nobody has written to it).
  Future<void> markRead(String conversationId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _conversations
          .doc(conversationId)
          .update({'unread.${user.uid}': 0});
    } on FirebaseException catch (e) {
      // not-found: the conversation is created with the first message.
      if (e.code == 'not-found') return;
      throw ChatFailure(_mapCode(e.code));
    }
  }

  /// Public name of a user (`users/{uid}`), or null if there is none.
  Future<String?> getUserName(String uid) async {
    if (uid.isEmpty) return null;
    try {
      final doc = await _db.collection('users').doc(uid).get();
      final name = (doc.data()?['displayName'] as String?)?.trim();
      return (name == null || name.isEmpty) ? null : name;
    } on FirebaseException catch (e) {
      throw ChatFailure(_mapCode(e.code));
    }
  }

  Never _rethrowAsFailure(Object error) {
    if (error is FirebaseException) throw ChatFailure(_mapCode(error.code));
    throw const ChatFailure(ChatError.unknown);
  }

  ChatError _mapCode(String code) {
    switch (code) {
      case 'permission-denied':
        return ChatError.permissionDenied;
      case 'unavailable':
      case 'deadline-exceeded':
        return ChatError.noNetwork;
      case 'unauthenticated':
        return ChatError.notSignedIn;
      default:
        return ChatError.unknown;
    }
  }
}
