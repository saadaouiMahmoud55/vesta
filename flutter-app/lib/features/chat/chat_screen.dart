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
import '../../core/widgets/rtl_helpers.dart';
import '../../core/widgets/price_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/require_sign_in.dart';
import '../listings/listing.dart';
import 'chat_controller.dart';
import 'chat_models.dart';
import 'chat_repository.dart';

/// One conversation: realtime messages, newest at the bottom, and a box to
/// write (VST-44). The conversation is between the buyer (from the id) and
/// the owner of the listing.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;
  int _lastCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _errorText(AppLocalizations l10n, ChatError error) {
    switch (error) {
      case ChatError.noNetwork:
        return l10n.chatSendError;
      case ChatError.permissionDenied:
      case ChatError.notSignedIn:
      case ChatError.ownListing:
      case ChatError.messageTooLong:
      case ChatError.unknown:
        return l10n.chatSendFailed;
    }
  }

  Future<void> _send(String ownerId) async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _sending = true);
    final error = await sendChatMessage(
      ref,
      conversationId: widget.conversationId,
      ownerId: ownerId,
      text: text,
    );
    if (!mounted) return;
    setState(() => _sending = false);
    if (error == null || error == ChatError.noNetwork) {
      // Offline: the message stays in the list as "sending" and leaves by
      // itself when the network is back, so the box is emptied either way.
      _controller.clear();
    }
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(_errorText(l10n, error))));
    }
  }

  /// Marks the conversation as read when new messages arrive while it is open.
  void _markReadIfNeeded(String myUid) {
    final conversations = ref.read(conversationsProvider).value;
    final mine = conversations
        ?.where((c) => c.id == widget.conversationId)
        .firstOrNull;
    if (mine != null && mine.unreadFor(myUid) > 0) {
      ref
          .read(chatRepositoryProvider)
          .markRead(widget.conversationId)
          .catchError((_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final myUid = ref.watch(myUidProvider);
    if (myUid == null) {
      return SignInPrompt(
        icon: Icons.chat_bubble_outline,
        title: l10n.chatTitle,
      );
    }

    final ids = parseConversationId(widget.conversationId);
    if (ids == null) {
      return Center(child: Text(l10n.chatLoadError));
    }
    final listingAsync = ref.watch(conversationListingProvider(ids.listingId));
    final listing = listingAsync.value;
    final ownerId = listing?.ownerId ?? '';
    final otherId = myUid == ids.buyerId ? ownerId : ids.buyerId;
    final otherName = ref.watch(userNameProvider(otherId)).value;

    // Opening or receiving messages clears the unread badge.
    ref.listen(conversationsProvider, (_, _) => _markReadIfNeeded(myUid));

    // The conversation document is created with the FIRST message. Before
    // that, the rules refuse to read its messages (there is nobody in the
    // conversation yet), and the provider would retry forever: the screen
    // stayed on a spinner. So we only listen to the messages once the
    // conversation exists. null = still checking.
    final conversations = ref.watch(conversationsProvider);
    final bool? exists = conversations.hasError
        ? false
        : conversations.value?.any((c) => c.id == widget.conversationId);

    if (exists == true) {
      ref.listen(messagesProvider(widget.conversationId), (_, next) {
        final count = next.value?.length ?? 0;
        _markReadIfNeeded(myUid);
        if (count > _lastCount && _scroll.hasClients) {
          // The list is reversed: 0 is the bottom, where the newest message is.
          _scroll.animateTo(
            0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
        _lastCount = count;
      });
    }

    final messages = exists == true
        ? ref.watch(messagesProvider(widget.conversationId))
        : null;

    return Column(
      children: [
        _Header(name: otherName ?? l10n.chatUnknownUser),
        if (listing != null)
          _ListingStrip(listing: listing)
        else if (!listingAsync.isLoading)
          _ListingRemovedStrip(text: l10n.chatListingRemoved),
        Expanded(
          child: exists == false
              ? Center(
                  child: Text(
                    l10n.chatNoMessages,
                    style: AppTextStyles.body.copyWith(color: AppColors.grey),
                  ),
                )
              : messages == null
              ? const LoadingView()
              : messages.when(
            loading: () => const LoadingView(),
            error: (error, stackTrace) => ErrorState(
              message: l10n.chatLoadError,
              onRetry: () =>
                  ref.invalidate(messagesProvider(widget.conversationId)),
            ),
            data: (list) => list.isEmpty
                ? Center(
                    child: Text(
                      l10n.chatNoMessages,
                      style: AppTextStyles.body.copyWith(color: AppColors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    reverse: true,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final message = list[index];
                      // The list is newest-first: the next index is older.
                      final older = index + 1 < list.length
                          ? list[index + 1]
                          : null;
                      final showDay =
                          message.createdAt != null &&
                          (older?.createdAt == null ||
                              !_sameDay(message.createdAt!, older!.createdAt!));
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showDay) _DaySeparator(date: message.createdAt!),
                          _Bubble(
                            message: message,
                            mine: message.senderId == myUid,
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
        _Composer(
          controller: _controller,
          sending: _sending,
          enabled: ownerId.isNotEmpty,
          onSend: () => _send(ownerId),
        ),
      ],
    );
  }
}

bool _sameDay(DateTime a, DateTime b) {
  final x = a.toLocal();
  final y = b.toLocal();
  return x.year == y.year && x.month == y.month && x.day == y.day;
}

class _DaySeparator extends StatelessWidget {
  const _DaySeparator({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final day = date.toLocal();
    final now = DateTime.now();
    final String label;
    if (_sameDay(day, now)) {
      label = l10n.chatToday;
    } else if (_sameDay(day, now.subtract(const Duration(days: 1)))) {
      label = l10n.chatYesterday;
    } else {
      label = DateFormat.yMMMd(locale).format(day);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.sand,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            label,
            style: AppTextStyles.small.copyWith(color: AppColors.grey),
          ),
        ),
      ),
    );
  }
}

/// The listing this conversation is about: title and price, opens the listing.
class _ListingStrip extends StatelessWidget {
  const _ListingStrip({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sand,
      child: InkWell(
        onTap: () => context.push(AppRoutes.listingDetailPath(listing.id)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.sensor_door_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  listing.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              PriceText(
                price: listing.price,
                currency: listing.currency,
                period: listing.rentPeriod,
                priceStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
                unitStyle: AppTextStyles.small.copyWith(color: AppColors.grey),
              ),
              const DirectionalIcon(
                Icons.chevron_right,
                color: AppColors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListingRemovedStrip extends StatelessWidget {
  const _ListingRemovedStrip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sand,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    // White bar under the app bar: avatar, name, and the listing in primary.
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          AppAvatar(name: name, radius: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});

  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final background = mine ? AppColors.primary : AppColors.white;
    final foreground = mine ? AppColors.white : AppColors.navy;
    final time = message.createdAt;
    final locale = Localizations.localeOf(context).toString();

    return Align(
      // My messages on the end side, the other person's on the start side.
      alignment: mine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // The direction follows the message, not the app language.
            Text(
              message.text,
              textDirection: textDirectionFor(message.text),
              style: AppTextStyles.body.copyWith(color: foreground),
            ),
            const SizedBox(height: 2),
            Text(
              time == null
                  ? l10n.chatSending
                  : DateFormat.Hm(locale).format(time.toLocal()),
              style: AppTextStyles.small.copyWith(
                color: foreground.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) => TextField(
                  controller: controller,
                  enabled: enabled,
                  maxLength: maxMessageLength,
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  // Arrow and cursor follow what the person types.
                  textDirection: textDirectionFor(
                    value.text,
                    fallback: Directionality.of(context),
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.chatMessageHint,
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.sand,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) => IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
                tooltip: l10n.chatSend,
                onPressed: enabled && !sending && value.text.trim().isNotEmpty
                    ? onSend
                    : null,
                icon: sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
