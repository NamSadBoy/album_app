import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import 'add_photo_screen.dart';
import 'detail_screen.dart';

class AlbumViewScreen extends StatefulWidget {
  final String albumId;
  final String albumName;

  const AlbumViewScreen({
    Key? key,
    required this.albumId,
    required this.albumName,
  }) : super(key: key);

  @override
  State<AlbumViewScreen> createState() => _AlbumViewScreenState();
}

class _AlbumViewScreenState extends State<AlbumViewScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<GalleryProvider>().fetchPhotos(widget.albumId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GalleryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.albumName),
        actions: [
          // NÚT SẮP XẾP ẢNH
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => provider.setPhotoSort(value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'newest', child: Text('Mới nhất')),
              const PopupMenuItem(value: 'oldest', child: Text('Cũ nhất')),
              const PopupMenuItem(value: 'az', child: Text('Tên: A-Z')),
              const PopupMenuItem(value: 'za', child: Text('Tên: Z-A')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // THANH TÌM KIẾM ẢNH
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm ảnh theo tên...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => provider.setPhotoFilter(value),
            ),
          ),
          // LƯỚI ẢNH
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount:
                        provider.filteredPhotos.length, // Dùng danh sách đã lọc
                    itemBuilder: (context, index) {
                      final photo = provider.filteredPhotos[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(photo: photo),
                          ),
                        ),
                        child: GridTile(
                          footer: GridTileBar(
                            backgroundColor: Colors.black54,
                            title: Text(photo.title),
                          ),
                          child: Image.network(
                            photo.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
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
            builder: (_) => AddPhotoScreen(albumId: widget.albumId),
          ),
        ),
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
