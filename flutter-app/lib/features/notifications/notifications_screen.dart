import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/app_states.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/require_sign_in.dart';
import '../chat/chat_controller.dart';
import '../chat/chat_list_screen.dart';
import '../chat/chat_models.dart';

/// Notification center (VST-99). The app has no server push, so a
/// "notification" is a conversation with messages the user has not read yet.
/// It disappears from here when the chat is opened (the unread counter is
/// reset there). It reuses the conversation list, so no second Firestore
/// listener is opened.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final myUid = ref.watch(myUidProvider);

    // The router already sends a guest away; this covers a sign-out while
    // the screen is open.
    if (myUid == null) {
      return SignInPrompt(
        icon: Icons.notifications_none,
        title: l10n.notificationsTitle,
      );
    }

    final conversations = ref.watch(conversationsProvider);
    return conversations.when(
      loading: () => const LoadingView(),
      error: (error, stackTrace) => ErrorState(
        message: l10n.chatLoadError,
        onRetry: () => ref.invalidate(conversationsProvider),
      ),
      data: (list) {
        final unread = unreadConversations(list, myUid);
        if (unread.isEmpty) {
          return EmptyState(
            icon: Icons.notifications_none,
            title: l10n.notificationsEmptyTitle,
            message: l10n.notificationsEmptyBody,
          );
        }
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Same white card as the conversation list.
            Material(
              color: AppColors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < unread.length; i++) ...[
                    if (i > 0)
                      const Divider(height: 1, color: AppColors.border),
                    ConversationTile(conversation: unread[i], myUid: myUid),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
