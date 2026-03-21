import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_models.dart';
import '../data/database_helper.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}

class GalleryProvider extends ChangeNotifier {
  List<Album> _albums = [];
  List<Photo> _photos = [];
  bool _isLoading = false;

  List<Album> get albums => _albums;
  List<Photo> get photos => _photos;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _albums = await DatabaseHelper.instance.getAllAlbums();
    _photos = await DatabaseHelper.instance.getAllPhotos();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addAlbum(Album album) async {
    await DatabaseHelper.instance.insertAlbum(album);
    await loadData();
  }

  Future<void> updateAlbum(Album album) async {
    await DatabaseHelper.instance.updateAlbum(album);
    await loadData();
  }

  Future<void> deleteAlbum(int id) async {
    await DatabaseHelper.instance.deleteAlbum(id);
    await loadData();
  }

  List<Photo> getPhotosByAlbum(int albumId) {
    return _photos.where((p) => p.albumId == albumId).toList();
  }

  Future<void> addPhoto(Photo photo) async {
    await DatabaseHelper.instance.insertPhoto(photo);
    await loadData();
  }

  Future<void> updatePhoto(Photo photo) async {
    await DatabaseHelper.instance.updatePhoto(photo);
    await loadData();
  }

  Future<void> deletePhoto(int id) async {
    await DatabaseHelper.instance.deletePhoto(id);
    await loadData();
  }
}
