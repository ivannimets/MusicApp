import 'package:flutter/material.dart';
import 'package:music_app/core/app_colors.dart';
import 'package:music_app/database/db_helper.dart';
import 'package:music_app/models/db_result.dart';
import 'package:music_app/models/playlist_arguments_model.dart';
import 'package:music_app/models/playlist_model.dart';
import 'package:music_app/widgets/bottom_nav.dart';

import '../widgets/drawer_menu.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  PlaylistsScreenState createState() => PlaylistsScreenState();
}

class PlaylistsScreenState extends State<PlaylistsScreen> {
  // List of playlists fetched from the database
  List<Playlist> _playlists = [];
  // Error or status message
  String _message = "";
  // Controls whether the loading icon is shown
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlaylists(); // Initial fetch of playlists on screen load
  }

  // Fetches all playlists from the local database
  Future<void> fetchPlaylists() async {
    DBPlaylistResult result = await DBHelper.dbMusicApp.getAllPlaylists();

    setState(() {
      if (result.isSuccess) {
        _playlists = result.playlistList;
      } else {
        _playlists = [];
        _message = result.message;
      }

      _isLoading = false;
    });
  }

  // Shows confirmation dialog before deleting a playlist
  Future<void> confirmDeletePlaylist(int id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Deletion", style: TextStyle(color: AppColors.textSecondary)),
        content: Text("Are you sure you want to delete this Playlist?", style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel", style: TextStyle(color: Colors.blueAccent)),
          ),
          // Confirm Delete
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _deletePlaylist(id);
    }
  }

  // Deletes a playlist by ID and refreshes the list
  Future<void> _deletePlaylist(int id) async {
    DBPlaylistResult result = await DBHelper.dbMusicApp.deletePlaylist(id);

    if (mounted) {
      // Show feedback to the user
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));

      // Refresh playlists if delete succeeded
      if (result.isSuccess) {
        fetchPlaylists();
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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title + Add Playlist Button
            Row(
              children: [
                Expanded(
                  child: Text(
                    "My Playlists",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_box_outlined,
                    color: AppColors.primary,
                  ),
                  iconSize: 40,
                  onPressed: () => Navigator.pushNamed(context, "/addPlaylist"),
                ),
              ],
            ),
            const SizedBox(height: 5),
            // Subheading: playlist count
            Text(
              "${_playlists.length} playlist${_playlists.length != 1 ? "s" : ""}",
              style: TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 5),
            // Main content area: loading, empty message, or list of playlists
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

                            // Display each playlist in a card
                            return Card(
                              child: ListTile(
                                // Tapping opens the playlist detail page
                                onTap: () => Navigator.pushNamed(
                                    context,
                                    "/playlistPage",
                                  arguments: PlaylistArguments(playlistId: playlist.playlistId!),
                                ),
                                // Playlist image (or placeholder)
                                leading: ClipRRect(
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
                                // Playlist name and genre
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
                                // Description and song count
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(playlist.description),
                                    Text("${playlist.songs!.length} song${playlist.songs!.length != 1 ? "s" : ""}"),
                                  ],
                                ),
                                // Edit & Delete buttons
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      color: Colors.blue,
                                      iconSize: 30,
                                      onPressed: () => Navigator.pushNamed(
                                        context,
                                        "/editPlaylist",
                                        arguments: PlaylistArguments(
                                            playlistId: playlist.playlistId!),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      color: Colors.red,
                                      iconSize: 30,
                                      onPressed: () => confirmDeletePlaylist(
                                          playlist.playlistId!),
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
