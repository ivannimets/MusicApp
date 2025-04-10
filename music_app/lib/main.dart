import 'package:flutter/material.dart';
import 'package:music_app/providers/loginstate_provider.dart';
import 'package:music_app/views/login_page.dart';
import 'package:music_app/views/splash_screen.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';

void main() {
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginStateProvider(),
      child: MaterialApp(
        title: "Music App",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/loginPage': (context) => LoginPage(),
        },
      ),
    );
  }
}