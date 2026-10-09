import 'package:flutter/material.dart';

import 'gen/assets.gen.dart';

final class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Image.asset(Assets.images.splashScreen.path, fit: BoxFit.cover),
      ),
    );
  }
}
