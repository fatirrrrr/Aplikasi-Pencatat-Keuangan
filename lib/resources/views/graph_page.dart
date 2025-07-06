import 'package:flutter/material.dart';

class GraphPage extends StatelessWidget {
  const GraphPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Statistik Keuangan Bulanan',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        actions: [
          // export file
          IconButton(onPressed: () {}, icon: Icon(Icons.drive_file_move_sharp)),
        ],
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Text(
          'Graph Page!',
          style: TextStyle(fontSize: 24, color: Colors.black54),
        ),
      ),
    );
  }
}
