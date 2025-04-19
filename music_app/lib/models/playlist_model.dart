class Playlist {
  int? playlistId;
  late bool isPublic;
  late String name;
  late String description;
  String? imageLink;
  List<Song>? songs;
  late int genreId;
  Genre? genre;

  Playlist({this.playlistId, required this.isPublic, required this.name, required this.description, this.imageLink, this.songs, required this.genreId, this.genre});

  // Facilitates conversion between database result and class definition
  Playlist.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      throw Exception("You must provide a map with data");
    }

    playlistId = map['playlistId'];
    isPublic = map['isPublic'] == 1 ? true : false;
    name = map['name'] ?? "";
    description = map['description'] ?? "";
    imageLink = map['imageLink'] ?? "";
    genreId = map['genreId'] ?? -1;
  }

  // Facilitates conversion between class definition and database result
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'isPublic': isPublic,
      'name': name,
      'description': description,
      'imageLink': imageLink ?? "",
      'genreId': genreId
    };
    return map;
  }
}

class Genre {
  late int genreId;
  late String name;

  // Facilitates conversion between database result and class definition
  Genre.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      throw Exception("You must provide a map with data");
    }
    genreId = map['genreId'];
    name = map['name'];
  }

  // Facilitates conversion between class definition and database result
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'genreId': genreId,
      'name': name
    };
    return map;
  }
}

class Song {
  late String songLink;

  Song({required this.songLink});

  // Facilitates conversion between database result and class definition
  Song.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      throw Exception("You must provide a map with data");
    }
    songLink = map['songLink'];
  }

  // Facilitates conversion between class definition and database result
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'songLink': songLink
    };
    return map;
  }
}