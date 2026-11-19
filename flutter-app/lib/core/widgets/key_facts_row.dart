import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// One fact: an icon and a short value, e.g. bed icon and `3`.
class KeyFact {
  const KeyFact({required this.icon, required this.value});

  final IconData icon;
  final String value;
}

/// Row of key facts (rooms, bathrooms, area, guests...). The values read
/// left-to-right in Arabic. The facts of a listing depend on its offer type
/// (docs/offer-types.md, section 3): the screen builds the list.
class KeyFactsRow extends StatelessWidget {
  const KeyFactsRow({super.key, required this.facts});

  final List<KeyFact> facts;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.xs,
      children: [
        for (final fact in facts)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(fact.icon, size: 16, color: color),
              const SizedBox(width: AppSpacing.xs),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  fact.value,
                  style: AppTextStyles.caption.copyWith(color: color),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
