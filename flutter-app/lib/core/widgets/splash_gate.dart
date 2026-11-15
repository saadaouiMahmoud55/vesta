import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';

/// Shows the Vesta logo and name for a moment when the app starts, then fades
/// out to reveal [child]. The native splash (res/drawable/launch_background)
/// uses the same image and size, so the two look like one screen.
class SplashGate extends StatefulWidget {
  const SplashGate({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1800),
  });

  final Widget child;
  final Duration duration;

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  static const Duration _fade = Duration(milliseconds: 350);
  Timer? _timer;
  bool _showing = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, () {
      if (mounted) setState(() => _showing = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      // This widget sits above MaterialApp, so it sets its own direction.
      textDirection: TextDirection.ltr,
      fit: StackFit.expand,
      children: [
        widget.child,
        IgnorePointer(
          ignoring: !_showing,
          child: AnimatedOpacity(
            key: const Key('splash'),
            opacity: _showing ? 1 : 0,
            duration: _fade,
            // No MaterialApp above: the label of the logo needs a direction.
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: ColoredBox(
                color: AppColors.white,
                child: Center(
                  child: Image(
                    image: AssetImage('assets/images/logo.png'),
                    width: 220,
                    height: 220,
                    semanticLabel: 'Vesta',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
