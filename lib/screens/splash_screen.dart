import 'package:flutter/material.dart';

import '../config/app_branding.dart';
import '../widgets/gradeglow_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 2), widget.onFinished);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const GradeGlowLogo(height: 160),
            const SizedBox(height: 20),
            Text(
              AppBranding.tagline,
              style: TextStyle(color: AppBranding.navy.withValues(alpha: 0.65), fontSize: 16),
            ),
            const SizedBox(height: 52),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppBranding.glowOrange.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
