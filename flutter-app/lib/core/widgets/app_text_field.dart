import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'rtl_helpers.dart';

/// Text field with its label above and an error text below (the error is
/// shown when [errorText] is not null). Use [ltr] for phone numbers and
/// prices, which stay left-to-right in Arabic.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.errorText,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.ltr = false,
    this.suffixIcon,
    this.onChanged,
  });

  final String label;
  final TextEditingController? controller;
  final String? errorText;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final bool ltr;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTextStyles.caption.copyWith(color: AppColors.grey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ltr
            ? LtrText(label, style: labelStyle)
            : Text(label, style: labelStyle),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          maxLines: maxLines,
          maxLength: maxLength,
          enabled: enabled,
          onChanged: onChanged,
          textDirection: ltr ? TextDirection.ltr : null,
          style: AppTextStyles.body.copyWith(color: AppColors.navy),
          decoration: InputDecoration(
            hintText: hintText,
            hintTextDirection: ltr ? TextDirection.ltr : null,
            errorText: errorText,
            errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            border: _border(AppColors.border),
            enabledBorder: _border(AppColors.border),
            disabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.primary, 1.5),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error, 1.5),
          ),
        ),
      ],
    );
  }
}
