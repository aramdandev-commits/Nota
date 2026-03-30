import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen2 extends StatelessWidget {
  const SplashScreen2({super.key});

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

            /// 🎯 المحتوى في النص
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 🟣 Logo
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

                  /// 🟣 divider + NOTA
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

                  const SizedBox(height: 10),

                  /// 🟢 subtitle
                  const Text(
                    "AI-Powered Note-Taking Platform",
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

            /// 🔴 dots تحت الشاشة (FIXED 💥)
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
                    children: [
                      dot(isActive: true),
                      const SizedBox(width: 6.8),
                      dot(),
                      const SizedBox(width: 6.8),
                      dot(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔵 Glow
  Widget _glow({required Color color}) {
    return Center(
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.06),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  /// 🟣 line
  Widget _line() {
    return Container(
      width: 40,
      height: 1,
      color: const Color(0xFFFB64B6).withOpacity(0.6),
    );
  }

  /// 🔴 dot
  Widget dot({bool isActive = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 8 : 6,
      height: isActive ? 8 : 6,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFFB64B6).withOpacity(0.82)
            : const Color(0xFFFF4DA6).withOpacity(0.57),
        shape: BoxShape.circle,
      ),
    );
  }
}
