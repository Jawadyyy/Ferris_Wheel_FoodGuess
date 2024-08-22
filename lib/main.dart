import 'package:flutter/material.dart';
import 'food_wheel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Wheel',
      theme: ThemeData(),
      home: const SpokeWheel(),
    );
  }
}
