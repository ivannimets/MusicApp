import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_colors.dart';
import 'package:music_app/widgets/bottom_nav.dart';
import 'package:provider/provider.dart';
import '../providers/loginstate_provider.dart';

class PlayingPage extends StatefulWidget {
  const PlayingPage({super.key});

  @override
  PlayingPageState createState() => PlayingPageState();
}

class PlayingPageState extends State<PlayingPage> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  String albumImageUrl = '';
  bool isPlaying = false;

  int songLength = (60 * 3) + 24;
  int currentTime = 0;

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(seconds: 1), (timer) {
      if (isPlaying) {
        _updateTime(1);
      }
    });

    fetchAlbumImage();
  }

  Future<void> fetchAlbumImage() async {
    setState(() {
      albumImageUrl =
      'http://coverartarchive.org/release/76df3287-6cda-33eb-8e9a-044b5e15ffdd/front';
    });
  }

  void _togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void _updateTime(int deltaTime) {
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

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 80),
              albumImageUrl.isNotEmpty
                  ? Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Image.network(
                  albumImageUrl,
                  height: 350,
                  fit: BoxFit.cover,
                ),
              )
                  : CircularProgressIndicator(),
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
                          'Song Title',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Artist Name',
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
                    onPressed: () => _updateTime(-10),
                  ),
                  SizedBox(width: 30),
                  IconButton(
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: Colors.green,
                      size: 90,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                  SizedBox(width: 30),
                  IconButton(
                    icon: Icon(
                      Icons.forward_10,
                      color: Colors.white,
                      size: 50,
                    ),
                    onPressed: () => _updateTime(10),
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
