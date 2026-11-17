import 'package:flutter/material.dart';

/// The Vesta logo (door and wordmark) shown above the title of the login and
/// sign-up screens. The file comes from docs/brand (VST-65, VST-94).
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/logo.png',
        key: const Key('auth-logo'),
        width: 160,
        height: 160,
        semanticLabel: 'Vesta',
      ),
    );
  }
}
