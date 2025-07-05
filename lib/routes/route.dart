import 'package:expense_tracker/resources/views/history_page.dart';
import 'package:expense_tracker/resources/views/home_page.dart';
import 'package:flutter/material.dart';

class AppRoute {
  static const String home = '/';
  static const String history = '/history';
}

class RouteGenerator {
  static Route<dynamic> generatorRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoute.home:
        return MaterialPageRoute(builder: (context) => Homepage());
      case AppRoute.history:
        return MaterialPageRoute(builder: (context) => HistoryPage());
      default:
        return MaterialPageRoute(builder: (context) => Homepage());
    }
  }
}
