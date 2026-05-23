import 'package:flutter/material.dart';

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
    final cs = Theme.of(context).colorScheme;
    
    return Center(
      child: RichText(
        text: TextSpan(
          text: isLogin
              ? "Don't have an account?  "
              : "Already have an account?  ",
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 13),
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: onActionTap,
                child: Text(
                  isLogin ? 'Sign up' : 'Log in',
                  style: const TextStyle(
                    color: Color(0xFF9810FA),
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
