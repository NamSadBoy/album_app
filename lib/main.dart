import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/app_providers.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rbcedzwpkmxbgapobixk.supabase.co',
    anonKey: 'sb_publishable_UB5ZV3Z_HOaPl6UuBUWNFg_zfvzzsqr',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GalleryProvider()),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ), // MỚI: Thêm ThemeProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lắng nghe thay đổi giao diện Sáng/Tối
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Album App',
      // MỚI: Cấu hình màu sắc Sáng/Tối
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const DashboardScreen(),
    );
  }
}
