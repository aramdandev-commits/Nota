import 'package:flutter/material.dart';
import 'package:nota/l10n/app_localizations.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final syncBg = isDark ? const Color(0xFF0F2922) : const Color(0xFFE8F8F1);
    final syncColor = const Color(0xFF00B074);
    final notifBg = isDark ? const Color(0xFF1E2029) : const Color(0xFFEEEEF5);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.goodAfternoon,
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.5),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.welecomeBack,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 23,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: syncBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud_done_outlined, color: syncColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.allChangesSynced,
                    style: TextStyle(
                      color: syncColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Theme.of(context).cardColor,
                    title: Text(AppLocalizations.of(context)!.notifications,
                        style: TextStyle(color: cs.onSurface)),
                    content: Row(
                      children: [
                        Icon(Icons.cloud_done_outlined,
                            color: syncColor, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          AppLocalizations.of(context)!.allChangesSyncedPop,
                          style: TextStyle(color: cs.onSurface),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context)!.close),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: notifBg,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  children: [
                    Icon(Icons.notifications_none,
                        color: cs.onSurface.withValues(alpha: 0.5), size: 24),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
