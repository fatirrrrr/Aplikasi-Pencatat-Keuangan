import 'package:expense_tracker/resources/views/add_data_page.dart';
import 'package:expense_tracker/resources/views/app_layout.dart';
import 'package:expense_tracker/resources/views/graph_page.dart';
import 'package:expense_tracker/resources/views/history_page.dart';
import 'package:expense_tracker/resources/views/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRoute {
  static const String splash = '/';
  static const String appLayout = '/app_layout';
  static const String history = '/history';
  static const String addData = '/add_data';
  static const String graph = '/graph';
  static const String test = '/test';
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
      case AppRoute.addData:
        // Menampilkan halaman AddDataPage menggunakan wrapper
        return MaterialPageRoute(
          builder: (_) => const AppLayoutWithoutNavbar(child: AddDataPage()),
        );
      case AppRoute.graph:
        return MaterialPageRoute(builder: (context) => const GraphPage());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Halaman Tidak Ditemukan'),
            centerTitle: true,
          ),
          body: const Center(child: Text('ERROR: Rute tidak valid.')),
        );
      },
    );
  }
}
