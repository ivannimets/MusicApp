import 'package:flutter/material.dart';
import 'package:music_app/providers/loginstate_provider.dart';
import 'package:music_app/views/add_playlist_screen.dart';
import 'package:music_app/views/contact_page.dart';
import 'package:music_app/views/edit_playlist_screen.dart';
import 'package:music_app/views/login_page.dart';
import 'package:music_app/views/playing_playlists_screen.dart';
import 'package:music_app/views/playlist_page.dart';
import 'package:music_app/views/playlists_screen.dart';
import 'package:music_app/views/playing_page.dart';
import 'package:music_app/views/search_page.dart';
import 'package:music_app/views/splash_screen.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';

void main() {
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          '/playlistsPage': (context) => PlaylistsScreen(),
          '/addPlaylist': (context) => AddPlaylistScreen(),
          '/editPlaylist': (context) => EditPlaylistScreen(),
          '/playingPage': (context) => PlayingPage(),
          '/playingPlaylistPage': (context) => PlayingPlaylistsScreen(),
          '/searchPage': (context) => SearchPage(),
          '/contactPage': (context) => ContactPage(),
          '/playlistPage': (context) => PlaylistPage(),
        },
      ),
    );
  }
}