import 'package:flutter/material.dart';

/// True when the app is shown right-to-left (Arabic).
bool isRtl(BuildContext context) =>
    Directionality.of(context) == TextDirection.rtl;

/// Icon that flips in Arabic (back arrow, chevrons). Give it the left-to-right
/// icon, for example `Icons.chevron_right`.
class DirectionalIcon extends StatelessWidget {
  const DirectionalIcon(this.icon, {super.key, this.size, this.color});

  final IconData icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: isRtl(context),
      child: Icon(icon, size: size, color: color),
    );
  }
}

/// Text that always reads left-to-right, even inside an Arabic screen:
/// phone numbers, prices, areas.
class LtrText extends StatelessWidget {
  const LtrText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text(text, style: style),
    );
  }
}
