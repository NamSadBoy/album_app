import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_models.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class GalleryProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<Album> _albums = [];
  List<Photo> _photos = [];
  bool isLoading = false;

  String albumSearchQuery = '';
  String albumSortOrder = 'newest';
  String photoSearchQuery = '';
  String photoSortOrder = 'newest';

  // --- TÍNH NĂNG ẨN ALBUM ---
  bool isShowingHidden = false;
  String? _pinCode;

  GalleryProvider() {
    _loadPin();
  }

  Future<void> _loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    _pinCode = prefs.getString('album_pin');
    notifyListeners();
  }

  bool get hasPin => _pinCode != null && _pinCode!.isNotEmpty;

  Future<void> setPin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('album_pin', newPin);
    _pinCode = newPin;
    notifyListeners();
  }

  bool checkPin(String inputPin) => _pinCode == inputPin;

  void toggleShowHidden() {
    isShowingHidden = !isShowingHidden;
    notifyListeners();
  }

  // --- LOGIC LỌC & SẮP XẾP ALBUM ---
  List<Album> get filteredAlbums {
    List<Album> temp = _albums.where((a) {
      bool matchSearch = a.name.toLowerCase().contains(
        albumSearchQuery.toLowerCase(),
      );
      bool matchHidden = isShowingHidden ? true : !a.isHidden;
      return matchSearch && matchHidden;
    }).toList();

    temp.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;

      if (albumSortOrder == 'newest')
        return b.dateCreated.compareTo(a.dateCreated);
      if (albumSortOrder == 'oldest')
        return a.dateCreated.compareTo(b.dateCreated);
      if (albumSortOrder == 'az') return a.name.compareTo(b.name);
      if (albumSortOrder == 'za') return b.name.compareTo(a.name);
      return 0;
    });

    return temp;
  }

  // --- LOGIC LỌC & SẮP XẾP ẢNH ---
  List<Photo> get filteredPhotos {
    List<Photo> temp = _photos
        .where(
          (p) => p.title.toLowerCase().contains(photoSearchQuery.toLowerCase()),
        )
        .toList();
    if (photoSortOrder == 'newest')
      temp.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    else if (photoSortOrder == 'oldest')
      temp.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
    else if (photoSortOrder == 'az')
      temp.sort((a, b) => a.title.compareTo(b.title));
    else if (photoSortOrder == 'za')
      temp.sort((a, b) => b.title.compareTo(a.title));
    return temp;
  }

  void setAlbumFilter(String query) {
    albumSearchQuery = query;
    notifyListeners();
  }

  void setAlbumSort(String order) {
    albumSortOrder = order;
    notifyListeners();
  }

  void setPhotoFilter(String query) {
    photoSearchQuery = query;
    notifyListeners();
  }

  void setPhotoSort(String order) {
    photoSortOrder = order;
    notifyListeners();
  }

  // --- CÁC HÀM TƯƠNG TÁC VỚI SUPABASE CHO ALBUM ---
  Future<void> fetchAlbums() async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await _supabase.from('albums').select();
      _albums = data.map((e) => Album.fromMap(e)).toList();
    } catch (e) {
      print('Lỗi tải Album: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> addAlbum(String name) async {
    try {
      final newAlbum = Album(
        name: name,
        dateCreated: DateTime.now().toIso8601String(),
      );
      await _supabase.from('albums').insert(newAlbum.toMap());
      await fetchAlbums();
    } catch (e) {
      print('Lỗi thêm Album: $e');
    }
  }

  Future<void> deleteAlbum(String albumId) async {
    try {
      await _supabase.from('albums').delete().eq('id', albumId);
      await fetchAlbums();
    } catch (e) {
      print('Lỗi xóa Album: $e');
    }
  }

  Future<void> toggleFavorite(Album album) async {
    try {
      await _supabase
          .from('albums')
          .update({'is_favorite': !album.isFavorite})
          .eq('id', album.id!);
      await fetchAlbums();
    } catch (e) {
      print('Lỗi Yêu thích: $e');
    }
  }

  Future<void> toggleHidden(Album album) async {
    try {
      await _supabase
          .from('albums')
          .update({'is_hidden': !album.isHidden})
          .eq('id', album.id!);
      await fetchAlbums();
    } catch (e) {
      print('Lỗi Ẩn: $e');
    }
  }

  // MỚI: SỬA TÊN ALBUM
  Future<void> editAlbum(String albumId, String newName) async {
    try {
      await _supabase
          .from('albums')
          .update({'name': newName})
          .eq('id', albumId);
      await fetchAlbums();
    } catch (e) {
      print('Lỗi sửa Album: $e');
    }
  }

  // --- CÁC HÀM TƯƠNG TÁC VỚI SUPABASE CHO ẢNH ---
  Future<void> fetchPhotos(String albumId) async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await _supabase
          .from('photos')
          .select()
          .eq('album_id', albumId);
      _photos = data.map((e) => Photo.fromMap(e)).toList();
    } catch (e) {
      print('Lỗi tải Ảnh: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<String?> addPhoto(Photo photo, Uint8List imageBytes) async {
    isLoading = true;
    notifyListeners();
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _supabase.storage
          .from('photos')
          .uploadBinary(
            fileName,
            imageBytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
      photo.imageUrl = _supabase.storage.from('photos').getPublicUrl(fileName);
      await _supabase.from('photos').insert(photo.toMap());
      await fetchPhotos(photo.albumId);
      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<void> deletePhoto(Photo photo) async {
    try {
      await _supabase.from('photos').delete().eq('id', photo.id!);
      final fileName = photo.imageUrl.split('/').last;
      await _supabase.storage.from('photos').remove([fileName]);
      await fetchPhotos(photo.albumId);
    } catch (e) {
      print('Lỗi xóa ảnh: $e');
    }
  }

  // MỚI: SỬA THÔNG TIN ẢNH
  Future<void> editPhoto(
    String photoId,
    String albumId,
    String newTitle,
    String newDescription,
  ) async {
    try {
      await _supabase
          .from('photos')
          .update({'title': newTitle, 'description': newDescription})
          .eq('id', photoId);
      await fetchPhotos(albumId);
    } catch (e) {
      print('Lỗi sửa Ảnh: $e');
    }
  }
}
