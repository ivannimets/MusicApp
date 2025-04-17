import 'package:flutter/material.dart';
import 'package:music_app/core/app_colors.dart';
import 'package:music_app/database/db_helper.dart';
import 'package:music_app/models/db_result.dart';
import 'package:music_app/models/playlist_model.dart';
import 'package:reactive_forms/reactive_forms.dart';

class AddPlaylistScreen extends StatefulWidget {
  const AddPlaylistScreen({super.key});

  @override
  AddPlaylistScreenState createState() => AddPlaylistScreenState();
}

class AddPlaylistScreenState extends State<AddPlaylistScreen> {
  final FormGroup frmPlaylist = FormGroup({
    'image': FormControl<String>(validators: []),
    'public': FormControl<bool>(value: false, validators: []),
    'name': FormControl<String>(validators: [Validators.required]),
    'description': FormControl<String>(validators: [Validators.required]),
    'genre': FormControl<int>(validators: [Validators.required]),
  });

  List<DropdownMenuItem<int>> genres = [];
  Image playlistImage = Image.asset(
    'assets/images/placeholder.jpg',
    fit: BoxFit.cover,
  );

  @override
  void initState() {
    super.initState();
    _fetchGenres();
  }

  Future<void> _fetchGenres() async {
    DBGenreResult result = await DBHelper.dbMusicApp.getAllGenres();

    setState(() {
      if (result.isSuccess) {
        for (Genre genre in result.genreList) {
          genres.add(DropdownMenuItem<int>(
              key: Key('Genre${genre.genreId}'),
              value: genre.genreId,
              child: Text(genre.name)));
        }
      }
    });
  }

  void fetchImage() {
    setState(() {
      if (frmPlaylist.control("image").value.toString().isNotEmpty) {
        playlistImage = Image.network(
          frmPlaylist.control("image").value,
          fit: BoxFit.cover,
        );
      } else {
        playlistImage = Image.asset(
          'assets/images/placeholder.jpg',
          fit: BoxFit.cover,
        );
      }
    });
  }

  Future<void> addPlaylist() async {
    Playlist playlist;

    frmPlaylist.controls.forEach((key, control) {
      control.markAsTouched();
      control.updateValueAndValidity();
    });

    if (frmPlaylist.valid) {
      playlist = Playlist(
        isPublic: frmPlaylist.control('public').value as bool,
        name: frmPlaylist.control('name').value,
        description: frmPlaylist.control('description').value,
        imageLink: frmPlaylist.control('image').value,
        genreId: frmPlaylist.control('genre').value as int,
      );

      DBPlaylistResult result =
          await DBHelper.dbMusicApp.insertPlaylist(playlist);

      if (mounted) {
        Navigator.popAndPushNamed(context, "/playlistsPage");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Music App"),
      ),
      body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "Create a Playlist",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ReactiveForm(
                  formGroup: frmPlaylist,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 130,
                              width: 130,
                              child: playlistImage,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // const SizedBox(height: 50),
                                ReactiveTextField(
                                  key: const Key('PlaylistImageLink'),
                                  formControlName: 'image',
                                  decoration:
                                  InputDecoration(labelText: 'Playlist Image Link'),
                                  style: TextStyle(color: AppColors.textSecondary),
                                  onChanged: (context) => fetchImage(),
                                ),
                                const SizedBox(height: 20),
                                Text("Public Playlist", style: TextStyle(color: AppColors.textPrimary),),
                                ReactiveSwitch(
                                  key: const Key('PlaylistIsPublic'),
                                  formControlName: 'public',
                                  activeTrackColor: AppColors.primary,
                                  activeColor: AppColors.secondary,
                                  inactiveTrackColor: AppColors.secondary,
                                  inactiveThumbColor: AppColors.backgroundSecondary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ReactiveTextField(
                        key: const Key('PlaylistName'),
                        formControlName: 'name',
                        decoration: InputDecoration(labelText: 'Playlist Name'),
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      ReactiveTextField(
                        key: const Key('PlaylistDescription'),
                        formControlName: 'description',
                        decoration:
                            InputDecoration(labelText: 'Playlist Description'),
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      ReactiveDropdownField(
                        key: const Key('PlaylistGenreId'),
                        formControlName: 'genre',
                        items: genres,
                        style: TextStyle(color: AppColors.textSecondary),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        hint: Text("Select a Genre", style: TextStyle(color: AppColors.textSecondary),),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: addPlaylist,
                          child: Text("Save"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: AppColors.textSecondary,
                            textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        child: Text("Cancel"),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}
