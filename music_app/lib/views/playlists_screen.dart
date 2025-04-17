import 'package:flutter/material.dart';
import 'package:music_app/core/app_colors.dart';
import 'package:music_app/database/db_helper.dart';
import 'package:music_app/models/db_result.dart';
import 'package:music_app/models/playlist_arguments_model.dart';
import 'package:music_app/models/playlist_model.dart';
import 'package:music_app/widgets/bottom_nav.dart';

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

  Future<void> confirmDeletePlaylist(int id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Deletion", style: TextStyle(color: AppColors.textSecondary)),
        content: Text("Are you sure you want to delete this Playlist?", style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel", style: TextStyle(color: Colors.blueAccent)),
          ),
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

  Future<void> _deletePlaylist(int id) async {
    DBPlaylistResult result = await DBHelper.dbMusicApp.deletePlaylist(id);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));

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
                                onTap: () => Navigator.pushNamed(context, "/playlistSongs"),
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
                                      icon: Icon(Icons.edit),
                                      iconSize: 30,
                                      onPressed: () => Navigator.pushNamed(
                                        context,
                                        "/editPlaylist",
                                        arguments: PlaylistArguments(
                                            playlistId: playlist.playlistId!),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline),
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
