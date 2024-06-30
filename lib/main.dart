import 'package:flutter/material.dart';
import 'package:gdd/screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GDD',
      debugShowCheckedModeBanner: false,
      home: const Home(),
    );
  }
}
