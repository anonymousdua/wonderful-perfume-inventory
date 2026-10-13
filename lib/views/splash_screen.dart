import 'package:flutter/material.dart';

import '../routes/route_generator.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    // Fade the logo in, hold, then go to the shell.
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _opacity = 1);
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        RouteGenerator.home,
        arguments: 'Wonderful Perfumes',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.plum,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 900),
          child: Image.asset(
            'assets/logo.png',
            width: 240,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
