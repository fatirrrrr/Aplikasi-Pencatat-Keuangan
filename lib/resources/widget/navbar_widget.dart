import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

// Model data untuk setiap item di navigasi bawah
class BottomNavItems {
  final String title;
  final Widget icon;
  final Widget page; // Halaman/layar yang akan ditampilkan

  BottomNavItems({
    required this.title,
    required this.icon,
    required this.page,
  });
}

// Widget reusable untuk Persistent Bottom Navigation Bar
class PersistentNavbarBottom extends StatelessWidget {
  final List<BottomNavItems> items;
  final Widget Function(NavBarConfig) navBarBuilder;

  const PersistentNavbarBottom({
    super.key,
    required this.items,
    required this.navBarBuilder,
  });

  List<PersistentTabConfig> _tabs() {
    return items.map((item) {
      return PersistentTabConfig(
        screen: item.page,
        item: ItemConfig(
          icon: item.icon,
          title: item.title,
          activeForegroundColor: Colors.blue,
          inactiveBackgroundColor: Colors.grey,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      tabs: _tabs(),
      navBarBuilder: navBarBuilder,
      // screenTransitionAnimation: const ScreenTransitionAnimation(
      //   animateTabTransition: true,
      //   curve: Curves.ease,
      //   duration: Duration(milliseconds: 200),
      // ),
      // stateManagement: true,
      // hideNavigationBarWhenKeyboardShows: true,
    );
  }
}