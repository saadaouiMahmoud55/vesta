import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/utils/phone_utils.dart';
import '../../core/widgets/app_avatar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_top_bar.dart';
import '../../core/widgets/password_text_field.dart';
import '../../core/widgets/photo_viewer.dart';
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
  bool _removePhoto = false; // the user asked to remove the current photo
  String? _nameError; // shown under the field
  late final TextEditingController _phoneController;
  String? _phoneError;
  bool _phoneLoaded = false; // true once the saved phone is read
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final String _originalEmail;
  String? _emailError;
  String? _passwordError;

  bool get _emailChanged => _emailController.text.trim() != _originalEmail;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.displayName);
    _phoneController = TextEditingController();
    _originalEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    _emailController = TextEditingController(text: _originalEmail);
    _passwordController = TextEditingController();
    ref.read(userRepositoryProvider).loadPhone().then((phone) {
      if (!mounted) return;
      setState(() {
        _phoneLoaded = true;
        if (phone != null && _phoneController.text.isEmpty) {
          _phoneController.text = formatPhone(phone);
        }
      });
    });
    // Clear an old error left by another screen (after the first build).
    Future.microtask(() {
      if (mounted) ref.read(profileControllerProvider.notifier).clearError();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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

    final photo = await ref
        .read(profileControllerProvider.notifier)
        .pickPhoto(source);
    if (photo != null && mounted) {
      setState(() {
        _newPhotoBase64 = photo;
        _removePhoto = false;
      });
    }
  }

  /// The photo shown now: a new one, else the saved one, else none.
  String? get _shownPhoto {
    if (_newPhotoBase64 != null) return _newPhotoBase64;
    return _removePhoto ? null : widget.profile.photoBase64;
  }

  void _clearPhoto() {
    setState(() {
      _newPhotoBase64 = null;
      _removePhoto = true;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final error = validateDisplayName(_nameController.text);
    final phoneError = validatePhone(_phoneController.text);
    final emailChanged = _emailChanged;
    final emailError = emailChanged
        ? validateEmail(_emailController.text)
        : null;
    final passwordError = emailChanged
        ? validatePassword(_passwordController.text)
        : null;
    setState(() {
      _nameError = error == null ? null : profileErrorMessage(l10n, error);
      _phoneError = phoneError == null
          ? null
          : profileErrorMessage(l10n, phoneError);
      _emailError = emailError == null
          ? null
          : profileErrorMessage(l10n, emailError);
      _passwordError = passwordError == null
          ? null
          : profileErrorMessage(l10n, passwordError);
    });
    if (error != null ||
        phoneError != null ||
        emailError != null ||
        passwordError != null) {
      return;
    }

    final controller = ref.read(profileControllerProvider.notifier);
    final saved = await controller.save(
      displayName: _nameController.text,
      photoBase64: _newPhotoBase64,
      removePhoto: _removePhoto,
      phone: _phoneLoaded ? _phoneController.text : null,
    );
    if (!saved || !mounted) return;

    if (emailChanged) {
      final sent = await controller.changeEmail(
        newEmail: _emailController.text,
        password: _passwordController.text,
      );
      if (!sent || !mounted) return; // the error is shown under the form
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(emailChanged ? l10n.profileEmailSent : l10n.profileSaved),
      ),
    );
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
                // With a photo, a tap shows it full size; "Change photo" below
                // picks another one. Without a photo, a tap picks one.
                onTap: state.isLoading
                    ? null
                    : (_shownPhoto ?? '').isNotEmpty
                    ? () => showPhotoViewer(context, _shownPhoto)
                    : _choosePhoto,
                child: AppAvatar(
                  photoBase64: _shownPhoto,
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
            if (_shownPhoto != null && _shownPhoto!.isNotEmpty)
              Center(
                child: TextButton.icon(
                  onPressed: state.isLoading ? null : _clearPhoto,
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.profileRemovePhoto),
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
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: l10n.profilePhoneLabel,
              hintText: '+216 20 123 456',
              controller: _phoneController,
              enabled: !state.isLoading && _phoneLoaded,
              textInputAction: TextInputAction.done,
              ltr: true,
              errorText: _phoneError,
              onChanged: (_) {
                if (_phoneError != null) setState(() => _phoneError = null);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: l10n.profileEmailLabel,
              controller: _emailController,
              enabled: !state.isLoading,
              textInputAction: TextInputAction.done,
              ltr: true,
              errorText: _emailError,
              onChanged: (_) => setState(() => _emailError = null),
            ),
            if (_emailChanged) ...[
              const SizedBox(height: AppSpacing.lg),
              PasswordTextField(
                label: l10n.profilePasswordLabel,
                controller: _passwordController,
                errorText: _passwordError,
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                },
              ),
            ],
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
