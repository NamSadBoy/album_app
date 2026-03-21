import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import '../models/data_models.dart';
import 'add_edit_screen.dart';
import 'detail_screen.dart';

enum SortOption { newest, oldest, az, za }

class AlbumViewScreen extends StatefulWidget {
  final Album album;
  AlbumViewScreen({required this.album});

  @override
  _AlbumViewScreenState createState() => _AlbumViewScreenState();
}

class _AlbumViewScreenState extends State<AlbumViewScreen> {
  String _searchQuery = '';
  SortOption _sortOption = SortOption.newest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.album.name),
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
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm ảnh theo tên...',
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
                var albumPhotos = provider
                    .getPhotosByAlbum(widget.album.id!)
                    .where((p) => p.title.toLowerCase().contains(_searchQuery))
                    .toList();

                albumPhotos.sort((a, b) {
                  switch (_sortOption) {
                    case SortOption.az:
                      return a.title.toLowerCase().compareTo(
                        b.title.toLowerCase(),
                      );
                    case SortOption.za:
                      return b.title.toLowerCase().compareTo(
                        a.title.toLowerCase(),
                      );
                    case SortOption.oldest:
                      return a.id!.compareTo(b.id!);
                    case SortOption.newest:
                    default:
                      return b.id!.compareTo(a.id!);
                  }
                });

                if (albumPhotos.isEmpty)
                  return const Center(child: Text('Không có ảnh nào!'));

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: albumPhotos.length,
                  itemBuilder: (context, index) {
                    final photo = albumPhotos[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(photo: photo),
                        ),
                      ),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Image.memory(
                                photo.imageBytes,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                photo.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ],
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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddEditScreen(albumId: widget.album.id),
          ),
        ),
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
