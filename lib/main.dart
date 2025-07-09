import 'dart:io';
import 'package:expense_tracker/routes/route.dart';
import 'package:expense_tracker/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  // Inisialisasi dasar yang wajib ada
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi database factory untuk platform desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Inisialisasi format tanggal untuk Bahasa Indonesia
  await initializeDateFormatting('id_ID', null);

  // Menjalankan aplikasi utama Anda dengan ProviderScope
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: AppTheme.lightTheme(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoute.splash,
      onGenerateRoute: RouteGenerator.generatorRoute,
    );
  }
}