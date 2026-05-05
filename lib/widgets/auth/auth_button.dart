import 'package:flutter/material.dart';
import '../../screens/auth/auth_screen.dart';

class AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AuthButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: NotaColors.gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: NotaColors.purple.withValues(alpha: .35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: NotaColors.pink.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
