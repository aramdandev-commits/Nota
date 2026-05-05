import 'package:flutter/material.dart';
import '../../screens/auth/auth_screen.dart';

class SocialButtonsRow extends StatelessWidget {
  const SocialButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _SocialButton(child: _GoogleIcon())),
        SizedBox(width: 12),
        Expanded(
          child: _SocialButton(
            child: Icon(Icons.apple, color: Colors.white, size: 22),
          ),
        ),
        SizedBox(width: 12),
        Expanded(child: _SocialButton(child: _MicrosoftIcon())),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget child;

  const _SocialButton({required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: NotaColors.socialBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: NotaColors.border),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final segments = [
      (0.0, 90.0, const Color(0xFF4285F4)),
      (90.0, 90.0, const Color(0xFF34A853)),
      (180.0, 90.0, const Color(0xFFFBBC05)),
      (270.0, 90.0, const Color(0xFFEA4335)),
    ];

    for (final seg in segments) {
      final paint = Paint()
        ..color = seg.$3
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.18;

      final startAngle = seg.$1 * 3.14159 / 180;
      final sweepAngle = seg.$2 * 3.14159 / 180;

      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r * 0.72),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _MicrosoftIcon extends StatelessWidget {
  const _MicrosoftIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: GridView.count(
        crossAxisCount: 2,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        children: const [
          ColoredBox(color: Color(0xFFF25022)),
          ColoredBox(color: Color(0xFF7FBA00)),
          ColoredBox(color: Color(0xFF00A4EF)),
          ColoredBox(color: Color(0xFFFFB900)),
        ],
      ),
    );
  }
}
