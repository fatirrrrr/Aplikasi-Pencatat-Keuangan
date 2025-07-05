import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

// Model data untuk setiap item di navigasi bawah
class BottomNavItems {
  final String title;
  final Widget icon;
  final Widget page; // Halaman/layar yang akan ditampilkan

  BottomNavItems({required this.title, required this.icon, required this.page});
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

  List<PersistentTabConfig> _tabs(BuildContext context) {
    // Mengakses ColorScheme dari context
    final colorScheme = Theme.of(context).colorScheme;

    return items.map((item) {
      return PersistentTabConfig(
        screen: item.page,
        item: ItemConfig(
          activeColorSecondary: colorScheme.onPrimary,
          icon: item.icon,
          iconSize: 28,
          title: item.title,
          activeForegroundColor: colorScheme.onPrimary,
          inactiveForegroundColor: colorScheme.onPrimary.withValues(alpha: 0.4),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PersistentTabView(
      tabs: _tabs(context),
      backgroundColor: colorScheme.primary,
      navBarBuilder: navBarBuilder,
      screenTransitionAnimation: const ScreenTransitionAnimation(
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      stateManagement: true,
      margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      // hideNavigationBarWhenKeyboardShows: true,
    );
  }
}
