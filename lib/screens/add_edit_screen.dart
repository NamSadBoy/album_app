import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/data_models.dart';
import '../providers/app_providers.dart';

class AddEditScreen extends StatefulWidget {
  final int? albumId;
  final Photo? photo;

  AddEditScreen({this.albumId, this.photo});

  @override
  _AddEditScreenState createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime _selectedDate;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _title = widget.photo?.title ?? '';
    _description = widget.photo?.description ?? '';
    _imageBytes = widget.photo?.imageBytes;

    if (widget.photo != null && widget.photo!.dateAdded != 'Chưa xác định') {
      try {
        final parts = widget.photo!.dateAdded.split('/');
        _selectedDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } catch (e) {
        _selectedDate = DateTime.now();
      }
    } else {
      _selectedDate = DateTime.now();
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Chọn từ Thư viện'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.green),
                title: const Text('Chụp ảnh mới'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _savePhoto() {
    if (_formKey.currentState!.validate() && _imageBytes != null) {
      _formKey.currentState!.save();
      final provider = context.read<GalleryProvider>();

      final int targetAlbumId = widget.photo?.albumId ?? widget.albumId!;

      final String formattedDate =
          "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}";

      final newPhoto = Photo(
        id: widget.photo?.id,
        albumId: targetAlbumId,
        title: _title,
        description: _description,
        dateAdded: formattedDate,
        imageBytes: _imageBytes!,
      );

      if (widget.photo == null) {
        provider.addPhoto(newPhoto);
      } else {
        provider.updatePhoto(newPhoto);
      }
      Navigator.pop(context);
    } else if (_imageBytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng cung cấp ảnh!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.photo == null ? 'Thêm ảnh vào Album' : 'Sửa ảnh'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: () => _showImageSourceActionSheet(context),
              child: Container(
                height: 200,
                color: Colors.grey[300],
                child: _imageBytes != null
                    ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Bấm để chọn hoặc chụp ảnh',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _title,
              decoration: const InputDecoration(
                labelText: 'Tên ảnh',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Không được để trống' : null,
              onSaved: (value) => _title = value!,
            ),
            const SizedBox(height: 16),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Ngày chụp: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              trailing: const Icon(Icons.calendar_today, color: Colors.blue),
              onTap: () => _selectDate(context),
            ),
            const Divider(),

            const SizedBox(height: 8),
            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onSaved: (value) => _description = value ?? '',
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _savePhoto,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Lưu thông tin', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
