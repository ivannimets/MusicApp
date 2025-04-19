import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:music_app/core/app_colors.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../models/cached_song.dart';
import '../providers/loginstate_provider.dart';

class SongCard extends StatefulWidget {
  //Stores the displayed cached song
  final CachedSong song;
  final VoidCallback? onDelete;

  const SongCard(
      {super.key,
      required this.song,
      this.onDelete});

  @override
  SongCardState createState() => SongCardState();
}

class SongCardState extends State<SongCard> {
  String albumCoverURL = "";

  @override
  void initState() {
    super.initState();
    //Fetches the album cover to be displayed
    fetchAlbumCover();
  }

  Future<void> fetchAlbumCover() async {
    //Builds the request to MusicBrainz' cover art archive
    final response = await http.get(Uri.parse(
        'https://coverartarchive.org/release/${widget.song.albumUUID}'));

    if (response.statusCode == 200) {
      //Gets the json data from the response
      final data = json.decode(response.body);
      if (mounted) {
        setState(() {
          //Grabs the image from the response
          albumCoverURL = data['images'][0]['image'];
        });
      }
    }
  }

  //Method to change the user's current playing song
  void changeSong(BuildContext context) {
    //Grabs the loginState, without listening
    final loginState = Provider.of<LoginStateProvider>(context, listen: false);

    //Updates the logged in user's current song
    loginState.user.currentSong = widget.song;
    //Shows a snack bar displaying which song is now playing
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Now playing: ${widget.song.name} by ${widget.song.artist}'),
        backgroundColor: AppColors.primary));
    //Navigates the user back to the playing page
    Navigator.popAndPushNamed(context, "/playingPage");
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      //Creates a rounded border around the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Row(
          children: [
            //Adds a circular border around the song's cover art
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: albumCoverURL.isNotEmpty
                  ? Image.network(
                      albumCoverURL,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/placeholder.jpg',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
            ),
            SizedBox(width: 16),
            //Adds a flexible widget to display the song name and artist name
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.song.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.song.artist,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        //Creates the play icon button on the song, including delete button if required
        trailing: widget.onDelete == null
            ? Icon(
                Icons.play_arrow,
                color: Colors.green,
                size: 30,
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.play_arrow,
                    color: Colors.green,
                    size: 30,
                  ),
                  SizedBox(width: 15),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 30,
                    ),
                    // widget onDelete properties triggers associated callback on parent screen
                    onPressed: widget.onDelete,
                  ),
                ],
              ),
        //Handles the user tap to change the song
        onTap: () => changeSong(context),
      ),
    );
  }
}
