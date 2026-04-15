import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nota/helper/splashScreenFunctions.dart';
import 'package:nota/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static String id = "splash_screen";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  int _activeDot = 0;
  late Timer _timer;

  @override
  @override
  void initState() {
    super.initState();

    // Start the dot animation (optional, already in your code)
    _timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() {
        _activeDot = (_activeDot + 1) % 3;
      });
    });

    // Navigate to the next screen after 2 seconds
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, OnboardingScreen.id);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.2,
            colors: [Color(0xFF1A0533), Color(0xFF2D0B5E), Color(0xFF1A0533)],
          ),
        ),
        child: Stack(
          children: [
            // glow top
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: glow(color: const Color(0xFF7C3AED)),
            ),

            // glow bottom
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: glow(color: const Color(0xFFDB2777)),
            ),

            // content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                        ),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          "assets/images/frame_10.svg",
                          width: 45,
                          height: 45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Nota",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 42,
                        height: 1.5,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        line(),
                        const SizedBox(width: 10),
                        const Text(
                          "NOTA",
                          style: TextStyle(
                            color: Color(0xFFDA55A5),
                            fontSize: 12,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        line(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "AI-Powered Note-Taking Platform",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: Color(0xFFDAB2FF),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.08,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 40,
                  height: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Row(
                        children: [
                          dot(isActive: _activeDot == index),
                          if (index != 2) const SizedBox(width: 6.8),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
