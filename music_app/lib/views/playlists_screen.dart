import 'package:flutter/material.dart';
import 'package:music_app/database/db_helper.dart';
import 'package:music_app/models/db_result.dart';
import 'package:music_app/models/playlist_model.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  PlaylistsScreenState createState() => PlaylistsScreenState();
}

class PlaylistsScreenState extends State<PlaylistsScreen> {
  List<Playlist> _playlists = [];
  String _message = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlaylists();
  }

  Future<void> fetchPlaylists() async {
    DBPlaylistResult result = await DBHelper.dbMusicApp.getAllPlaylists(); // Get list of vacations from sqlite database

    setState(() {
      if (result.isSuccess) {
        _playlists = result.playlistList;
      } else {
        _message = result.message;
      }

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
                              title: Text(playlist.name),
                              subtitle: Text("${playlist.description} Genre: ${playlist.genre!.name}"),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
