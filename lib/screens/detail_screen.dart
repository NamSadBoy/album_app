import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/data_models.dart';
import '../providers/app_providers.dart';

class DetailScreen extends StatefulWidget {
  final Photo photo;
  const DetailScreen({Key? key, required this.photo}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Photo currentPhoto;

  @override
  void initState() {
    super.initState();
    currentPhoto = widget.photo;
  }

  void _showEditPhotoDialog() {
    final titleController = TextEditingController(text: currentPhoto.title);
    final descController = TextEditingController(
      text: currentPhoto.description,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa thông tin ảnh'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tên ảnh',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                context.read<GalleryProvider>().editPhoto(
                  currentPhoto.id!,
                  currentPhoto.albumId,
                  titleController.text,
                  descController.text,
                );

                setState(() {
                  currentPhoto.title = titleController.text;
                  currentPhoto.description = descController.text;
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Lưu thay đổi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentPhoto.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: _showEditPhotoDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xác nhận xóa'),
                  content: const Text(
                    'Bạn có chắc chắn muốn xóa bức ảnh này không?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        context.read<GalleryProvider>().deletePhoto(
                          currentPhoto,
                        );
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Xóa',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.network(
                currentPhoto.imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Theme.of(context).cardColor,
            child: Text(
              'Mô tả: ${currentPhoto.description}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
