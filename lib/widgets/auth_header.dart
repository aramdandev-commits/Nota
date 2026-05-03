import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../screens/auth_screen.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SvgPicture.asset('assets/images/nota.svg', width: 45, height: 45),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nota',
                  style: TextStyle(
                    color: NotaColors.textPrimary,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  'AI-Powered Notes',
                  style: TextStyle(
                    color: NotaColors.purple,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: NotaColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NotaColors.border),
          ),
          child: const Icon(
            Icons.language_rounded,
            color: NotaColors.textMuted,
            size: 20,
          ),
        ),
      ],
    );
  }
}
