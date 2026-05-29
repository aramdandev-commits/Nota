import 'package:flutter/material.dart';

/// Dark-themed toggle / switch tile.
class SpaceSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SpaceSwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151821) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? null
            : Border.all(color: cs.onSurface.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: cs.primary,
            activeTrackColor: cs.primary.withValues(alpha: 0.3),
            inactiveThumbColor: cs.onSurface.withValues(alpha: 0.4),
            inactiveTrackColor: isDark
                ? const Color(0xFF202430)
                : Theme.of(context).scaffoldBackgroundColor,
          ),
        ],
      ),
    );
  }
}
