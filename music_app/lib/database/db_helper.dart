import 'package:music_app/models/db_result.dart';
import 'package:music_app/models/playlist_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper dbMusicApp = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  // Enforces Singleton design pattern
  Future<Database> get musicAppDatabase async {
    // Enforce singleton instance
    if (_database != null) return _database!;

    _database = await _getDB();

    return _database!;
  }

  // Retrieves database
  Future<Database> _getDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'music_app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  // Sets up tables with data on database creation
  void _createDatabase(Database db, int version) async {
    // Creates Schema for genres table
    await db.execute('''
      CREATE TABLE genres (
        genreId INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )
    ''');

    // Populate genres table with data
    await db.execute('''INSERT INTO genres(name) VALUES ('Country')''');
    await db.execute('''INSERT INTO genres(name) VALUES ('Pop')''');
    await db.execute('''INSERT INTO genres(name) VALUES ('Rock')''');
    await db.execute('''INSERT INTO genres(name) VALUES ('Hip-Hop')''');
    await db.execute('''INSERT INTO genres(name) VALUES ('Jazz')''');
    await db.execute('''INSERT INTO genres(name) VALUES ('Classical')''');
    await db.execute('''INSERT INTO genres(name) VALUES ('Latin')''');
    await db.execute('''INSERT INTO genres(name) VALUES ('EDM')''');
    await db.execute('''INSERT INTO genres(name) VALUES ('R&B')''');
    await db.execute('''INSERT INTO genres(name) VALUES ('Reggae')''');

    // create playlists table
    await db.execute('''
      CREATE TABLE playlists (
        playlistId INTEGER PRIMARY KEY AUTOINCREMENT,
        isPublic BOOLEAN,
        name TEXT,
        description TEXT,
        imageLink TEXT,
        genreId INTEGER,
        FOREIGN KEY(genreId) REFERENCES genres(genreId)
      )
    ''');

    // creates playlist_songs table
    await db.execute('''
      CREATE TABLE playlist_songs (
        playlistId INTEGER,
        songLink TEXT,
        FOREIGN KEY(playlistId) REFERENCES playlists(playlistId)
      )
    ''');

    // Populate playlists table with a default playlist
    await db.execute('''
      INSERT INTO playlists(isPublic, name, description, imageLink, genreId) VALUES (
        0,
        'My First Playlist',
        'Just for me',
        '',
        2
      )
    ''');

    // Add a song to the default playlist
    await db.execute('''INSERT INTO playlist_songs(playlistId, songLink) VALUES (1, '1e4f5547-5175-4d18-bd5a-83fda618c964')''');
  }

  // Retrieves all Playlists in the database
  Future<DBPlaylistResult> getAllPlaylists() async {
    final db = await dbMusicApp.musicAppDatabase;
    List<Playlist> playlists = [];

    try {
      // Query database for all playlists
      List<Map<String, dynamic>> result = await db.query('playlists');

      if (result.isNotEmpty) {
        for (Map<String, dynamic> row in result) {
          // Initialize playlist details then add them to the list
          Playlist playlist = Playlist.fromMap(row);

          DBGenreResult genreResult = await getGenre(playlist.genreId);
          if (genreResult.isSuccess) playlist.genre = genreResult.genreList[0];

          DBSongListResult songsResult = await getSongsOfPlaylist(playlist.playlistId!);
          playlist.songs = songsResult.isSuccess ? songsResult.songList : [];

          playlists.add(playlist);
        }

        // Return appropriate Result
        return DBPlaylistResult(
            isSuccess: true,
            message: "Playlists Retrieved",
            playlistList: playlists,
        );
      } else {
        return DBPlaylistResult(
            isSuccess: false,
            message: "No Playlists Found",
            playlistList: playlists);
      }
    } catch (e) {
      return DBPlaylistResult(
          isSuccess: false, message: "Error: $e", playlistList: []);
    }
  }

  // Retrieves one playlist by id
  Future<DBPlaylistResult> getPlaylist(int id) async {
    final db = await dbMusicApp.musicAppDatabase;

    try {
      // Query database for playlists with matching id
      List<Map<String, dynamic>> result = await db.query(
        'playlists',
        where: 'playlistId = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        // Add details to playlist and send it as a list
        Playlist playlist = Playlist.fromMap(result[0]);

        DBGenreResult genreResult = await getGenre(playlist.genreId);
        if (genreResult.isSuccess) playlist.genre = genreResult.genreList[0];

        DBSongListResult songResult = await getSongsOfPlaylist(id);
        playlist.songs = songResult.isSuccess ? songResult.songList : [];

        // Return appropriate result
        return DBPlaylistResult(
            isSuccess: true,
            message: "Playlist Retrieved",
            playlistList: [playlist],
        );
      } else {
        return DBPlaylistResult(
            isSuccess: false,
            message: "No Matching Playlist Found",
            playlistList: [],
        );
      }
    } catch (e) {
      return DBPlaylistResult(
          isSuccess: false, message: "Error: $e", playlistList: []);
    }
  }

  // Adds a new playlist to the database
  Future<DBPlaylistResult> insertPlaylist(Playlist playlistDetails) async {
    final db = await dbMusicApp.musicAppDatabase;

    try {
      // Insert playlist record into database
      int playlistId = await db.insert('playlists', playlistDetails.toMap());

      // Return result to indicate success of insertion
      if (playlistId > 0) {
        return DBPlaylistResult(
            isSuccess: true,
            message: "Playlist Inserted Successfully with ID: $playlistId",
            playlistList: []);
      } else {
        return DBPlaylistResult(
            isSuccess: false,
            message: "Failed to Insert Playlist",
            playlistList: []);
      }
    } catch (e) {
      return DBPlaylistResult(
          isSuccess: false, message: "Error: $e", playlistList: []);
    }
  }

  // updates an existing playlist record
  Future<DBPlaylistResult> updatePlaylist(Playlist playlistDetails) async {
    final db = await dbMusicApp.musicAppDatabase;

    try {
      int id = playlistDetails.playlistId!;

      // apply update to database
      int rowsAffected = await db.update(
        'playlists',
        playlistDetails.toMap(),
        where: 'playlistId = ?',
        whereArgs: [id],
      );

      // Return result to indicate success of insertion
      if (rowsAffected > 0) {
        return DBPlaylistResult(
            isSuccess: true,
            message: "Playlist Updated Successfully",
            playlistList: []);
      } else {
        return DBPlaylistResult(
            isSuccess: false,
            message: "No Matching Playlist Found",
            playlistList: []);
      }
    } catch (e) {
      return DBPlaylistResult(
          isSuccess: false, message: "Error: $e", playlistList: []);
    }
  }

  // deletes an existing playlist record
  Future<DBPlaylistResult> deletePlaylist(int id) async {
    final db = await dbMusicApp.musicAppDatabase;

    try {
      // Remove playlist records with matching id
      int rowsDeleted = await db.delete(
        'playlists',
        where: 'playlistId = ?',
        whereArgs: [id],
      );

      // Return result to indicate success of deletion
      if (rowsDeleted > 0) {
        return DBPlaylistResult(
            isSuccess: true,
            message: "Playlist Deleted Successfully",
            playlistList: []);
      } else {
        return DBPlaylistResult(
            isSuccess: false,
            message: "No Matching Playlist Found",
            playlistList: []);
      }
    } catch (e) {
      return DBPlaylistResult(
          isSuccess: false, message: "Error: $e", playlistList: []);
    }
  }

  // Retrieves list of genres
  Future<DBGenreResult> getAllGenres() async {
    final db = await dbMusicApp.musicAppDatabase;
    List<Genre> genres = [];

    try {
      // Query database for all genres, ordered
      List<Map<String, dynamic>> result = await db.query('genres', orderBy: 'name');

      if (result.isNotEmpty) {
        // loop over result set to populate genre list
        for (Map<String, dynamic> genre in result) {
          genres.add(Genre.fromMap(genre));
        }

        // Return appropriate result
        return DBGenreResult(
            isSuccess: true, message: "Genres Retrieved", genreList: genres);
      } else {
        return DBGenreResult(
            isSuccess: false, message: "No Genres Found", genreList: genres);
      }
    } catch (e) {
      return DBGenreResult(
          isSuccess: false, message: "Error: $e", genreList: []);
    }
  }

  // Retrieves a specific genre by id
  Future<DBGenreResult> getGenre(int id) async {
    final db = await dbMusicApp.musicAppDatabase;

    try {
      // Query database for genres with matching id
      List<Map<String, dynamic>> result =
          await db.query('genres', where: 'genreId = ?', whereArgs: [id]);

      // Return appropriate result
      if (result.isNotEmpty) {
        return DBGenreResult(
            isSuccess: true, message: "Genres Retrieved", genreList: [Genre.fromMap(result[0])]);
      } else {
        return DBGenreResult(
            isSuccess: false, message: "No Genres Found", genreList: []);
      }
    } catch (e) {
      return DBGenreResult(
          isSuccess: false, message: "Error: $e", genreList: []);
    }
  }

  // Retrieves a list of song uuids associated with a playlist
  Future<DBSongListResult> getSongsOfPlaylist(int id) async {
    final db = await dbMusicApp.musicAppDatabase;
    List<Song> songs = [];

    try {
      // Query database for records with matching playlistId and uuid
      List<Map<String, dynamic>> results = await db.query(
        'playlist_songs',
        columns: ['songLink'],
        where: 'playlistId = ?',
        whereArgs: [id],
      );

      // Loops over results populate song list
      for (Map<String, dynamic> row in results) {
        songs.add(Song.fromMap(row));
      }

      // Return appropriate result
      if (songs.isNotEmpty) {
        return DBSongListResult(isSuccess: true, message: "Songs retrieved", songList: songs);
      } else {
        return DBSongListResult(isSuccess: false, message: "No songs are associated with that playlist_arguments_model.dart", songList: []);
      }
    } catch (e) {
      return DBSongListResult(isSuccess: false, message: "Error: $e", songList: []);
    }
  }

  // Adds song to playlist
  Future<DBPlaylistResult> addSongToPlaylist(Song song, int id) async {
    final db = await dbMusicApp.musicAppDatabase;

    try {
      // Insert record to playlist_songs table
      await db.insert(
        'playlist_songs',
        {'playlistId': id, 'songLink': song.songLink} as Map<String, dynamic>,
      );

      // Double check insertion was successful
      List<Map<String, dynamic>> songResult = await db.query(
        'playlist_songs',
        columns: ['playlistId'],
        where: 'playlistId = ? AND songLink = ?',
        whereArgs: [id, song.songLink],
      );
      int playlistId = songResult[0]['playlistId'];

      // Return appropriate result
      if (playlistId > 0) {
        return DBPlaylistResult(
            isSuccess: true,
            message: "Successfully added Song to Playlist with ID: $playlistId",
            playlistList: []);
      } else {
        return DBPlaylistResult(
            isSuccess: false,
            message: "Failed to Add Song to Playlist",
            playlistList: []);
      }
    } catch (e) {
      return DBPlaylistResult(
          isSuccess: false, message: "Error: $e", playlistList: []);
    }
  }

  // Removes song from playlist
  Future<DBPlaylistResult> deleteSongFromPlaylist(int playlistId, String uuid) async {
    final db = await dbMusicApp.musicAppDatabase;

    try {
      // Remove record from playlist_songs table
      int rowsDeleted = await db.delete(
        'playlist_songs',
        where: 'playlistId = ? AND songLink = ?',
        whereArgs: [playlistId, uuid],
      );

      // Return appropriate result
      if (rowsDeleted > 0) {
        return DBPlaylistResult(
            isSuccess: true,
            message: "Song Deleted From Playlist Successfully",
            playlistList: []);
      } else {
        return DBPlaylistResult(
            isSuccess: false,
            message: "Failed to Delete Song From Playlist",
            playlistList: []);
      }
    } catch (e) {
      return DBPlaylistResult(
          isSuccess: false, message: "Error: $e", playlistList: []);
    }
  }
}
