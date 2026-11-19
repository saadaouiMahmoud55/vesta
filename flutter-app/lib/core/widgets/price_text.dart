import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../config/app_config.dart';

/// Price with its unit, e.g. `TND 120 / night`. Uses `formatPrice` (the only
/// function that formats a price) and always reads left-to-right, also inside
/// an Arabic screen.
///
/// [period] is the `rentPeriod` of the listing: `night`, `month` or `year`.
/// Leave it null for a sale (no unit).
class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.price,
    this.currency,
    this.period,
    this.priceStyle,
    this.unitStyle,
  });

  final num price;
  final String? currency;
  final String? period;
  final TextStyle? priceStyle;
  final TextStyle? unitStyle;

  static String? _unitLabel(AppLocalizations l10n, String? period) {
    switch (period) {
      case 'night':
        return l10n.unitNight;
      case 'month':
        return l10n.unitMonth;
      case 'year':
        return l10n.unitYear;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final unit = _unitLabel(l10n, period);
    final given = currency;
    final code = (given == null || given.isEmpty) ? null : given;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: formatPrice(price, currency: code),
              style:
                  priceStyle ??
                  theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (unit != null)
              TextSpan(
                text: ' $unit',
                style:
                    unitStyle ??
                    theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}
