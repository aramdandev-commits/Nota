import 'package:flutter/material.dart';
import '../../screens/auth/auth_screen.dart';

class AuthDivider extends StatelessWidget {
  final String text;

  const AuthDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: NotaColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: const TextStyle(
              color: NotaColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: NotaColors.border)),
      ],
    );
  }
}
