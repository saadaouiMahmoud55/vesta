import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Pill chip used for filters and choices (property type, period, language).
class FilterTag extends StatelessWidget {
  const FilterTag({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      backgroundColor: AppColors.white,
      selectedColor: AppColors.primary,
      labelStyle: AppTextStyles.body.copyWith(
        color: selected ? AppColors.white : AppColors.navy,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }
}
