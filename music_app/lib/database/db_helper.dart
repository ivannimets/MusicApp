import 'package:music_app/models/db_result.dart';
import 'package:music_app/models/playlist_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper dbMusicApp = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get musicAppDatabase async { // Enforce singleton instance
    if (_database != null) return _database!;

    _database = await _getDB();

    return _database!;
  }

  Future<Database> _getDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'music_app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  void _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE genres (
        genreId INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )
    ''');

    await db.execute('INSERT INTO genres(name) VALUES ("Country")');
    await db.execute('INSERT INTO genres(name) VALUES ("Pop")');
    await db.execute('INSERT INTO genres(name) VALUES ("Rock")');
    await db.execute('INSERT INTO genres(name) VALUES ("Hip-Hop")');
    await db.execute('INSERT INTO genres(name) VALUES ("Jazz")');
    await db.execute('INSERT INTO genres(name) VALUES ("Classical")');
    await db.execute('INSERT INTO genres(name) VALUES ("Latin")');
    await db.execute('INSERT INTO genres(name) VALUES ("EDM")');
    await db.execute('INSERT INTO genres(name) VALUES ("R&B")');
    await db.execute('INSERT INTO genres(name) VALUES ("Reggae")');

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

    await db.execute('''
      INSERT INTO playlists(isPublic, name, description, imageLink, genreId) VALUES (
        0,
        'My First Playlist',
        'Just for me',
        '#',
        2
      )
    ''');
  }

  Future<DBPlaylistResult> getAllPlaylists() async {
    List<Playlist> playlists = [];
    final db = await dbMusicApp.musicAppDatabase;

    try {
      List<Map<String, dynamic>> result = await db.query('playlists');

      if (result.isNotEmpty) {
        for (Map<String, dynamic> row in result) {
          Playlist playlist = Playlist.fromMap(row);
          DBGenreResult genreResult = await getGenre(playlist.genreId);
          if (genreResult.isSuccess) playlist.genre = genreResult.genreList[0];
          playlists.add(playlist);
        }

        return DBPlaylistResult(isSuccess: true, message: "Playlists Retrieved", playlistList: playlists);
      } else {
        return DBPlaylistResult(isSuccess: false, message: "No Playlists Found", playlistList: playlists);
      }
    } catch (e) {
      return DBPlaylistResult(isSuccess: false, message: "Error: $e", playlistList: []);
    }
  }

  Future<DBPlaylistResult> getPlaylist(int id) async {
    List<Playlist> playlists = [];
    final db = await dbMusicApp.musicAppDatabase;

    try {
      List<Map<String, dynamic>> result = await db.query(
        'playlists',
        where: 'playlistId = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        Playlist playlist = Playlist.fromMap(result[0]);
        DBGenreResult genreResult = await getGenre(playlist.genreId);
        if (genreResult.isSuccess) playlist.genre = genreResult.genreList[0];
        playlists.add(playlist);
        return DBPlaylistResult(isSuccess: true, message: "Playlist Retrieved", playlistList: playlists);
      } else {
        return DBPlaylistResult(isSuccess: false, message: "No Matching Playlist Found", playlistList: playlists);
      }
    } catch (e) {
      return DBPlaylistResult(isSuccess: false, message: "Error: $e", playlistList: []);
    }
  }

  Future<DBPlaylistResult> insertPlaylist(Playlist playlistDetails) async {
    final db = await dbMusicApp.musicAppDatabase;

    try {
      int playlistId = await db.insert(
          'playlists',
          playlistDetails.toMap()
      );

      if (playlistId > 0) {
        return DBPlaylistResult(isSuccess: true, message: "Playlist Inserted Successfully with ID: $playlistId", playlistList: []);
      } else {
        return DBPlaylistResult(isSuccess: false, message: "Failed to Insert Playlist", playlistList: []);
      }
    } catch (e) {
      return DBPlaylistResult(isSuccess: false, message: "Error: $e", playlistList: []);
    }
  }

  Future<DBPlaylistResult> updatePlaylist(Playlist playlistDetails) async {
    final db = await dbMusicApp.musicAppDatabase;

    try {
      int id = playlistDetails.playlistId!;

      int rowsAffected = await db.update(
        'playlists',
        playlistDetails.toMap(),
        where: 'playlistId = ?',
        whereArgs: [id],
      );

      if (rowsAffected > 0) {
        return DBPlaylistResult(isSuccess: true, message: "Playlist Updated Successfully", playlistList: []);
      } else {
        return DBPlaylistResult(isSuccess: false, message: "No Matching Playlist Found", playlistList: []);
      }
    } catch (e) {
      return DBPlaylistResult(isSuccess: false, message: "Error: $e", playlistList: []);
    }
  }

  Future<DBPlaylistResult> deletePlaylist(int id) async {
    final db = await dbMusicApp.musicAppDatabase;

    try {
      int rowsDeleted = await db.delete(
        'playlists',
        where: 'playlistId = ?',
        whereArgs: [id],
      );

      if (rowsDeleted > 0) {
        return DBPlaylistResult(isSuccess: true, message: "Playlist Deleted Successfully", playlistList: []);
      } else {
        return DBPlaylistResult(isSuccess: false, message: "No Matching Playlist Found", playlistList: []);
      }
    } catch (e) {
      return DBPlaylistResult(isSuccess: false, message: "Error: $e", playlistList: []);
    }
  }

  Future<DBGenreResult> getAllGenres() async {
    List<Genre> genres = [];
    final db = await dbMusicApp.musicAppDatabase;

    try {
      List<Map<String, dynamic>> result = await db.query('genres');

      if (result.isNotEmpty) {
        for (Map<String, dynamic> genre in result) {
          genres.add(Genre.fromMap(genre));
        }

        return DBGenreResult(isSuccess: true, message: "Genres Retrieved", genreList: genres);
      } else {
        return DBGenreResult(isSuccess: false, message: "No Genres Found", genreList: genres);
      }
    } catch (e) {
      return DBGenreResult(isSuccess: false, message: "Error: $e", genreList: []);
    }
  }

  Future<DBGenreResult> getGenre(int id) async {
    List<Genre> genres = [];
    final db = await dbMusicApp.musicAppDatabase;

    try {
      List<Map<String, dynamic>> result = await db.query(
          'genres', where: 'genreId = ?', whereArgs: [id]);

      if (result.isNotEmpty) {
        genres.add(Genre.fromMap(result[0]));

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
}
