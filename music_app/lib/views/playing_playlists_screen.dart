import 'package:flutter/material.dart';
import 'package:music_app/core/app_colors.dart';
import 'package:music_app/database/db_helper.dart';
import 'package:music_app/models/db_result.dart';
import 'package:music_app/models/playlist_arguments_model.dart';
import 'package:music_app/models/playlist_model.dart';
import 'package:music_app/models/cached_song.dart';
import 'package:music_app/widgets/bottom_nav.dart';
import 'package:provider/provider.dart';

import '../providers/loginstate_provider.dart';

class PlayingPlaylistsScreen extends StatefulWidget {
  const PlayingPlaylistsScreen({super.key});

  @override
  PlayingPlaylistsScreenState createState() => PlayingPlaylistsScreenState();
}

class PlayingPlaylistsScreenState extends State<PlayingPlaylistsScreen> {
  List<Playlist> playlists = [];
  String message = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlaylists();
  }

  Future<void> fetchPlaylists() async {
    DBPlaylistResult result = await DBHelper.dbMusicApp.getAllPlaylists();

    setState(() {
      isLoading = false;

      if (result.isSuccess) {
        playlists = result.playlistList;
      } else {
        message = result.message;
      }
    });
  }

  Future<void> addToPlaylist(int playlistId, String songUUID) async {
    final songListResult =
        await DBHelper.dbMusicApp.getSongsOfPlaylist(playlistId);

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

    setState(() {
      fetchPlaylists();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          addSongResult.isSuccess
              ? "Successfully added song to the playlist!"
              : "Failed to add song to playlist",
          style: TextStyle(
              color: addSongResult.isSuccess
                  ? AppColors.background
                  : AppColors.textPrimary),
        ),
        backgroundColor:
            addSongResult.isSuccess ? AppColors.primary : Colors.redAccent,
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
              "${playlists.length} playlists",
              style: TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : playlists.isEmpty
                      ? Center(
                          child: Text(
                            message,
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: playlists.length,
                          itemBuilder: (context, index) {
                            final Playlist playlist = playlists[index];
                            return Card(
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: playlist.imageLink != null &&
                                            playlist.imageLink!.isNotEmpty
                                        ? Image.network(
                                            playlist.imageLink!,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'assets/images/placeholder.jpg',
                                            fit: BoxFit.cover,
                                          ),
                                  ),
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
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Done"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
