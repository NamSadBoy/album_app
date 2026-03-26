import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/data_models.dart';
import '../providers/app_providers.dart';

class DetailScreen extends StatelessWidget {
  final Photo photo;
  const DetailScreen({Key? key, required this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(photo.title),
        // NÚT XÓA KÈM CẢNH BÁO
        actions: [
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
                        context.read<GalleryProvider>().deletePhoto(photo);
                        Navigator.pop(ctx); // Đóng hộp thoại
                        Navigator.pop(context); // Thoát ra ngoài lưới ảnh
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
                photo.imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.white,
            child: Text(
              'Mô tả: ${photo.description}',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
