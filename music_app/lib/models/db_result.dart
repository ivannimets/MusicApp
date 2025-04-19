import 'package:music_app/models/playlist_model.dart';

// Standardizes Database results according to table queried
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

class DBSongListResult {
  final bool isSuccess;
  final String message;
  List<Song> songList;

  DBSongListResult({required this.isSuccess, required this.message, required this.songList});
}