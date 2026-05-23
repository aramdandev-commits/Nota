import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../model/ai_analysis_model.dart';

/// Card that displays the AI analysis result with Copy / Save as Note actions.
class AiResultCard extends StatelessWidget {
  final AiAnalysisResult result;
  final bool copied;
  final VoidCallback onCopy;
  final VoidCallback onSaveAsNote;
  final VoidCallback onNewAnalysis;

  const AiResultCard({
    super.key,
    required this.result,
    required this.copied,
    required this.onCopy,
    required this.onSaveAsNote,
    required this.onNewAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1A1A2E) : Theme.of(context).cardColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analysis Results',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 20,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.onSurface.withValues(alpha: 0.07)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(label: 'SUMMARY'),
              const SizedBox(height: 10),
              Text(
                result.summary,
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.85),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),

              _SectionLabel(label: 'KEY POINTS'),
              const SizedBox(height: 10),
              ...result.keyPoints.map(
                (point) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF9810FA),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          point,
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.85),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: copied ? Icons.check_rounded : Icons.copy_rounded,
                label: copied ? 'Copied!' : 'Copy',
                onTap: () {
                  final text = '${result.summary}\n\n${result.keyPoints.join('\n')}';
                  Clipboard.setData(ClipboardData(text: text));
                  onCopy();
                },
                isAccent: false,
                isCopied: copied,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.add_rounded,
                label: 'Save as Note',
                onTap: onSaveAsNote,
                isAccent: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Center(
          child: TextButton.icon(
            onPressed: onNewAnalysis,
            icon: Icon(Icons.refresh_rounded, color: cs.onSurface.withValues(alpha: 0.5), size: 18),
            label: Text(
              'New Analysis',
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.5),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        fontSize: 11,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isAccent;
  final bool isCopied;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isAccent,
    this.isCopied = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nonAccentBg = isDark ? const Color(0xFF252535) : const Color(0xFFEEEEF5);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          gradient: isAccent
              ? const LinearGradient(
                  colors: [Color(0xFF9810FA), Color(0xFFDB2777)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isAccent ? null : nonAccentBg,
          borderRadius: BorderRadius.circular(12),
          border: isAccent ? null : Border.all(color: cs.onSurface.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isCopied ? const Color(0xFF22C55E) : (isAccent ? Colors.white : cs.onSurface),
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isCopied ? const Color(0xFF22C55E) : (isAccent ? Colors.white : cs.onSurface),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
