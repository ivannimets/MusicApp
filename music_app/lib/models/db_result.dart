import 'package:music_app/models/playlist_model.dart';

class DBPlaylistResult {
  final bool isSuccess;
  final String message;
  List<Playlist> playlistList;

  DBPlaylistResult({required this.isSuccess, required this.message, required this.playlistList});
}

class DBGenreResult {
  final bool isSuccess;
  final String message;
  List<Genre> genreList;

  DBGenreResult({required this.isSuccess, required this.message, required this.genreList});
}