import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:indevche/record_list_screen.dart';

void main() {
  debugPaintSizeEnabled = false;
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const RecordListScreen(),
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
    );
  }
}
