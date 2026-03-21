import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import '../models/data_models.dart';
import 'album_view_screen.dart';
import 'settings_screen.dart';

enum SortOption { newest, oldest, az, za }

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _searchQuery = '';
  SortOption _sortOption = SortOption.newest;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<GalleryProvider>().loadData());
  }

  void _showAlbumDialog([Album? existingAlbum]) {
    String albumName = existingAlbum?.name ?? '';
    final isEditing = existingAlbum != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Sửa tên Album' : 'Tạo Album mới'),
        content: TextFormField(
          initialValue: albumName,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Tên Album',
            border: OutlineInputBorder(),
          ),
          onChanged: (val) => albumName = val,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (albumName.trim().isNotEmpty) {
                if (isEditing) {
                  existingAlbum.name = albumName;
                  context.read<GalleryProvider>().updateAlbum(existingAlbum);
                } else {
                  final newAlbum = Album(name: albumName);
                  context.read<GalleryProvider>().addAlbum(newAlbum);
                }
                Navigator.pop(ctx);
              }
            },
            child: Text(isEditing ? 'Lưu' : 'Tạo'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAlbum(BuildContext context, Album album) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Xóa album này sẽ xóa toàn bộ ảnh bên trong. Bạn có chắc chắn không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.read<GalleryProvider>().deleteAlbum(album.id!);
              Navigator.pop(ctx);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đại Nam Album'),
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (SortOption result) {
              setState(() {
                _sortOption = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem<SortOption>(
                value: SortOption.newest,
                child: Text('Mới nhất'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.oldest,
                child: Text('Cũ nhất'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.az,
                child: Text('Tên A-Z'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.za,
                child: Text('Tên Z-A'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm Album...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<GalleryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading)
                  return const Center(child: CircularProgressIndicator());

                var filteredAlbums = provider.albums
                    .where((a) => a.name.toLowerCase().contains(_searchQuery))
                    .toList();

                filteredAlbums.sort((a, b) {
                  switch (_sortOption) {
                    case SortOption.az:
                      return a.name.toLowerCase().compareTo(
                        b.name.toLowerCase(),
                      );
                    case SortOption.za:
                      return b.name.toLowerCase().compareTo(
                        a.name.toLowerCase(),
                      );
                    case SortOption.oldest:
                      return a.id!.compareTo(b.id!);
                    case SortOption.newest:
                    default:
                      return b.id!.compareTo(a.id!);
                  }
                });

                if (provider.albums.isEmpty)
                  return const Center(
                    child: Text('Chưa có Album nào. Tạo ngay!'),
                  );
                if (filteredAlbums.isEmpty)
                  return const Center(
                    child: Text('Không tìm thấy Album phù hợp!'),
                  );

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredAlbums.length,
                  itemBuilder: (context, index) {
                    final album = filteredAlbums[index];
                    final photoCount = provider
                        .getPhotosByAlbum(album.id!)
                        .length;

                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.folder,
                          size: 40,
                          color: Colors.blue,
                        ),
                        title: Text(
                          album.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('$photoCount ảnh'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.orange,
                              ),
                              onPressed: () => _showAlbumDialog(album),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _confirmDeleteAlbum(context, album),
                            ),
                          ],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AlbumViewScreen(album: album),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAlbumDialog(),
        child: const Icon(Icons.create_new_folder),
      ),
    );
  }
}
