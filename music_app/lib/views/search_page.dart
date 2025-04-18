import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:music_app/core/app_colors.dart';
import 'package:music_app/models/cached_song.dart';
import 'package:music_app/widgets/bottom_nav.dart';
import 'package:music_app/widgets/song_card.dart';

import '../widgets/drawer_menu.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoading = false;

  //Creates a nullable debounce timer to be used in the search field
  Timer? debounce;

  //Method used to make the request to MusicBrainz to search for music
  Future<void> searchMusic(String query) async {
    if (query.isEmpty) {
      setState(() {
        //Sets search to an empty list if search is empty
        searchResults = [];
      });
      return;
    }

    //Enables the loading circular progress bar
    setState(() {
      isLoading = true;
      searchResults = [];
    });

    //Builds the API request to search for songs on MusicBrainz
    final songResponse = await http.get(Uri.parse(
        'https://musicbrainz.org/ws/2/recording/?query=$query&fmt=json&limit=20'));

    //Ensures the request was completed
    if (songResponse.statusCode == 200) {
      //decodes the json into an object
      final songData = json.decode(songResponse.body);

      setState(() {
        //Sets the search results to the requested data
        searchResults = songData['recordings'];
        //Disables the loading screen
        isLoading = false;
      });
    } else {
      setState(() {
        //Disables the loading screen with no results shown
        isLoading = false;
      });
    }
  }

  //Grabs the json item and retrieves and returns the artist name from it.
  String getArtistName(dynamic item) {
    //Ensures the artist and its fields are not null or empty
    if (item['artist-credit'] != null &&
        item['artist-credit'].isNotEmpty &&
        item['artist-credit'][0] != null &&
        item['artist-credit'][0]['name'] != null) {
      String artist = item['artist-credit'][0]['name'] ?? "Unknown Artist";
      //Clamps the display length of the artist name to 15 characters to prevent overflows
      if (artist.length > 15) artist = "${artist.substring(0, 15)}...";

      //Returns the artist
      return artist;
    }
    //Returns that it couldnt find an artist
    return 'Unknown Artist';
  }

  //Grabs the json item and retrieves and returns the song name from it.
  String getSongName(dynamic item) {
    //Ensures the song and its fields are not null or empty
    if (item['title'] != null && item['title'].isNotEmpty) {
      String title = item['title'] ?? "Unknown Title";
      //Clamps the display length of the song title to 15 characters to prevent overflows
      if (title.length > 15) title = "${title.substring(0, 15)}...";

      //Returns the song title
      return title;
    }
    //Returns that it couldnt find a song title
    return 'Unknown Title';
  }

  String getReleaseId(dynamic item) {
    //Ensures the release is not null
    if (item['releases'] == null || item['releases'][0] == null) {
      return "";
    }

    return item['releases'][0]['id'];
  }

  //Adds logic for a debounce time to ensure the API call is not called on every Search Input field Update
  void onSearchChanged(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();


    //Ensures that the last time the search was changed was 250ms
    debounce = Timer(const Duration(milliseconds: 250), () {
      searchMusic(query);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Music App"),
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            //Search text field that calls the onSearchChanged method when its changed
            //which will then handle the debounce and searching
            TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
              //Instructional label for the user
              decoration: InputDecoration(
                hintText: 'Search for music...',
                hintStyle: TextStyle(color: Colors.black45),
                prefixIcon: Icon(Icons.search, color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            //Displays the results, or a circular progress bar if it is loading
            isLoading
                ? CircularProgressIndicator(
              valueColor:
              AlwaysStoppedAnimation<Color>(AppColors.primary),
            )
                : searchResults.isEmpty || searchController.text.isEmpty
                ? Text(
              'No results found.',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            )
            //Adds a scrollbar to allow the user to scroll through more songs
                : Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                thickness: 8,
                radius: Radius.circular(10),
                scrollbarOrientation: ScrollbarOrientation.right,
                //Creates a list view of all the results
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    //Checks if the result actually has an artist present
                    bool hasArtist =
                    searchResults[index].containsKey('name');
                    //Uses the custom song card to display all the information
                    return SongCard(
                      //Creates a cached song with all the retrieved information from the methods
                      song: CachedSong(
                          uuid: searchResults[index]['id'] ?? "",
                          albumUUID:
                          getReleaseId(searchResults[index]),
                          name: getSongName(searchResults[index]),
                          artist: hasArtist
                              ? searchResults[index]['name'] ??
                              'Unknown Artist'
                              : getArtistName(searchResults[index]),
                          duration: 100,
                          currentDuration: 0),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      //Our custom bottom navigation bar
      bottomNavigationBar: CustomBottomNavBar(
        context: context,
        currentIndex: 1,
      ),
    );
  }
}

