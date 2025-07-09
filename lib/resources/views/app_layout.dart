import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/resources/views/graph_page.dart';
import 'package:expense_tracker/resources/views/history_page.dart';
import 'package:expense_tracker/resources/views/home_page.dart';
import 'package:expense_tracker/resources/widget/navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

// 1. Ubah menjadi ConsumerStatefulWidget
class AppLayout extends ConsumerStatefulWidget {
  const AppLayout({super.key});

  @override
  ConsumerState<AppLayout> createState() => _AppLayoutState();
}

// 2. Ubah State menjadi ConsumerState
class _AppLayoutState extends ConsumerState<AppLayout> {
  final PersistentTabController _controller = PersistentTabController();

  // 3. Tambahkan initState untuk memuat data
  @override
  void initState() {
    super.initState();
    // Memuat data transaksi saat layout utama ini pertama kali dibuat
    // Ini adalah titik paling aman dan tepat setelah splash screen
    Future.microtask(() {
      DateTime now = DateTime.now();
      // interval sehari
      DateTime startDate = DateTime(now.year, now.month, now.day);
      DateTime endDate =
          DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      ref.read(transactionProvider.notifier).loadTransactions();
      ref
          .read(transactionProvider.notifier)
          .loadTransactionsByDateRange(startDate, endDate);
    });
  }

  // Daftar navigasi tidak perlu diubah
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
    // Bagian build tidak perlu diubah
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

// Wrapper ini tidak perlu diubah
class AppLayoutWithoutNavbar extends StatelessWidget {
  final Widget child;

  const AppLayoutWithoutNavbar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child);
  }
}
