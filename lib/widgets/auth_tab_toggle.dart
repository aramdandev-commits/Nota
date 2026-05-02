import 'package:flutter/material.dart';
import '../../screens/auth_screen.dart';

class AuthTabToggle extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onLoginTap;
  final VoidCallback onSignUpTap;

  const AuthTabToggle({
    super.key,
    required this.isLogin,
    required this.onLoginTap,
    required this.onSignUpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: NotaColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NotaColors.border),
      ),
      child: Row(
        children: [
          _AuthTab(label: 'Log In', isActive: isLogin, onTap: onLoginTap),
          _AuthTab(label: 'Sign Up', isActive: !isLogin, onTap: onSignUpTap),
        ],
      ),
    );
  }
}

class _AuthTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _AuthTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: isActive ? NotaColors.gradient : null,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: NotaColors.purple.withValues(alpha: 0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : NotaColors.textMuted,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
