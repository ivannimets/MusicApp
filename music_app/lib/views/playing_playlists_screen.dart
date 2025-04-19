import 'package:flutter/material.dart';
import 'package:music_app/core/app_colors.dart';
import 'package:music_app/database/db_helper.dart';
import 'package:music_app/models/db_result.dart';
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
  //List of the playlists
  List<Playlist> playlists = [];
  String message = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    //Fetches the playlists
    fetchPlaylists();
  }

  //Method to populate the playlists List from the Database
  Future<void> fetchPlaylists() async {
    DBPlaylistResult result = await DBHelper.dbMusicApp.getAllPlaylists();

    //Either sets the error message, or the List of playlists
    setState(() {
      isLoading = false;

      if (result.isSuccess) {
        playlists = result.playlistList;
      } else {
        message = result.message;
      }
    });
  }

  //Method to add a song to the playlist and add it to the DB
  Future<void> addToPlaylist(int playlistId, String songUUID) async {
    //Gets the current Songs in the playlist, to allow us to check if its a duplicate
    final songListResult =
        await DBHelper.dbMusicApp.getSongsOfPlaylist(playlistId);

    //Checks if the song is a duplicate and shows a snackbar if it is.
    if (songListResult.songList.any((song) => song.songLink == songUUID)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("That song is already on this playlist!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    //Gets the DB Result of adding the song to the playlist
    final addSongResult = await DBHelper.dbMusicApp
        .addSongToPlaylist(Song(songLink: songUUID), playlistId);

    //Refetches the playlists
    setState(() {
      fetchPlaylists();
    });

    //Shows a snackbar with the outcome of the operation
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
    //Grabs the global login state
    final loginState = Provider.of<LoginStateProvider>(context);
    //Grabs the user's currently playing song
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
              //Loops through the list of playlists and creates a card for each one
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
                                    //Grabs the image or the placeholder image
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
                                //Shows the Playlist name and then the Genre
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
                                //Shows the description and song count for the playlist
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(playlist.description),
                                    Text("${playlist.songs!.length} songs"),
                                  ],
                                ),
                                //Adds the button that runs the method to add song to the playlist
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
            //Button to go back to the playing screen
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
