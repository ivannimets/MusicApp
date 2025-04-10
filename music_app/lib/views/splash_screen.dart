import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    Timer(Duration(seconds: 3), () {
      Navigator.pushNamedAndRemoveUntil(context, '/loginPage', (route) => false);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: controller.value * 2 * pi,
              child: child,
            );
          },
          child: Icon(Icons.note)),
        ),
      );
  }
}
