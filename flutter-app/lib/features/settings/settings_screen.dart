import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_links.dart';
import '../../core/config/locale_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/filter_tag.dart';
import '../../core/widgets/rtl_helpers.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/auth_controller.dart';
import '../auth/delete_account_dialog.dart';
import '../auth/forgot_password_dialog.dart';

/// Settings opened from the Profile tab (VST-95): language, about, sign out,
/// delete account (VST-84).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// Names are always written in their own language.
  static const _languages = {
    'ar': 'العربية التونسية',
    'fr': 'Français',
    'en': 'English',
  };

  Future<void> _open(BuildContext context, Uri uri) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!opened) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsLinkError)));
    }
  }

  void _signOut(BuildContext context, WidgetRef ref) {
    ref.read(authControllerProvider.notifier).signOut();
    // Back to the guest home: nothing of the previous user stays on screen.
    context.go(AppRoutes.explore);
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final deleted = await showDeleteAccountDialog(context);
    if (!deleted) return;

    // The account is gone: back to the guest home.
    router.go(AppRoutes.explore);
    messenger.showSnackBar(SnackBar(content: Text(l10n.deleteAccountDone)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = Localizations.localeOf(context).languageCode;
    final signedIn = ref.watch(authStateProvider).value != null;
    final privacyUri = Uri.parse(AppLinks.privacyAndDeletionUrl);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _SectionTitle(l10n.languageLabel),
        _SettingsCard(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final entry in _languages.entries)
                    FilterTag(
                      label: entry.value,
                      selected: current == entry.key,
                      onTap: () => ref
                          .read(localeProvider.notifier)
                          .setLocale(Locale(entry.key)),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (signedIn) ...[
          _SectionTitle(l10n.settingsAccount),
          _SettingsCard(
            children: [
              _SettingsRow(
                title: l10n.settingsChangePassword,
                chevron: true,
                onTap: () => showForgotPasswordDialog(
                  context,
                  initialEmail:
                      ref.read(authStateProvider).value?.email ?? '',
                ),
              ),
              _SettingsRow(
                title: l10n.notificationsTitle,
                chevron: true,
                onTap: () => context.push(AppRoutes.notifications),
              ),
            ],
          ),
        ],
        _SectionTitle(l10n.settingsAbout),
        _SettingsCard(
          children: [
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final info = snapshot.data;
                return _SettingsRow(
                  title: l10n.settingsVersion,
                  trailing: info == null
                      ? null
                      : LtrText(
                          '${info.version}+${info.buildNumber}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                );
              },
            ),
            _SettingsRow(
              title: l10n.settingsPrivacy,
              chevron: true,
              onTap: () => _open(context, privacyUri),
            ),
            _SettingsRow(
              title: l10n.settingsContact,
              subtitle: AppLinks.contactEmail,
              chevron: true,
              onTap: () => _open(
                context,
                Uri(scheme: 'mailto', path: AppLinks.contactEmail),
              ),
            ),
          ],
        ),
        if (signedIn) ...[
          const SizedBox(height: AppSpacing.lg),
          _SettingsCard(
            children: [
              _SettingsRow(
                title: l10n.authLogoutButton,
                danger: true,
                onTap: () => _signOut(context, ref),
              ),
              _SettingsRow(
                title: l10n.settingsDeleteAccount,
                danger: true,
                onTap: () => _deleteAccount(context),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.sm,
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(color: AppColors.grey),
      ),
    );
  }
}

/// White rounded block that groups rows, with thin dividers between them.
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.border),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    this.subtitle,
    this.trailing,
    this.chevron = false,
    this.danger = false,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool chevron;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: AppTextStyles.subtitle.copyWith(
          color: danger ? AppColors.error : AppColors.navy,
          fontWeight: FontWeight.w400,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : LtrText(
              subtitle!,
              style: AppTextStyles.caption.copyWith(color: AppColors.grey),
            ),
      trailing: chevron
          ? const DirectionalIcon(Icons.chevron_right, color: AppColors.grey)
          : trailing,
    );
  }
}
