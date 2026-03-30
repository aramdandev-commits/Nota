import 'package:flutter/material.dart';
import 'package:nota/splash.dart';
import 'package:nota/splash2.dart';
import 'package:nota/splash3.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen3(),
    );
  }
}
