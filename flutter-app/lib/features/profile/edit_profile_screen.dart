import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/app_avatar.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_top_bar.dart';
import '../../l10n/generated/app_localizations.dart';
import 'profile_controller.dart';
import 'profile_messages.dart';
import 'user_repository.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  String? _newPhotoBase64; // set only when the user picked a new photo
  String? _nameError; // shown under the field

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.displayName);
    // Clear an old error left by another screen (after the first build).
    Future.microtask(() {
      if (mounted) ref.read(profileControllerProvider.notifier).clearError();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _choosePhoto() async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.profilePhotoGallery),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.profilePhotoCamera),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return; // sheet dismissed

    final photo =
        await ref.read(profileControllerProvider.notifier).pickPhoto(source);
    if (photo != null && mounted) setState(() => _newPhotoBase64 = photo);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final error = validateDisplayName(_nameController.text);
    setState(() {
      _nameError = error == null ? null : profileErrorMessage(l10n, error);
    });
    if (error != null) return;

    final saved = await ref.read(profileControllerProvider.notifier).save(
          displayName: _nameController.text,
          photoBase64: _newPhotoBase64,
        );
    if (!saved || !mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(profileControllerProvider);

    final String? errorText;
    if (state.error != null) {
      errorText = profileErrorMessage(l10n, state.error!);
    } else if (state.photoError != null) {
      errorText = profilePhotoErrorMessage(l10n, state.photoError!);
    } else {
      errorText = null;
    }

    return Scaffold(
      appBar: AppTopBar(title: l10n.profileEditTitle),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Center(
              child: GestureDetector(
                onTap: state.isLoading ? null : _choosePhoto,
                child: AppAvatar(
                  photoBase64: _newPhotoBase64 ?? widget.profile.photoBase64,
                  name: _nameController.text,
                  radius: 56,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: TextButton.icon(
                onPressed: state.isLoading ? null : _choosePhoto,
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(l10n.profileChangePhoto),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: l10n.profileNameLabel,
              controller: _nameController,
              enabled: !state.isLoading,
              textInputAction: TextInputAction.done,
              errorText: _nameError,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
            if (errorText != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(errorText, style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: l10n.profileSaveButton,
              loading: state.isLoading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}