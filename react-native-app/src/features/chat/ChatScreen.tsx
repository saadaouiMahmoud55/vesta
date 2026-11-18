import React, { useEffect, useState } from 'react';
import {
  FlatList,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import { useTranslation } from 'react-i18next';
import { AppText } from '../../core/components/AppText';
import { ErrorView } from '../../core/components/ErrorView';
import { LoadingView } from '../../core/components/LoadingView';
import { TextButton } from '../../core/components/TextButton';
import { theme } from '../../core/theme';
import {
  ChatMessage,
  maxMessageLength,
  parseConversationId,
  textDirectionFor,
  unreadFor,
} from '../../data/models/chat';
import { ChatError } from '../../data/repositories/chatErrors';
import { useAuth } from '../auth/authController';
import {
  markConversationRead,
  sendChatMessage,
  useConversationListing,
  useConversations,
  useMessages,
  useUserName,
} from './chatController';

function sameDay(a: Date, b: Date): boolean {
  return (
    a.getFullYear() === b.getFullYear() &&
    a.getMonth() === b.getMonth() &&
    a.getDate() === b.getDate()
  );
}

/** Same texts as the Flutter chat: offline = "not sent yet", else "failed". */
function sendErrorKey(error: ChatError): string {
  return error === 'noNetwork' ? 'chatSendError' : 'chatSendFailed';
}

function DaySeparator({ date }: { date: Date }): React.JSX.Element {
  const { t, i18n } = useTranslation();
  const now = new Date();
  const yesterday = new Date(now.getTime() - 24 * 60 * 60 * 1000);
  let label: string;
  if (sameDay(date, now)) {
    label = t('chatToday');
  } else if (sameDay(date, yesterday)) {
    label = t('chatYesterday');
  } else {
    label = date.toLocaleDateString(i18n.language, {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
    });
  }
  return (
    <View style={styles.dayWrap}>
      <View style={styles.dayPill}>
        <Text style={styles.dayText}>{label}</Text>
      </View>
    </View>
  );
}

function Bubble({
  message,
  mine,
}: {
  message: ChatMessage;
  mine: boolean;
}): React.JSX.Element {
  const { t, i18n } = useTranslation();
  const time = message.createdAt;
  return (
    <View style={[styles.bubble, mine ? styles.bubbleMine : styles.bubbleOther]}>
      {/* The direction follows the message, not the app language. */}
      <Text
        style={[
          styles.bubbleText,
          mine ? styles.textMine : null,
          { writingDirection: textDirectionFor(message.text) },
        ]}
      >
        {message.text}
      </Text>
      <Text style={[styles.bubbleTime, mine ? styles.timeMine : null]}>
        {time === null
          ? t('chatSending')
          : time.toLocaleTimeString(i18n.language, {
              hour: '2-digit',
              minute: '2-digit',
            })}
      </Text>
    </View>
  );
}

/**
 * Live messages of an existing conversation. It is mounted only once the
 * conversation exists: before the first message the rules refuse to read its
 * messages, so listening earlier would fail.
 */
function MessageList({
  conversationId,
  myUid,
}: {
  conversationId: string;
  myUid: string;
}): React.JSX.Element {
  const chat = useMessages(conversationId);

  // New messages arriving while the screen is open clear the unread badge.
  useEffect(() => {
    markConversationRead(conversationId);
  }, [conversationId, chat.messages.length]);

  if (chat.error !== null) {
    return (
      <View style={styles.flex}>
        <ErrorView messageKey="chatLoadError" />
        <TextButton labelKey="chatRetry" onPress={chat.retry} />
      </View>
    );
  }
  if (chat.loading) {
    return <LoadingView />;
  }
  if (chat.messages.length === 0) {
    return (
      <View style={styles.center}>
        <AppText translationKey="chatNoMessages" style={styles.body} />
      </View>
    );
  }
  return (
    <FlatList
      // Newest first + inverted: the newest message is at the bottom.
      inverted
      data={chat.messages}
      keyExtractor={item => item.id}
      contentContainerStyle={styles.list}
      renderItem={({ item, index }) => {
        const older = chat.messages[index + 1];
        const showDay =
          item.createdAt !== null &&
          (older === undefined ||
            older.createdAt === null ||
            !sameDay(item.createdAt, older.createdAt));
        return (
          <View>
            {showDay && item.createdAt !== null ? (
              <DaySeparator date={item.createdAt} />
            ) : null}
            <Bubble message={item} mine={item.senderId === myUid} />
          </View>
        );
      }}
    />
  );
}

/**
 * One conversation: realtime messages, newest at the bottom, and a box to
 * write (VST-45). The conversation is between the buyer (from the id) and
 * the owner of the listing.
 */
export function ChatScreen({
  conversationId,
  onOpenListing,
}: {
  conversationId: string;
  onOpenListing?: (listingId: string) => void;
}): React.JSX.Element {
  const { t } = useTranslation();
  const { uid } = useAuth();
  const chats = useConversations();
  const ids = parseConversationId(conversationId);
  const listing = useConversationListing(ids === null ? '' : ids.listingId);
  const ownerId = listing === undefined || listing === null ? '' : listing.ownerId;
  const otherId =
    ids === null ? '' : uid === ids.buyerId ? ownerId : ids.buyerId;
  const otherName = useUserName(otherId);

  const [text, setText] = useState('');
  const [sending, setSending] = useState(false);
  const [sendError, setSendError] = useState<ChatError | null>(null);

  // Opening or receiving messages clears the unread badge.
  useEffect(() => {
    const mine = chats.conversations.find(item => item.id === conversationId);
    if (mine !== undefined && uid !== null && unreadFor(mine, uid) > 0) {
      markConversationRead(conversationId);
    }
  }, [chats.conversations, conversationId, uid]);

  if (uid === null) {
    return (
      <View style={styles.center}>
        <AppText translationKey="signInToContinueTitle" style={styles.title} />
        <AppText translationKey="signInToContinueBody" style={styles.body} />
      </View>
    );
  }
  if (ids === null) {
    return (
      <View style={styles.center}>
        <AppText translationKey="chatLoadError" style={styles.body} />
      </View>
    );
  }

  // null = still checking.
  const exists: boolean | null =
    chats.error !== null
      ? false
      : chats.loading
        ? null
        : chats.conversations.some(item => item.id === conversationId);

  const displayName = otherName ?? t('chatUnknownUser');
  const canSend = ownerId.length > 0 && !sending && text.trim().length > 0;

  async function send(): Promise<void> {
    const body = text.trim();
    if (body.length === 0 || sending || ownerId.length === 0) {
      return;
    }
    setSending(true);
    setSendError(null);
    const error = await sendChatMessage({
      conversationId,
      ownerId,
      text: body,
    });
    setSending(false);
    // Offline: the message leaves by itself when the network is back, so the
    // box is emptied either way.
    if (error === null || error === 'noNetwork') {
      setText('');
    }
    if (error !== null) {
      setSendError(error);
    }
  }

  let body: React.JSX.Element;
  if (exists === null) {
    body = <LoadingView />;
  } else if (exists === false) {
    body = (
      <View style={styles.center}>
        <AppText translationKey="chatNoMessages" style={styles.body} />
      </View>
    );
  } else {
    body = <MessageList conversationId={conversationId} myUid={uid} />;
  }

  return (
    <KeyboardAvoidingView
      style={styles.screen}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <View style={styles.header}>
        <View style={styles.avatar}>
          <Text style={styles.avatarText}>
            {displayName.charAt(0).toUpperCase()}
          </Text>
        </View>
        <Text numberOfLines={1} style={styles.name}>
          {displayName}
        </Text>
      </View>

      {listing !== undefined ? (
        listing === null ? (
          <View style={styles.strip}>
            <AppText translationKey="chatListingRemoved" style={styles.body} />
          </View>
        ) : (
          <Pressable
            accessibilityRole="button"
            onPress={() => onOpenListing?.(listing.id)}
            style={styles.strip}
          >
            <Text numberOfLines={1} style={styles.stripTitle}>
              {listing.title}
            </Text>
          </Pressable>
        )
      ) : null}

      <View style={styles.flex}>{body}</View>

      {sendError !== null ? (
        <AppText
          translationKey={sendErrorKey(sendError)}
          style={styles.sendError}
        />
      ) : null}

      <View style={styles.composer}>
        <TextInput
          value={text}
          onChangeText={setText}
          editable={ownerId.length > 0}
          maxLength={maxMessageLength}
          multiline
          placeholder={t('chatMessageHint')}
          placeholderTextColor={theme.colors.grey}
          // Cursor and alignment follow what the person types.
          style={[
            styles.input,
            { writingDirection: textDirectionFor(text) },
          ]}
        />
        <Pressable
          accessibilityRole="button"
          accessibilityLabel={t('chatSend')}
          disabled={!canSend}
          onPress={send}
          style={[styles.sendButton, !canSend ? styles.sendDisabled : null]}
        >
          <Text style={styles.sendText}>
            {sending ? t('chatSending') : t('chatSend')}
          </Text>
        </Pressable>
      </View>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  screen: { backgroundColor: theme.colors.background, flex: 1 },
  center: {
    alignItems: 'center',
    backgroundColor: theme.colors.background,
    flex: 1,
    gap: theme.spacing.sm,
    justifyContent: 'center',
    padding: theme.spacing.lg,
  },
  title: {
    color: theme.colors.navy,
    fontSize: theme.fontSizes.title,
    fontWeight: '700',
    textAlign: 'center',
  },
  body: { color: theme.colors.grey, textAlign: 'center' },
  header: {
    alignItems: 'center',
    backgroundColor: theme.colors.white,
    flexDirection: 'row',
    gap: theme.spacing.md,
    paddingHorizontal: theme.spacing.md,
    paddingVertical: theme.spacing.sm,
  },
  avatar: {
    alignItems: 'center',
    backgroundColor: theme.colors.sand,
    borderRadius: theme.radius.round,
    height: 40,
    justifyContent: 'center',
    width: 40,
  },
  avatarText: {
    color: theme.colors.navy,
    fontSize: theme.fontSizes.body,
    fontWeight: '700',
  },
  name: {
    color: theme.colors.navy,
    flex: 1,
    fontSize: theme.fontSizes.body,
    fontWeight: '700',
  },
  strip: {
    backgroundColor: theme.colors.sand,
    paddingHorizontal: theme.spacing.md,
    paddingVertical: theme.spacing.sm,
  },
  stripTitle: {
    color: theme.colors.navy,
    fontSize: theme.fontSizes.small,
    fontWeight: '600',
  },
  list: { padding: theme.spacing.md },
  dayWrap: { alignItems: 'center', paddingVertical: theme.spacing.md },
  dayPill: {
    backgroundColor: theme.colors.sand,
    borderRadius: theme.radius.round,
    paddingHorizontal: theme.spacing.md,
    paddingVertical: 4,
  },
  dayText: { color: theme.colors.grey, fontSize: theme.fontSizes.small },
  bubble: {
    borderRadius: theme.radius.md,
    marginVertical: 3,
    maxWidth: '78%',
    paddingHorizontal: 14,
    paddingVertical: 10,
  },
  bubbleMine: {
    alignSelf: 'flex-end',
    backgroundColor: theme.colors.primary,
  },
  bubbleOther: {
    alignSelf: 'flex-start',
    backgroundColor: theme.colors.white,
  },
  bubbleText: {
    color: theme.colors.navy,
    fontSize: theme.fontSizes.body,
  },
  textMine: { color: theme.colors.white },
  bubbleTime: {
    alignSelf: 'flex-end',
    color: theme.colors.grey,
    fontSize: theme.fontSizes.small,
    marginTop: 2,
  },
  timeMine: { color: theme.colors.white, opacity: 0.75 },
  sendError: {
    color: theme.colors.error,
    paddingHorizontal: theme.spacing.md,
    paddingTop: theme.spacing.xs,
  },
  composer: {
    alignItems: 'flex-end',
    flexDirection: 'row',
    gap: theme.spacing.sm,
    padding: theme.spacing.sm,
  },
  input: {
    backgroundColor: theme.colors.sand,
    borderColor: theme.colors.border,
    borderRadius: theme.radius.lg,
    borderWidth: 1,
    color: theme.colors.navy,
    flex: 1,
    fontSize: theme.fontSizes.body,
    maxHeight: 120,
    paddingHorizontal: theme.spacing.md,
    paddingVertical: theme.spacing.sm,
  },
  sendButton: {
    alignItems: 'center',
    backgroundColor: theme.colors.primary,
    borderRadius: theme.radius.round,
    justifyContent: 'center',
    paddingHorizontal: theme.spacing.md,
    paddingVertical: theme.spacing.sm,
  },
  sendDisabled: { opacity: 0.4 },
  sendText: {
    color: theme.colors.white,
    fontSize: theme.fontSizes.body,
    fontWeight: '700',
  },
});