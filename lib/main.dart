import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'providers/app_providers.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => GalleryProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Quản Lý Album',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: DashboardScreen(),
    );
  }
}
