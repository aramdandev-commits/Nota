import 'package:flutter/material.dart';
import 'package:nota/l10n/app_localizations.dart';

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
              ? AppLocalizations.of(context)!.dontHaveAccount
              : AppLocalizations.of(context)!.alreadyHaveAccount,
          style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.5), fontSize: 13),
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: onActionTap,
                child: Text(
                  isLogin
                      ? AppLocalizations.of(context)!.signUp
                      : AppLocalizations.of(context)!.logIn,
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
