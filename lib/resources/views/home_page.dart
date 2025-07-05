import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    // Ambil tema dan textTheme sekali agar tidak berulang
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height:
                180,
            width: double.infinity,
            color: colorScheme.primary,
            child: SafeArea(
              bottom: false, // Tidak perlu SafeArea di bagian bawah header
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 3. Gunakan TextTheme untuk konsistensi & adaptasi dark mode
                  Text(
                    'Expense Tracker',
                    style: textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kelola pemasukan & pengeluaranmu dengan mudah',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 4. Gunakan Padding untuk memberi jarak, bukan SizedBox di dalam Column/ListView
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              // 3. Gunakan TextTheme di sini juga
              child: Text(
                'Welcome to the Home Page!',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ),
          // Padding untuk tombol agar tidak menempel di tepi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ElevatedButton(
              onPressed: () {
                // Action when button is pressed
              },
              child: const Text('Go to Details'),
            ),
          ),
          const SizedBox(height: 20), // Spasi di akhir
        ],
      ),
    );
  }
}
