import 'package:flutter/material.dart';
import '../../screens/auth_screen.dart';

class AuthFooter extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onActionTap;

  const AuthFooter({
    super.key,
    required this.isLogin,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: isLogin
              ? "Don't have an account?  "
              : "Already have an account?  ",
          style: const TextStyle(color: NotaColors.textMuted, fontSize: 13),
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: onActionTap,
                child: Text(
                  isLogin ? 'Sign up' : 'Log in',
                  style: const TextStyle(
                    color: NotaColors.purple,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
