import 'package:flutter/material.dart';
import 'package:nota/screens/introScreen.dart';
import 'package:nota/screens/splashScreen.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => const SplashScreen(),
        Introscreen.id: (context) => const Introscreen(),
      },
    );
  }
}
