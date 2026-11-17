import 'package:flutter/material.dart';

/// Fades a child in while it slides up a little. Plays once when the widget
/// is first built, so a list feels alive without any infinite animation.
class FadeInUp extends StatelessWidget {
  const FadeInUp({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;

  /// Wait before the animation starts (used to stagger the first cards).
  final Duration delay;

  static const _duration = Duration(milliseconds: 350);

  @override
  Widget build(BuildContext context) {
    final total = _duration + delay;
    final start = delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: child,
        ),
      ),
    );
  }
}
