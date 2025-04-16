import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:music_app/core/app_colors.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/widgets/bottom_nav.dart';
import 'package:music_app/widgets/song_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  Future<void> _searchMusic(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    final songResponse = await http.get(Uri.parse(
        'https://musicbrainz.org/ws/2/recording/?query=$query&fmt=json&limit=20'));

    if (songResponse.statusCode == 200) {
      final songData = json.decode(songResponse.body);

      setState(() {
        _searchResults = songData['recordings'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getArtistName(dynamic item) {
    if (item['artist-credit'] != null && item['artist-credit'].isNotEmpty) {
      return item['artist-credit'][0]['name'] ?? 'Unknown Artist';
    }
    if (item['name'] != null) {
      return item['name'] ?? 'Unknown Artist';
    }
    return 'Unknown Artist';
  }

  String _getReleaseId(dynamic item) {
    return item['releases'][0]['id'];
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 250), () {
      _searchMusic(query);
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
              controller: _searchController,
              onChanged: _onSearchChanged,
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
            _isLoading
                ? CircularProgressIndicator(
              valueColor:
              AlwaysStoppedAnimation<Color>(AppColors.primary),
            )
                : _searchResults.isEmpty || _searchController.text.isEmpty
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
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    bool hasArtist =
                    _searchResults[index].containsKey('name');
                    return SongCard(
                      song: CachedSong(
                          uuid: '',
                          albumUUID:
                          _getReleaseId(_searchResults[index]),
                          name: _searchResults[index]['title'] ??
                              'Unknown Title',
                          artist: hasArtist
                              ? _searchResults[index]['name'] ??
                              'Unknown Artist'
                              : _getArtistName(_searchResults[index]),
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
