import 'package:flutter/material.dart';
import 'package:music_app/core/app_colors.dart';
import 'package:music_app/database/db_helper.dart';
import 'package:music_app/models/db_result.dart';
import 'package:music_app/models/playlist_arguments_model.dart';
import 'package:music_app/models/playlist_model.dart';
import 'package:reactive_forms/reactive_forms.dart';

class EditPlaylistScreen extends StatefulWidget {
  const EditPlaylistScreen({super.key});

  @override
  EditPlaylistScreenState createState() => EditPlaylistScreenState();
}

class EditPlaylistScreenState extends State<EditPlaylistScreen> {
  final FormGroup frmPlaylist = FormGroup({
    'image': FormControl<String>(validators: []),
    'public': FormControl<bool>(validators: []),
    'name': FormControl<String>(validators: [Validators.required]),
    'description': FormControl<String>(validators: [Validators.required]),
    'genre': FormControl<int>(validators: [Validators.required]),
  });

  bool isPlaylistDetailsLoaded = false;
  List<DropdownMenuItem<int>> genres = [];
  late Image playlistImage = Image.asset(
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

  Future<void> editPlaylist() async {
    final args = ModalRoute.of(context)!.settings.arguments as PlaylistArguments;
    Playlist playlist;

    frmPlaylist.controls.forEach((key, control) {
      control.markAsTouched();
      control.updateValueAndValidity();
    });

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

      if (mounted) {
        Navigator.popAndPushNamed(context, "/playlistsPage");
      }
    }
  }

    @override
  Widget build(BuildContext context) {
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
            Text(
              "Edit Playlist",
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
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      hint: Text("Select a Genre", style: TextStyle(color: AppColors.textSecondary),),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: editPlaylist,
                      child: Text("Save"),
                    ),
                    const SizedBox(height: 10),
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