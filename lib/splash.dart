import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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
            colors: [Color(0xFF1A0533), Color(0xFF2D0B5E), Color(0XFF1A0533)],
          ),
        ),
        child: Stack(
          children: [
            /// 🔵 Glow فوق
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: _glow(color: Color(0xFF7C3AED)),
            ),

            /// 🔴 Glow تحت
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: _glow(color: Color(0xFFDB2777)),
            ),

            /// 🎯 المحتوى
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 🟣 Logo container
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        "assets/logos/frame_10.svg",
                        width: 45,
                        height: 45,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// 🟡 Title
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

                  /// 🟣 Divider + subtitle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _line(),
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
                      _line(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glow({Color color = Colors.black}) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.2), // مركز قوي
            color.withOpacity(0.06),
            Colors.transparent, // اختفاء تدريجي
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _line() {
    return Container(
      width: 40,
      height: 1,
      color: Color(0xFFFB64B6).withOpacity(0.6),
    );
  }
}
