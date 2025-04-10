import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:music_app/core/app_colors.dart';
import 'package:music_app/widgets/bottom_nav.dart';
import 'package:provider/provider.dart';
import '../providers/loginstate_provider.dart';

class PlayingPage extends StatefulWidget {
  const PlayingPage({super.key});

  @override
  PlayingPageState createState() => PlayingPageState();
}

class PlayingPageState extends State<PlayingPage> {
  String albumImageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchAlbumImage();
  }

  Future<void> fetchAlbumImage() async {
    setState(() {
      albumImageUrl = 'http://coverartarchive.org/release/76df3287-6cda-33eb-8e9a-044b5e15ffdd/front';
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginStateProvider>(context);
    int selectedIndex = 0;
    bool isPlaying = false;

    double songProgress = 0.3;
    String songLength = '3:45';
    String currentPosition = '1:10';

    void togglePlayPause() {
      setState(() {
        isPlaying = !isPlaying;
      });
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                    value: songProgress,
                    minHeight: 8,
                    color: AppColors.primary,
                    backgroundColor: Colors.grey[700],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentPosition,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        songLength,
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
                  onPressed: () {},
                ),
                SizedBox(width: 30),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    color: Colors.green,
                    size: 90,
                  ),
                  onPressed: togglePlayPause,
                ),
                SizedBox(width: 30),

                IconButton(
                  icon: Icon(
                    Icons.forward_10,
                    color: Colors.white,
                    size: 50,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        context: context,
        currentIndex: selectedIndex,
      ),
    );
  }
}