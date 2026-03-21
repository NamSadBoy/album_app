import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/data_models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('album_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      var factory = databaseFactoryFfiWeb;
      return await factory.openDatabase(
        filePath,
        options: OpenDatabaseOptions(version: 1, onCreate: _createDB),
      );
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(path, version: 1, onCreate: _createDB);
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE albums(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE photos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        albumId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        dateAdded TEXT NOT NULL,
        imageBytes BLOB NOT NULL,
        FOREIGN KEY (albumId) REFERENCES albums (id) ON DELETE CASCADE
      )
    ''');
  }

  // ALBUM CRUD
  Future<int> insertAlbum(Album album) async {
    final db = await instance.database;
    return await db.insert('albums', album.toMap());
  }

  Future<List<Album>> getAllAlbums() async {
    final db = await instance.database;
    final maps = await db.query('albums', orderBy: 'id DESC');
    return maps.map((map) => Album.fromMap(map)).toList();
  }

  Future<int> updateAlbum(Album album) async {
    final db = await instance.database;
    return await db.update(
      'albums',
      album.toMap(),
      where: 'id = ?',
      whereArgs: [album.id],
    );
  }

  Future<int> deleteAlbum(int id) async {
    final db = await instance.database;
    await db.delete(
      'photos',
      where: 'albumId = ?',
      whereArgs: [id],
    ); // Xóa ảnh con trước
    return await db.delete('albums', where: 'id = ?', whereArgs: [id]);
  }

  // PHOTO CRUD
  Future<int> insertPhoto(Photo photo) async {
    final db = await instance.database;
    return await db.insert('photos', photo.toMap());
  }

  Future<List<Photo>> getAllPhotos() async {
    final db = await instance.database;
    final maps = await db.query('photos', orderBy: 'id DESC');
    return maps.map((map) => Photo.fromMap(map)).toList();
  }

  Future<int> updatePhoto(Photo photo) async {
    final db = await instance.database;
    return await db.update(
      'photos',
      photo.toMap(),
      where: 'id = ?',
      whereArgs: [photo.id],
    );
  }

  Future<int> deletePhoto(int id) async {
    final db = await instance.database;
    return await db.delete('photos', where: 'id = ?', whereArgs: [id]);
  }
}
