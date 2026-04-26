import 'package:flutter/material.dart';

// ----Nota----
Widget line() {
  return Container(
    width: 40,
    height: 1,
    color: const Color(0xFFFB64B6).withAlpha(153), // 153 ≈ 0.6 opacity
  );
}

// for gradient in splash
Widget glow({Color color = Colors.black}) {
  Color withAlpha(Color color, double opacity) {
    int alpha = (opacity * 255).round().clamp(0, 255);
    return color.withAlpha(alpha);
  }

  return Container(
    width: 300,
    height: 300,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          withAlpha(color, 0.2), // strong center
          withAlpha(color, 0.06), // fade
          withAlpha(color, 0.0), // fully transparent edge
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
    ),
  );
}

// loading dots
Widget dot({bool isActive = false}) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    width: 8,
    height: 8,
    decoration: BoxDecoration(
      color: const Color(0xFFFF4DA6).withAlpha(isActive ? 255 : 100),
      shape: BoxShape.circle,
    ),
  );
}
