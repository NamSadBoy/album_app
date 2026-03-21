import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/data_models.dart';
import '../providers/app_providers.dart';
import 'add_edit_screen.dart';

class DetailScreen extends StatelessWidget {
  final Photo photo;
  DetailScreen({required this.photo});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa ảnh này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.read<GalleryProvider>().deletePhoto(photo.id!);
              Navigator.pop(ctx);
              Navigator.pop(context);
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
        title: Text(photo.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AddEditScreen(photo: photo)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InteractiveViewer(
              panEnabled: false,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.memory(photo.imageBytes, fit: BoxFit.contain),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ngày chụp: ${photo.dateAdded}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  Text(photo.description, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
