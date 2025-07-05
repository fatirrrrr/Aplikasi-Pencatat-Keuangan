import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          // export file
          IconButton(onPressed: () {}, icon: Icon(Icons.drive_file_move_sharp)),
        ],
      ),
      body: Center(
        child: Text(
          'History Page!',
          style: TextStyle(fontSize: 24, color: Colors.black54),
        ),
      ),
    );
  }
}
