import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:music_app/core/app_colors.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/widgets/bottom_nav.dart';
import 'package:provider/provider.dart';
import '../providers/loginstate_provider.dart';

class PlayingPage extends StatefulWidget {
  const PlayingPage({super.key});

  @override
  PlayingPageState createState() => PlayingPageState();
}

class PlayingPageState extends State<PlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  String albumCoverURL = '';
  bool isPlaying = false;

  int songLength = (60 * 3) + 24;
  int currentTime = 0;

  @override
  void initState() {
    super.initState();


    Timer.periodic(Duration(seconds: 1), (timer) {
      final loginState = Provider.of<LoginStateProvider>(context, listen: false);
      final song = loginState.user.currentSong;

      if (isPlaying) {
        _updateTime(1, song);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchAlbumCover();
  }

  Future<void> _fetchAlbumCover() async {
    final loginState = Provider.of<LoginStateProvider>(context, listen: false);
    final song = loginState.user.currentSong;

    if (song == null) {
      return;
    }

    final response = await http.get(
        Uri.parse('https://coverartarchive.org/release/${song.albumUUID}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['images'] != null && data['images'].isNotEmpty) {
        final imageUrl = data['images'][0]['image'];

        if (imageUrl != null && mounted) {
          setState(() {
            albumCoverURL = imageUrl;
          });
        }
      }
    }
  }

  void _togglePlayPause(SongModel? song) {
    if (song == null) {
      return;
    }

    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void _updateTime(int deltaTime, SongModel? song) {
    if (song == null) {
      return;
    }

    int newTime = currentTime + deltaTime;

    setState(() {
      currentTime = min(songLength, max(0, newTime));
    });
  }

  String _formatTime(int time) {
    int minutes = time ~/ 60;
    int seconds = time % 60;

    return '$minutes:${seconds < 10 ? "0" : ""}$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginStateProvider>(context);
    int selectedIndex = 0;

    SongModel? song = loginState.user.currentSong;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 80),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: (albumCoverURL.isNotEmpty)
                      ? Image.network(
                          albumCoverURL,
                          height: 350,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/images/placeholder.jpg',
                          height: 350,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song?.name ?? "Nothing playing",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          song?.artist ?? "",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 36,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: (currentTime / songLength),
                      minHeight: 8,
                      color: AppColors.primary,
                      backgroundColor: Colors.grey[700],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(currentTime),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          _formatTime(songLength),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.replay_10,
                      color: Colors.white,
                      size: 50,
                    ),
                    onPressed: () => _updateTime(-10, song),
                  ),
                  SizedBox(width: 30),
                  IconButton(
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: AppColors.primary,
                      size: 90,
                    ),
                    onPressed: () => _togglePlayPause(song),
                  ),
                  SizedBox(width: 30),
                  IconButton(
                    icon: Icon(
                      Icons.forward_10,
                      color: Colors.white,
                      size: 50,
                    ),
                    onPressed: () => _updateTime(10, song),
                  ),
                ],
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        context: context,
        currentIndex: selectedIndex,
      ),
    );
  }
}
