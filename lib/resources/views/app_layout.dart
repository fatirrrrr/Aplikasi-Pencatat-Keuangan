import 'package:expense_tracker/resources/views/graph_page.dart';
import 'package:expense_tracker/resources/views/history_page.dart';
import 'package:expense_tracker/resources/views/home_page.dart';
import 'package:expense_tracker/resources/views/add_data_page.dart';
import 'package:expense_tracker/resources/widget/navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  final PersistentTabController _controller = PersistentTabController();

  final List<BottomNavItems> navItems = [
    BottomNavItems(
      icon: const Icon(Icons.home),
      title: 'Home',
      page: const Homepage(),
    ),
    BottomNavItems(
      icon: const Icon(Icons.bar_chart),
      title: 'Chart',
      page: const GraphPage(),
    ),
    BottomNavItems(
      icon: const Icon(Icons.history),
      title: 'History',
      page: const HistoryPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentNavbarBottom(
        items: navItems,
        navBarBuilder: (navBarConfig) => NeumorphicBottomNavBar(
          navBarConfig: navBarConfig,
          navBarDecoration: NavBarDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
      ),
    );
  }
}

// Wrapper untuk halaman yang tidak memerlukan navbar
class AppLayoutWithoutNavbar extends StatelessWidget {
  final Widget child;

  const AppLayoutWithoutNavbar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child);
  }
}
