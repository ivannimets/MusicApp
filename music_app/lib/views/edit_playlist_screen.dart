import 'package:flutter/material.dart';
import 'package:music_app/core/app_colors.dart';
import 'package:music_app/database/db_helper.dart';
import 'package:music_app/models/db_result.dart';
import 'package:music_app/models/playlist_arguments_model.dart';
import 'package:music_app/models/playlist_model.dart';
import 'package:reactive_forms/reactive_forms.dart';

// Screen for editing an existing playlist.
class EditPlaylistScreen extends StatefulWidget {
  const EditPlaylistScreen({super.key});

  @override
  EditPlaylistScreenState createState() => EditPlaylistScreenState();
}

class EditPlaylistScreenState extends State<EditPlaylistScreen> {
  // Reactive form for managing playlist field inputs
  final FormGroup frmPlaylist = FormGroup({
    'image': FormControl<String>(validators: []),
    'public': FormControl<bool>(validators: []),
    'name': FormControl<String>(validators: [Validators.required]),
    'description': FormControl<String>(validators: [Validators.required]),
    'genre': FormControl<int>(validators: [Validators.required]),
  });

  // Flags whether playlist details have been loaded from the DB
  bool isPlaylistDetailsLoaded = false;

  // List of genre dropdown menu items
  List<DropdownMenuItem<int>> genres = [];

  // Image preview for the playlist
  late Image playlistImage = Image.asset(
    'assets/images/placeholder.jpg',
    fit: BoxFit.cover,
  );

  @override
  void initState() {
    super.initState();
    _fetchGenres();
  }

  // Loads available genres from local DB and builds dropdown items
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

  // Loads the playlist details (ID comes from navigation arguments)
  Future<void> _loadPlaylistDetails() async {
    final args = ModalRoute.of(context)!.settings.arguments as PlaylistArguments;
    DBPlaylistResult result = await DBHelper.dbMusicApp.getPlaylist(args.playlistId);

    if (result.playlistList.isNotEmpty && !isPlaylistDetailsLoaded) {
      Playlist playlist = result.playlistList[0];

      if (playlist.imageLink != null && playlist.imageLink!.isNotEmpty) {
        playlistImage = Image.network(
          playlist.imageLink!,
          fit: BoxFit.cover,
        );
      } else {
        playlistImage = Image.asset(
          'assets/images/placeholder.jpg',
          fit: BoxFit.cover,
        );
      }

      // Populate the form fields with existing playlist values
      frmPlaylist.control('image').value = playlist.imageLink;
      frmPlaylist.control('public').value = playlist.isPublic;
      frmPlaylist.control('name').value = playlist.name;
      frmPlaylist.control('description').value = playlist.description;
      frmPlaylist.control('genre').value = playlist.genreId;

      setState(() {
        isPlaylistDetailsLoaded = true;
      });
    }
  }

  // Updates the playlist image preview whenever the image URL input changes
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

  // Validates form and updates the playlist in the database
  Future<void> editPlaylist() async {
    final args = ModalRoute.of(context)!.settings.arguments as PlaylistArguments;
    Playlist playlist;

    // Mark all controls as touched to show validation errors
    frmPlaylist.controls.forEach((key, control) {
      control.markAsTouched();
      control.updateValueAndValidity();
    });

    // If the form is valid, update the playlist
    if (frmPlaylist.valid) {
      playlist = Playlist(
        playlistId: args.playlistId,
        isPublic: frmPlaylist.control('public').value as bool,
        name: frmPlaylist.control('name').value,
        description: frmPlaylist.control('description').value,
        imageLink: frmPlaylist.control('image').value,
        genreId: frmPlaylist.control('genre').value as int,
      );

      DBPlaylistResult result =
      await DBHelper.dbMusicApp.updatePlaylist(playlist);

      // Go back to playlist list after successful update
      if (mounted && result.isSuccess) {
        Navigator.popAndPushNamed(context, "/playlistsPage");
      }
    }
  }

    @override
  Widget build(BuildContext context) {
    // Ensures playlist data is loaded *after* build to avoid accessing context too early
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isPlaylistDetailsLoaded) {
        _loadPlaylistDetails();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Music App"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Title
            Text(
              "Edit Playlist",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            // Playlist form
            Expanded(
              child: ReactiveForm(
                formGroup: frmPlaylist,
                child: Column(
                  children: [
                    // Image preview and image URL input
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Playlist cover image preview
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            height: 130,
                            width: 130,
                            child: playlistImage,
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Image link and public/private switch
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Input field for image URL
                              ReactiveTextField(
                                key: const Key('PlaylistImageLink'),
                                formControlName: 'image',
                                decoration:
                                InputDecoration(labelText: 'Playlist Image Link'),
                                style: TextStyle(color: AppColors.textSecondary),
                                onChanged: (context) => fetchImage(),
                              ),
                              const SizedBox(height: 20),
                              // Public/private switch
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
                    // Playlist name input
                    ReactiveTextField(
                      key: const Key('PlaylistName'),
                      formControlName: 'name',
                      decoration: InputDecoration(labelText: 'Playlist Name'),
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    // Playlist description input
                    ReactiveTextField(
                      key: const Key('PlaylistDescription'),
                      formControlName: 'description',
                      decoration:
                      InputDecoration(labelText: 'Playlist Description'),
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    // Genre dropdown menu
                    ReactiveDropdownField(
                      key: const Key('PlaylistGenreId'),
                      formControlName: 'genre',
                      items: genres,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      hint: Text("Select a Genre", style: TextStyle(color: AppColors.textSecondary),),
                    ),
                    const SizedBox(height: 20),
                    // Save button
                    ElevatedButton(
                      onPressed: editPlaylist,
                      child: Text("Save"),
                    ),
                    const SizedBox(height: 10),
                    // Cancel button
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.background,
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