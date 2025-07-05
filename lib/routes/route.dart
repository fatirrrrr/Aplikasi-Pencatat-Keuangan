import 'package:expense_tracker/resources/views/app_layout.dart';
import 'package:expense_tracker/resources/views/history_page.dart';
import 'package:expense_tracker/resources/views/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRoute {
  static const String splash = '/';
  static const String appLayout = '/app_layout';
  static const String history = '/history';

}

class RouteGenerator {
  static Route<dynamic> generatorRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoute.splash:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case AppRoute.appLayout:
        return MaterialPageRoute(builder: (context) => const AppLayout());
      case AppRoute.history:
        return MaterialPageRoute(builder: (context) => const HistoryPage());
      default:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
    }
  }
}
