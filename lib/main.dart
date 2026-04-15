import 'package:flutter/material.dart';
import 'package:nota/screens/next.dart';
import 'package:nota/screens/onboarding_screen.dart';
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
        OnboardingScreen.id: (context) => const OnboardingScreen(),
        MyWidget.id: (context) => const MyWidget(),
      },
    );
  }
}
