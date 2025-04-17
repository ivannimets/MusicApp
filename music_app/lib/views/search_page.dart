import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:music_app/core/app_colors.dart';
import 'package:music_app/models/cached_song.dart';
import 'package:music_app/widgets/bottom_nav.dart';
import 'package:music_app/widgets/song_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoading = false;
  Timer? debounce;

  Future<void> searchMusic(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
      searchResults = [];
    });

    final songResponse = await http.get(Uri.parse(
        'https://musicbrainz.org/ws/2/recording/?query=$query&fmt=json&limit=20'));

    if (songResponse.statusCode == 200) {
      final songData = json.decode(songResponse.body);

      setState(() {
        searchResults = songData['recordings'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  String getArtistName(dynamic item) {
    if (item['artist-credit'] != null && item['artist-credit'].isNotEmpty) {
      String artist = item['artist-credit'][0]['name'] ?? "Unknown Artist";
      if (artist.length > 15) artist = "${artist.substring(0, 15)}...";

      return artist;
    }
    if (item['name'] != null) {
      return item['name'] ?? 'Unknown Artist';
    }
    return 'Unknown Artist';
  }

  String getSongName(dynamic item) {
    if (item['title'] != null && item['title'].isNotEmpty) {
      String title = item['title'] ?? "Unknown Title";
      if (title.length > 15) title = "${title.substring(0, 15)}...";

      return title;
    }
    return 'Unknown Title';
  }

  String _getReleaseId(dynamic item) {
    return item['releases'][0]['id'];
  }

  void onSearchChanged(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();

    debounce = Timer(const Duration(milliseconds: 250), () {
      searchMusic(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 80),
            TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
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
                : Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                thickness: 8,
                radius: Radius.circular(10),
                scrollbarOrientation: ScrollbarOrientation.right,
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    bool hasArtist =
                    searchResults[index].containsKey('name');
                    return SongCard(
                      song: CachedSong(
                          uuid: searchResults[index]['id'] ?? "",
                          albumUUID:
                          _getReleaseId(searchResults[index]),
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
      bottomNavigationBar: CustomBottomNavBar(
        context: context,
        currentIndex: 1,
      ),
    );
  }
}
