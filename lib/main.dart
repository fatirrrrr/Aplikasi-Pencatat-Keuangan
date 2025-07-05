import 'package:expense_tracker/resources/views/splash_screen.dart'; // 1. Import splash screen
import 'package:expense_tracker/routes/route.dart';
import 'package:expense_tracker/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: AppTheme.lightTheme(),
      // darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      onGenerateRoute: RouteGenerator.generatorRoute,
      debugShowCheckedModeBanner: false,
      // 2. Ubah home menjadi SplashScreen()
      home: const SplashScreen(),
    );
  }
}
