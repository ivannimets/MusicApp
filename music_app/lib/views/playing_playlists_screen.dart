import 'package:flutter/material.dart';
import 'package:music_app/core/app_colors.dart';
import 'package:music_app/database/db_helper.dart';
import 'package:music_app/models/db_result.dart';
import 'package:music_app/models/playlist_arguments_model.dart';
import 'package:music_app/models/playlist_model.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/widgets/bottom_nav.dart';
import 'package:provider/provider.dart';

import '../providers/loginstate_provider.dart';

class PlayingPlaylistsScreen extends StatefulWidget {
  const PlayingPlaylistsScreen({super.key});

  @override
  PlayingPlaylistsScreenState createState() => PlayingPlaylistsScreenState();
}

class PlayingPlaylistsScreenState extends State<PlayingPlaylistsScreen> {
  List<Playlist> _playlists = [];
  String _message = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlaylists();
  }

  Future<void> fetchPlaylists() async {
    DBPlaylistResult result = await DBHelper.dbMusicApp.getAllPlaylists();

    setState(() {
      _isLoading = false;

      if (result.isSuccess) {
        _playlists = result.playlistList;
      } else {
        _message = result.message;
      }
    });
  }

  Future<void> addToPlaylist(int playlistId, String songUUID) async {
    final songListResult = await DBHelper.dbMusicApp.getSongsOfPlaylist(playlistId);

    if (songListResult.songList.any((song) => song.songLink == songUUID)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("That song is already on this playlist!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final addSongResult = await DBHelper.dbMusicApp
        .addSongToPlaylist(Song(songLink: songUUID), playlistId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Successfully added song to the playlist!"),
        backgroundColor: addSongResult.isSuccess ? AppColors.primary : Colors.redAccent,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginStateProvider>(context);
    CachedSong? song = loginState.user.currentSong;

    return Scaffold(
      appBar: AppBar(
        title: Text("Music App"),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        context: context,
        currentIndex: 2,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Add song to the playlist",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              "${_playlists.length} playlists",
              style: TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _playlists.isEmpty
                      ? Center(
                          child: Text(
                            _message,
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _playlists.length,
                          itemBuilder: (context, index) {
                            final Playlist playlist = _playlists[index];
                            return Card(
                              child: ListTile(
                                leading: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Image.network(playlist.imageLink),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      playlist.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      playlist.genre!.name,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(playlist.description),
                                    Text("${playlist.songs!.length} songs"),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      iconSize: 30,
                                      onPressed: () => addToPlaylist(
                                          playlist.playlistId!, song!.uuid),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
