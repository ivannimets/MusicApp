import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:music_app/core/app_colors.dart';
import 'package:music_app/database/db_helper.dart';
import 'package:music_app/models/cached_song.dart';
import 'package:music_app/models/db_result.dart';
import 'package:music_app/models/playlist_arguments_model.dart';
import 'package:music_app/models/playlist_model.dart';
import 'package:music_app/widgets/bottom_nav.dart';
import 'package:music_app/widgets/drawer_menu.dart';
import 'package:music_app/widgets/song_card.dart';

// Displays a single playlist and its songs.
class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  PlaylistPageState createState() => PlaylistPageState();
}

class PlaylistPageState extends State<PlaylistPage> {
  // The playlist to be displayed
  late final Playlist playlist;
  // Indicates if the playlist and song data are still loading
  bool isLoading = true;
  // List of full song data fetched from the MusicBrainz API
  List<dynamic> songResults = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Trigger initial data fetch once context is available
    if (isLoading) {
      fetchPlaylist();
    }
  }

  // Fetches playlist data from the database and then retrieves song info
  Future<void> fetchPlaylist() async {
    // Extract route arguments to get the playlist ID
    PlaylistArguments args =
        ModalRoute.of(context)!.settings.arguments as PlaylistArguments;
    // Fetch the playlist from local database
    DBPlaylistResult result =
        await DBHelper.dbMusicApp.getPlaylist(args.playlistId);

    if (result.isSuccess) {
      playlist = result.playlistList[0];
      // Fetch additional song info using the MusicBrainz API
      await fetchSongsByUUIDs(
          playlist.songs?.map((e) => e.songLink).toList() ?? []);

      setState(() {
        isLoading = false;
      });
    } else {
      // Handle errors: Show error message and return to previous screen
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.message),
      ));
      Navigator.pop(context);
    }
  }

  // Fetches detailed song information from MusicBrainz API using UUIDs
  Future<void> fetchSongsByUUIDs(List<String> uuids) async {
    List<dynamic> fetchedSongs = [];

    for (String uuid in uuids) {
      final response = await http.get(Uri.parse(
          'https://musicbrainz.org/ws/2/recording/$uuid?fmt=json&inc=artist-credits+releases'));

      if (response.statusCode == 200) {
        final songData = json.decode(response.body);
        fetchedSongs.add(songData);
      }
    }

    songResults = fetchedSongs;
  }

  // Grabs the json item and retrieves and returns the song's artist's name from it.
  String getArtistName(dynamic item) {
    //Ensures the artist and its fields are not null or empty
    if (item['artist-credit'] != null &&
        item['artist-credit'].isNotEmpty &&
        item['artist-credit'][0] != null &&
        item['artist-credit'][0]['name'] != null) {
      String artist = item['artist-credit'][0]['name'] ?? "Unknown Artist";
      //Clamps the display length of the artist name to 15 characters to prevent overflows
      if (artist.length > 15) artist = "${artist.substring(0, 15)}...";

      //Returns the artist
      return artist;
    }
    //Returns that it couldnt find an artist
    return 'Unknown Artist';
  }

  // Grabs the json item and retrieves and returns the song name from it.
  String getSongName(dynamic item) {
    //Ensures the song and its fields are not null or empty
    if (item['title'] != null && item['title'].isNotEmpty) {
      String title = item['title'] ?? "Unknown Title";
      //Clamps the display length of the song title to 15 characters to prevent overflows
      if (title.length > 15) title = "${title.substring(0, 15)}...";

      //Returns the song title
      return title;
    }
    //Returns that it couldnt find a song title
    return 'Unknown Title';
  }

  // Grabs the json item and retrieves and returns the release id from it.
  String getReleaseId(dynamic item) {
    //Ensures the release is not null
    if (item['releases'] == null || item['releases'][0] == null) {
      return "";
    }

    return item['releases'][0]['id'];
  }

  // Deletes a song from the playlist in the database
  Future<void> deleteSong(String uuid) async {
    DBPlaylistResult result = await DBHelper.dbMusicApp.deleteSongFromPlaylist(playlist.playlistId!, uuid);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));

      if (result.isSuccess) {
        setState(() {
          isLoading = true;
        });
        fetchPlaylist();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Music App"),
      ),
      drawer: const CustomDrawer(),
      bottomNavigationBar: CustomBottomNavBar(
        context: context,
        currentIndex: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Playlist title and genre row
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: playlist.imageLink != null &&
                              playlist.imageLink!.isNotEmpty
                              ? Image.network(
                            playlist.imageLink!,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                              : Image.asset(
                            'assets/images/placeholder.jpg',
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          playlist.name,
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        playlist.genre!.name,
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                  // Playlist description and song count row
                  Row(
                    children: [
                      Expanded(
                        child: Text(playlist.description),
                      ),
                      Text("${playlist.songs!.length} songs"),
                    ],
                  ),
                  // Song list or empty state
                  Expanded(
                    child: songResults.isEmpty
                        ? Center(child: Text("No Songs in this playlist."))
                        : ListView.builder(
                            itemCount: songResults.length,
                            itemBuilder: (context, index) {
                              //Checks if the result actually has an artist present
                              bool hasArtist =
                                  songResults[index].containsKey('name');
                              //Uses the custom song card to display all the information
                              return Row(
                                children: [
                                  Expanded(
                                    child: SongCard(
                                      //Creates a cached song with all the retrieved information from the methods
                                      song: CachedSong(
                                          uuid: songResults[index]['id'] ?? "",
                                          albumUUID:
                                              getReleaseId(songResults[index]),
                                          name: getSongName(songResults[index]),
                                          artist: hasArtist
                                              ? songResults[index]['name'] ??
                                                  'Unknown Artist'
                                              : getArtistName(
                                                  songResults[index]),
                                          duration: 100,
                                          currentDuration: 0,
                                      ),
                                      // Binds custom callback function to enable deletion
                                      onDelete: () => deleteSong(songResults[index]['id'] ?? ""),
                                    ),
                                  ),
                                ],
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
