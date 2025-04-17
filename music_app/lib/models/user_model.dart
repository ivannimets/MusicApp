import 'package:music_app/models/cached_song.dart';

class UserModel {

  String username;
  String password;
  bool isLoggedIn;
  String errorMessage;

  CachedSong? currentSong;

  UserModel({
    this.username = '',
    this.password = '',
    this.isLoggedIn = false,
    this.errorMessage = '',
    this.currentSong
  });
}