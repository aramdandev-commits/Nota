import 'package:flutter/material.dart';

/// Multi-line text field for pasting / typing text to analyze.
class AiTextInput extends StatelessWidget {
  final TextEditingController controller;

  const AiTextInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A2E) : Theme.of(context).cardColor;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.onSurface.withValues(alpha: 0.07)),
      ),
      child: TextField(
        controller: controller,
        maxLines: 7,
        minLines: 7,
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        decoration: InputDecoration(
          hintText: 'Paste or type text to analyze...',
          hintStyle: TextStyle(
            color: cs.onSurface.withValues(alpha: 0.3),
            fontSize: 14,
            fontFamily: 'Inter',
          ),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
