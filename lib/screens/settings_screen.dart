import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Chế độ Tối (Dark Mode)'),
            value: themeProvider.isDarkMode,
            onChanged: (value) => context.read<ThemeProvider>().toggleTheme(),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.school),
            title: Text('Thông tin sinh viên'),
            subtitle: Text('Sinh viên: Nguyễn Nam - Đại học Đại Nam'),
          ),
        ],
      ),
    );
  }
}
