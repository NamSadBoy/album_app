import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import 'album_view_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<GalleryProvider>().fetchAlbums());
  }

  // Hộp thoại tạo mã PIN lần đầu
  void _showSetPinDialog() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thiết lập Mã PIN'),
        content: TextField(
          controller: pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Nhập mã PIN mới (VD: 1234)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (pinController.text.isNotEmpty) {
                context.read<GalleryProvider>().setPin(pinController.text);
                context.read<GalleryProvider>().toggleShowHidden();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Lưu & Mở khóa'),
          ),
        ],
      ),
    );
  }

  // Hộp thoại nhập mã PIN để mở khóa
  void _showEnterPinDialog() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nhập Mã PIN'),
        content: TextField(
          controller: pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Nhập mã PIN của bạn'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = context.read<GalleryProvider>();
              if (provider.checkPin(pinController.text)) {
                provider.toggleShowHidden(); // Đúng PIN thì mở khóa
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mã PIN không chính xác!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  // (Giữ nguyên hộp thoại tạo Album)
  void _showAddAlbumDialog(BuildContext context) {
    final txtController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo Album mới'),
        content: TextField(
          controller: txtController,
          decoration: const InputDecoration(hintText: 'Nhập tên Album...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (txtController.text.isNotEmpty) {
                context.read<GalleryProvider>().addAlbum(txtController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GalleryProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Album App'),
        actions: [
          // NÚT BẬT/TẮT XEM ALBUM ẨN
          IconButton(
            icon: Icon(
              provider.isShowingHidden
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: provider.isShowingHidden ? Colors.red : null,
            ),
            onPressed: () {
              if (provider.isShowingHidden) {
                provider.toggleShowHidden(); // Khóa lại thì không cần hỏi PIN
              } else {
                if (provider.hasPin)
                  _showEnterPinDialog(); // Đã có PIN thì hỏi nhập
                else
                  _showSetPinDialog(); // Chưa có PIN thì bắt tạo
              }
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => provider.setAlbumSort(value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'newest', child: Text('Mới nhất')),
              const PopupMenuItem(value: 'oldest', child: Text('Cũ nhất')),
              const PopupMenuItem(value: 'az', child: Text('Tên: A-Z')),
              const PopupMenuItem(value: 'za', child: Text('Tên: Z-A')),
            ],
          ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
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
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => provider.setAlbumFilter(value),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: provider.filteredAlbums.length,
                    itemBuilder: (context, index) {
                      final album = provider.filteredAlbums[index];
                      return ListTile(
                        leading: Icon(
                          album.isHidden
                              ? Icons.lock
                              : Icons.folder, // Đổi icon nếu bị ẩn
                          size: 40,
                          color: album.isHidden ? Colors.grey : Colors.blue,
                        ),
                        title: Text(
                          album.name,
                          style: TextStyle(
                            fontWeight: album.isFavorite
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: album.isFavorite
                            ? const Text(
                                '⭐ Yêu thích',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                ),
                              )
                            : null,

                        // NÚT 3 CHẤM MENU CHO MỖI ALBUM
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'fav') provider.toggleFavorite(album);
                            if (value == 'hide') provider.toggleHidden(album);
                            if (value == 'delete') {
                              // Hộp thoại xác nhận xóa
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Xác nhận xóa'),
                                  content: const Text(
                                    'Xóa Album này và toàn bộ ảnh bên trong?',
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
                                        provider.deleteAlbum(album.id!);
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text(
                                        'Xóa',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          itemBuilder: (ctx) => [
                            PopupMenuItem(
                              value: 'fav',
                              child: Row(
                                children: [
                                  Icon(
                                    album.isFavorite
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    album.isFavorite
                                        ? 'Bỏ Yêu thích'
                                        : 'Yêu thích',
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'hide',
                              child: Row(
                                children: [
                                  Icon(
                                    album.isHidden
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(album.isHidden ? 'Bỏ Ẩn' : 'Ẩn Album'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Xóa',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AlbumViewScreen(
                              albumId: album.id!,
                              albumName: album.name,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAlbumDialog(context),
        child: const Icon(Icons.create_new_folder),
      ),
    );
  }
}
