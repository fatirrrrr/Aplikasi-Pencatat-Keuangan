import 'package:expense_tracker/routes/route.dart';
import 'package:expense_tracker/resources/views/app_layout.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AppLayout(),
      onGenerateRoute: RouteGenerator.generatorRoute,
    );
  }
}
