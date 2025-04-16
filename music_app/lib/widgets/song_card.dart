import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:music_app/core/app_colors.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../models/song_model.dart';
import '../providers/loginstate_provider.dart';

class SongCard extends StatefulWidget {
  final CachedSong song;

  const SongCard({super.key, required this.song});

  @override
  SongCardState createState() => SongCardState();
}

class SongCardState extends State<SongCard> {
  String albumCoverURL = "";

  @override
  void initState() {
    super.initState();
    _fetchAlbumCover();
  }

  Future<void> _fetchAlbumCover() async {
    final response = await http.get(Uri.parse(
        'https://coverartarchive.org/release/${widget.song.albumUUID}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (mounted) {
        setState(() {
          albumCoverURL = data['images'][0]['image'];
        });
      }
    }
  }

  void _changeSong(BuildContext context) {
    final loginState = Provider.of<LoginStateProvider>(context, listen: false);

    loginState.user.currentSong = widget.song;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
      Text('Now playing: ${widget.song.name} by ${widget.song.artist}'),
      backgroundColor: AppColors.primary));
    Navigator.popAndPushNamed(context, "/playingPage");
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Row(
          children: [
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
        trailing: Icon(
          Icons.play_arrow,
          color: Colors.green,
          size: 30,
        ),
        onTap: () => _changeSong(context),
      ),
    );
  }
}
