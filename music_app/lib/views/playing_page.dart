import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:music_app/core/app_colors.dart';
import 'package:music_app/models/cached_song.dart';
import 'package:music_app/widgets/bottom_nav.dart';
import 'package:provider/provider.dart';
import '../providers/loginstate_provider.dart';
import '../widgets/drawer_menu.dart';

class PlayingPage extends StatefulWidget {
  const PlayingPage({super.key});

  @override
  PlayingPageState createState() => PlayingPageState();
}

//Creates a state class for the PlayingPage with SingleTickerProviderStateMixin
class PlayingPageState extends State<PlayingPage>
    with SingleTickerProviderStateMixin {
  //Late initializes the Animation Controller
  late AnimationController controller;

  //URL for the album cover image
  String albumCoverURL = '';
  //Boolean whether or not the song is playing
  bool isPlaying = false;

  //Placeholder song length
  int songLength = (60 * 3) + 24;
  //Placeholder song current time
  int currentTime = 0;

  @override
  void initState() {
    super.initState();

    //Runs the timer runnable to update the playtime every second
    Timer.periodic(Duration(seconds: 1), (timer) {
      final loginState =
          Provider.of<LoginStateProvider>(context, listen: false);
      final song = loginState.user.currentSong;

      if (isPlaying) {
        updateTime(1, song);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //Late fetches the album cover
    fetchAlbumCover();
  }

  //Method to fetch the album cover from the MusicBrainz cover art API
  Future<void> fetchAlbumCover() async {
    //Grabs the loginState without listening for updates
    final loginState = Provider.of<LoginStateProvider>(context, listen: false);
    //Gets the current cached song from the user's login state
    final song = loginState.user.currentSong;

    //Stops fetching if the song is null
    if (song == null) {
      return;
    }

    //Builds the API call for the song's cover art
    final response = await http.get(
        Uri.parse('https://coverartarchive.org/release/${song.albumUUID}'));

    //Ensures the call was completed
    if (response.statusCode == 200) {
      //decodes the json response into a dynamic map since we only need 1 small piece from the call
      final data = json.decode(response.body);

      //Ensures the image exists
      if (data['images'] != null && data['images'].isNotEmpty) {
        //Grabs the URL to the image
        final imageUrl = data['images'][0]['image'];

        //Checks if mounted before setting the state
        if (imageUrl != null && mounted) {
          setState(() {
            //Updates the cover art to the fetched image URL
            albumCoverURL = imageUrl;
          });
        }
      }
    }
  }

  //Method to toggle the mock playing of the song
  void togglePlayPause(CachedSong? song) {
    //Returns if the currently cached song is null
    if (song == null) {
      return;
    }

    setState(() {
      //Inverts the boolean of playing
      isPlaying = !isPlaying;
    });
  }

  //Method to update the time, and validate it
  void updateTime(int deltaTime, CachedSong? song) {
    //Returns if the currently cached song is null
    if (song == null) {
      return;
    }

    //Adds the delta time to the current time
    int newTime = currentTime + deltaTime;

    setState(() {
      //Clamps the current time to a min of 0 and a maximum of the song length
      currentTime = min(songLength, max(0, newTime));
    });
  }

  //Converts seconds into a formatted time string "0:00"
  String formatTime(int time) {
    //Grabs the minutes from the time
    int minutes = time ~/ 60;
    //Grabs the remaining seconds from the time
    int seconds = time % 60;

    //Formats the time
    return '$minutes:${seconds < 10 ? "0" : ""}$seconds';
  }

  @override
  Widget build(BuildContext context) {
    //Grabs the global login state
    final loginState = Provider.of<LoginStateProvider>(context);
    int selectedIndex = 0;

    //Grabs the current playing song
    CachedSong? song = loginState.user.currentSong;

    return Scaffold(
      appBar: AppBar(
        title: Text("Music App"),
      ),
      drawer: const CustomDrawer(),
      //Makes the page scrollable for safety
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                //Adds slight rounding to album cover image
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  //Checks where or not to display the placeholder image
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
                    //Button to navigate to the add to playlist screen
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 36,
                      ),
                      onPressed: () {
                        if (song == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You do not have a song selected!")));
                          return;
                        }

                        Navigator.pushNamed(context, "/playingPlaylistPage");
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    //Displays the progress of the current song time
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
                        //Uses the format time method to display the current song time
                        Text(
                          formatTime(currentTime),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                        //Uses the format time method to display the song length
                        Text(
                          formatTime(songLength),
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
              //Row for all the buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Moves song time back 10 seconds
                  IconButton(
                    icon: Icon(
                      Icons.replay_10,
                      color: Colors.white,
                      size: 50,
                    ),
                    onPressed: () => updateTime(-10, song),
                  ),
                  SizedBox(width: 30),
                  //Toggles the song playing or paused
                  IconButton(
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: AppColors.primary,
                      size: 90,
                    ),
                    onPressed: () => togglePlayPause(song),
                  ),
                  SizedBox(width: 30),
                  //Moves the song time foward 10 seconds
                  IconButton(
                    icon: Icon(
                      Icons.forward_10,
                      color: Colors.white,
                      size: 50,
                    ),
                    onPressed: () => updateTime(10, song),
                  ),
                ],
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
      //Inserts the bottom nav bar
      bottomNavigationBar: CustomBottomNavBar(
        context: context,
        currentIndex: selectedIndex,
      ),
    );
  }
}
