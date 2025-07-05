import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History Page')),
      body: Center(
        child: Text(
          'Welcome to the History Page!',
          style: TextStyle(fontSize: 24, color: Colors.black54),
        ),
      ),
    );
  }
}
