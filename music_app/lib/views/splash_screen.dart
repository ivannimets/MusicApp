import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    //Creates an animation controller to spin the icon
    controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    //Pushes the user to the login screen after 3 seconds
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
        //Builds an animation using the already defined controller, Rotates the child
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: controller.value * 10 * pi,
              child: child,
            );
          },
            //Adds the icon that will be displayed and animated
          child: Icon(Icons.music_note, color: AppColors.textPrimary, size: 50,)),
        ),
      );
  }
}
