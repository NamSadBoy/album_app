import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/data_models.dart';
import '../providers/app_providers.dart';

class AddPhotoScreen extends StatefulWidget {
  final String albumId;
  const AddPhotoScreen({Key? key, required this.albumId}) : super(key: key);

  @override
  State<AddPhotoScreen> createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  // Đã sửa lại hàm để nhận tham số Nguồn ảnh (Camera hoặc Thư viện)
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  // MỚI: Menu bật lên từ dưới đáy màn hình để chọn nguồn ảnh
  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Nguồn ảnh',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Chọn từ Thư viện'),
                onTap: () {
                  Navigator.pop(context); // Đóng menu
                  _pickImage(ImageSource.gallery); // Mở thư viện
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.green),
                title: const Text('Chụp từ Camera'),
                onTap: () {
                  Navigator.pop(context); // Đóng menu
                  _pickImage(ImageSource.camera); // Bật máy ảnh
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveData() async {
    if (_titleController.text.isEmpty || _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh và nhập tên!')),
      );
      return;
    }

    final newPhoto = Photo(
      albumId: widget.albumId,
      title: _titleController.text,
      description: _descController.text,
      dateAdded: DateTime.now().toIso8601String(),
      imageUrl: '',
    );

    String? errorMessage = await context.read<GalleryProvider>().addPhoto(
      newPhoto,
      _imageBytes!,
    );

    if (mounted) {
      if (errorMessage == null) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'LỖI: $errorMessage',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<GalleryProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm Ảnh Mới')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap:
                        _showPickerOptions, // MỚI: Khi bấm vào thì gọi menu chọn lên
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: _imageBytes != null
                          ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Bấm để chọn ảnh',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Tên ảnh',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Mô tả chi tiết',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveData,
                      child: const Text(
                        'Lưu Ảnh',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
