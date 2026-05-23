import 'package:flutter/material.dart';
import '../../controllers/ai_analyze_provider.dart';

/// Tab toggle between "Paste Text" and "From Note" modes.
class AiModeToggle extends StatelessWidget {
  final AiAnalyzeMode selected;
  final ValueChanged<AiAnalyzeMode> onChanged;

  const AiModeToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFEEEEF5);

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _Tab(
            label: 'Paste Text',
            isSelected: selected == AiAnalyzeMode.pasteText,
            onTap: () => onChanged(AiAnalyzeMode.pasteText),
          ),
          _Tab(
            label: 'From Note',
            isSelected: selected == AiAnalyzeMode.fromNote,
            onTap: () => onChanged(AiAnalyzeMode.fromNote),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF9810FA), Color(0xFFDB2777)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : cs.onSurface.withValues(alpha: 0.5),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
