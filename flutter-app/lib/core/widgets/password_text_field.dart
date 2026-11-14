import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import 'app_text_field.dart';

/// [AppTextField] for a password, with an eye button at the end of the field
/// to show or hide what is typed. The password is hidden at first.
class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    super.key,
    required this.label,
    this.controller,
    this.errorText,
    this.textInputAction,
    this.onChanged,
  });

  final String label;
  final TextEditingController? controller;
  final String? errorText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppTextField(
      label: widget.label,
      controller: widget.controller,
      errorText: widget.errorText,
      obscureText: _hidden,
      textInputAction: widget.textInputAction,
      ltr: true,
      onChanged: widget.onChanged,
      suffixIcon: IconButton(
        icon: Icon(
          _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.grey,
        ),
        tooltip: _hidden ? l10n.authShowPassword : l10n.authHidePassword,
        onPressed: () => setState(() => _hidden = !_hidden),
      ),
    );
  }
}
