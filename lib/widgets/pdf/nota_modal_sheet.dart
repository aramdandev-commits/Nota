import 'package:flutter/material.dart';

/// A reusable modal bottom sheet for Nota.
///
/// Usage:
/// ```dart
/// NotaModalSheet.show(
///   context: context,
///   icon: Icons.picture_as_pdf_rounded,
///   title: 'Import PDF',
///   subtitle: 'Upload a PDF file to convert into a note',
///   tabs: ['From Device', 'From Cloud'],
///   tabIcons: [Icons.storage_rounded, Icons.cloud_outlined],
///   body: YourContentWidget(),
///   cancelLabel: 'Cancel',
/// );
/// ```
class NotaModalSheet extends StatefulWidget {
  const NotaModalSheet({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.body,
    this.tabs,
    this.tabIcons,
    this.onTabChanged,
    this.cancelLabel = 'Cancel',
    this.onCancel,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  /// Optional tab labels. If null, no tab bar is shown.
  final List<String>? tabs;

  /// Optional icons for each tab (same length as [tabs]).
  final List<IconData>? tabIcons;

  /// Called when the selected tab index changes.
  final ValueChanged<int>? onTabChanged;

  /// The main content below the tab bar.
  final Widget body;

  final String cancelLabel;

  /// Called when cancel is tapped. Defaults to Navigator.pop.
  final VoidCallback? onCancel;

  /// Convenience method to show the sheet.
  static Future<T?> show<T>({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget body,
    List<String>? tabs,
    List<IconData>? tabIcons,
    ValueChanged<int>? onTabChanged,
    String cancelLabel = 'Cancel',
    VoidCallback? onCancel,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotaModalSheet(
        icon: icon,
        title: title,
        subtitle: subtitle,
        body: body,
        tabs: tabs,
        tabIcons: tabIcons,
        onTabChanged: onTabChanged,
        cancelLabel: cancelLabel,
        onCancel: onCancel,
      ),
    );
  }

  @override
  State<NotaModalSheet> createState() => _NotaModalSheetState();
}

class _NotaModalSheetState extends State<NotaModalSheet> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final hasTabs = widget.tabs != null && widget.tabs!.isNotEmpty;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color sheetBg = isDark ? const Color(0xFF12121C) : Theme.of(context).scaffoldBackgroundColor;
    final Color surfaceColor = isDark ? const Color(0xFF1E1E2A) : Theme.of(context).cardColor;
    final Color borderColor = isDark ? const Color(0xFF2A2A38) : cs.onSurface.withValues(alpha: 0.1);
    final Color textPrimary = cs.onSurface;
    final Color textMuted = cs.onSurface.withValues(alpha: 0.6);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: textMuted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Icon badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7A36DC), Color(0xFFE520A4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.file_open_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 17,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Close button
                GestureDetector(
                  onTap: widget.onCancel ?? () => Navigator.of(context).pop(),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: textMuted,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (hasTabs) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _TabBar(
                tabs: widget.tabs!,
                icons: widget.tabIcons,
                selectedIndex: _selectedTab,
                onTap: (i) {
                  setState(() => _selectedTab = i);
                  widget.onTabChanged?.call(i);
                },
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Body content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: widget.body,
          ),

          const SizedBox(height: 16),

          // Cancel button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _CancelButton(
              label: widget.cancelLabel,
              onTap: widget.onCancel ?? () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Internal widgets ──────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
    this.icons,
  });

  final List<String> tabs;
  final List<IconData>? icons;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color surfaceColor = isDark ? const Color(0xFF1E1E2A) : Theme.of(context).cardColor;
    final Color borderColor = isDark ? const Color(0xFF2A2A38) : cs.onSurface.withValues(alpha: 0.1);
    final Color textMuted = cs.onSurface.withValues(alpha: 0.6);

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: selected ? const LinearGradient(colors: [Color(0xFF7A36DC), Color(0xFFE520A4)]) : null,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icons != null && i < icons!.length) ...[
                      Icon(
                        icons![i],
                        size: 15,
                        color: selected ? Colors.white : textMuted,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      tabs[i],
                      style: TextStyle(
                        color: selected ? Colors.white : textMuted,
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color surfaceColor = isDark ? const Color(0xFF1E1E2A) : Theme.of(context).cardColor;
    final Color borderColor = isDark ? const Color(0xFF2A2A38) : cs.onSurface.withValues(alpha: 0.1);
    final Color textMuted = cs.onSurface.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: textMuted,
            fontSize: 15,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
