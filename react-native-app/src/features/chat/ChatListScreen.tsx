import React from 'react';
import { FlatList, Pressable, StyleSheet, Text, View } from 'react-native';
import { useTranslation } from 'react-i18next';
import { AppText } from '../../core/components/AppText';
import { ErrorView } from '../../core/components/ErrorView';
import { LoadingView } from '../../core/components/LoadingView';
import { TextButton } from '../../core/components/TextButton';
import { theme } from '../../core/theme';
import {
  Conversation,
  otherUserId,
  textDirectionFor,
  unreadFor,
} from '../../data/models/chat';
import { useAuth } from '../auth/authController';
import {
  useConversations,
  useListingTitle,
  useUserName,
} from './chatController';

/** "14:05" for today, "5 Nov" for older messages, in the app language. */
function timeText(time: Date | null, language: string): string {
  if (time === null) {
    return '';
  }
  const now = new Date();
  const today =
    time.getFullYear() === now.getFullYear() &&
    time.getMonth() === now.getMonth() &&
    time.getDate() === now.getDate();
  return today
    ? time.toLocaleTimeString(language, { hour: '2-digit', minute: '2-digit' })
    : time.toLocaleDateString(language, { day: 'numeric', month: 'short' });
}

/** One row of the conversation list. */
function ConversationRow({
  conversation,
  myUid,
  onOpen,
}: {
  conversation: Conversation;
  myUid: string;
  onOpen: (conversationId: string) => void;
}): React.JSX.Element {
  const { t, i18n } = useTranslation();
  const name = useUserName(otherUserId(conversation, myUid));
  const listingTitle = useListingTitle(conversation.listingId);
  const displayName = name ?? t('chatUnknownUser');
  const unread = unreadFor(conversation, myUid);
  const lastMessage = conversation.lastMessage;

  let titleText = '';
  if (listingTitle === null) {
    titleText = t('chatListingRemoved');
  } else if (listingTitle !== undefined) {
    titleText = listingTitle;
  }

  return (
    <Pressable
      accessibilityRole="button"
      onPress={() => onOpen(conversation.id)}
      style={styles.row}
    >
      <View style={styles.avatar}>
        <Text style={styles.avatarText}>
          {displayName.charAt(0).toUpperCase()}
        </Text>
      </View>
      <View style={styles.rowBody}>
        <Text numberOfLines={1} style={styles.name}>
          {displayName}
        </Text>
        {titleText.length > 0 ? (
          <Text numberOfLines={1} style={styles.listingTitle}>
            {titleText}
          </Text>
        ) : null}
        {lastMessage.length > 0 ? (
          <Text
            numberOfLines={1}
            style={[
              styles.lastMessage,
              unread > 0 ? styles.lastMessageUnread : null,
              { writingDirection: textDirectionFor(lastMessage) },
            ]}
          >
            {lastMessage}
          </Text>
        ) : null}
      </View>
      <View style={styles.rowEnd}>
        <Text style={[styles.time, unread > 0 ? styles.timeUnread : null]}>
          {timeText(conversation.lastMessageAt, i18n.language)}
        </Text>
        {unread > 0 ? (
          <View style={styles.badge}>
            <Text style={styles.badgeText}>{unread}</Text>
          </View>
        ) : null}
      </View>
    </Pressable>
  );
}

function Separator(): React.JSX.Element {
  return <View style={styles.separator} />;
}

/** All the conversations of the signed-in user, newest first (VST-45). */
export function ChatListScreen({
  onOpen,
}: {
  onOpen: (conversationId: string) => void;
}): React.JSX.Element {
  const { uid } = useAuth();
  const chats = useConversations();

  // Covers a sign out while the screen is open.
  if (uid === null) {
    return (
      <View style={styles.center}>
        <AppText translationKey="signInToContinueTitle" style={styles.title} />
        <AppText translationKey="signInToContinueBody" style={styles.body} />
      </View>
    );
  }

  if (chats.error !== null) {
    return (
      <View style={styles.screen}>
        <ErrorView messageKey="chatLoadError" />
        <TextButton labelKey="chatRetry" onPress={chats.retry} />
      </View>
    );
  }

  if (chats.loading) {
    return <LoadingView />;
  }

  if (chats.conversations.length === 0) {
    return (
      <View style={styles.center}>
        <AppText translationKey="chatEmptyTitle" style={styles.title} />
        <AppText translationKey="chatEmptyBody" style={styles.body} />
      </View>
    );
  }

  return (
    <View style={styles.screen}>
      <FlatList
        data={chats.conversations}
        keyExtractor={item => item.id}
        contentContainerStyle={styles.list}
        ItemSeparatorComponent={Separator}
        renderItem={({ item }) => (
          <ConversationRow conversation={item} myUid={uid} onOpen={onOpen} />
        )}
      />
    </View>
  );
}

const styles = StyleSheet.create({
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
  list: { padding: theme.spacing.md },
  separator: { backgroundColor: theme.colors.border, height: 1 },
  row: {
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
    height: 44,
    justifyContent: 'center',
    width: 44,
  },
  avatarText: {
    color: theme.colors.navy,
    fontSize: theme.fontSizes.body,
    fontWeight: '700',
  },
  rowBody: { flex: 1, gap: 2 },
  name: {
    color: theme.colors.navy,
    fontSize: theme.fontSizes.body,
    fontWeight: '700',
  },
  listingTitle: { color: theme.colors.primary, fontSize: theme.fontSizes.small },
  lastMessage: { color: theme.colors.grey, fontSize: theme.fontSizes.small },
  lastMessageUnread: { color: theme.colors.navy, fontWeight: '700' },
  rowEnd: { alignItems: 'flex-end', gap: theme.spacing.xs },
  time: { color: theme.colors.grey, fontSize: theme.fontSizes.small },
  timeUnread: { color: theme.colors.primary },
  badge: {
    alignItems: 'center',
    backgroundColor: theme.colors.primary,
    borderRadius: theme.radius.round,
    justifyContent: 'center',
    minWidth: 20,
    paddingHorizontal: 6,
    paddingVertical: 2,
  },
  badgeText: {
    color: theme.colors.white,
    fontSize: theme.fontSizes.small,
    fontWeight: '700',
  },
});