import 'package:flutter/material.dart';
import 'package:nota/l10n/app_localizations.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      style: TextStyle(color: cs.onSurface, fontSize: 14),
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.search,
        hintStyle:
            TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 14),
        prefixIcon: Icon(Icons.search,
            color: cs.onSurface.withValues(alpha: 0.5), size: 20),
        filled: true,
        fillColor:
            isDark ? const Color(0xFF1E2029) : Theme.of(context).cardColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: isDark
              ? BorderSide.none
              : BorderSide(color: cs.onSurface.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: isDark
              ? BorderSide.none
              : BorderSide(color: cs.onSurface.withValues(alpha: 0.1)),
        ),
      ),
      onChanged: (value) {
        // Search logic to be added here
      },
    );
  }
}
