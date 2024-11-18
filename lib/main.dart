import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rodis_service/screens/welcome_screen.dart';

void main() {
  debugPaintSizeEnabled = false;
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const WelcomeScreen(),
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
    );
  }
}
