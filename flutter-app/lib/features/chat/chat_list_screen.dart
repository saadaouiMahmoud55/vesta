import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_avatar.dart';
import '../../core/widgets/app_states.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/auth_controller.dart';
import '../auth/require_sign_in.dart';
import 'chat_controller.dart';
import 'chat_models.dart';

/// All the conversations of the signed-in user, newest first (VST-44).
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authStateProvider);
    final me = auth.value;

    // The router already sends a guest away; this covers a sign-out while
    // the screen is open.
    if (me == null) {
      return SignInPrompt(
        icon: Icons.chat_bubble_outline,
        title: l10n.chatTitle,
      );
    }

    final conversations = ref.watch(conversationsProvider);
    return conversations.when(
      loading: () => const LoadingView(),
      error: (error, stackTrace) => ErrorState(
        message: l10n.chatLoadError,
        onRetry: () => ref.invalidate(conversationsProvider),
      ),
      data: (list) => list.isEmpty
          ? EmptyState(
              icon: Icons.chat_bubble_outline,
              title: l10n.chatEmptyTitle,
              message: l10n.chatEmptyBody,
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // One white card, rows separated by thin dividers.
                Material(
                  color: AppColors.white,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < list.length; i++) ...[
                        if (i > 0)
                          const Divider(height: 1, color: AppColors.border),
                        ConversationTile(conversation: list[i], myUid: me.uid),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// One row of the conversation list. Also used by the notification center.
class ConversationTile extends ConsumerWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.myUid,
  });

  final Conversation conversation;
  final String myUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final otherId = conversation.otherUserId(myUid);
    final name = ref.watch(userNameProvider(otherId)).value;
    final displayName = name ?? l10n.chatUnknownUser;

    final listingAsync = ref.watch(
      conversationListingProvider(conversation.listingId),
    );
    final listingTitle = listingAsync.when(
      data: (listing) => listing?.title ?? l10n.chatListingRemoved,
      loading: () => '',
      error: (_, _) => '',
    );

    final unread = conversation.unreadFor(myUid);
    final lastMessage = conversation.lastMessage;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      leading: AppAvatar(name: displayName),
      title: Text(
        displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.subtitle.copyWith(
          color: AppColors.navy,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (listingTitle.isNotEmpty)
            Text(
              listingTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
          if (lastMessage.isNotEmpty)
            // The direction follows the message, not the app language.
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: textDirectionFor(lastMessage),
                style: AppTextStyles.bodySmall.copyWith(
                  color: unread > 0 ? AppColors.navy : AppColors.grey,
                  fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _timeText(context, conversation.lastMessageAt),
            style: AppTextStyles.small.copyWith(
              color: unread > 0 ? AppColors.primary : AppColors.grey,
            ),
          ),
          if (unread > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Badge(
              backgroundColor: AppColors.primary,
              textColor: AppColors.white,
              label: Text('$unread'),
            ),
          ],
        ],
      ),
      onTap: () => context.push(AppRoutes.chatRoomPath(conversation.id)),
    );
  }
}

/// "14:05" for today, "5 Nov" for older messages, in the app language.
String _timeText(BuildContext context, DateTime? time) {
  if (time == null) return '';
  final locale = Localizations.localeOf(context).toString();
  final now = DateTime.now();
  final local = time.toLocal();
  final today =
      local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
  return today
      ? DateFormat.Hm(locale).format(local)
      : DateFormat.MMMd(locale).format(local);
}
