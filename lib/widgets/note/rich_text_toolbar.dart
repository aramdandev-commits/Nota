import 'package:flutter/material.dart';
import 'package:nota/helper/app_theme.dart';

class RichTextToolbar extends StatefulWidget {
  // We keep the QuillController dynamic to avoid a hard dependency on flutter_quill
  final dynamic controller;

  const RichTextToolbar({super.key, required this.controller});

  @override
  State<RichTextToolbar> createState() => _RichTextToolbarState();
}

class _RichTextToolbarState extends State<RichTextToolbar> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final toolbarBg = isDark ? const Color(0xFF111116) : const Color(0xFFF0F0F5);

    return Container(
      height: 60,
      width: double.infinity,
      color: toolbarBg,
      child: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          // Access quill attributes dynamically
          final style = widget.controller.getSelectionStyle();
          final isBold      = style.containsKey('bold');
          final isItalic    = style.containsKey('italic');
          final isUnderline = style.containsKey('underline');
          final isH1 = style.attributes['header']?.value == 1;
          final isH2 = style.attributes['header']?.value == 2;
          final isBulletedList = style.attributes['list']?.value == 'bullet';
          final isNumberedList = style.attributes['list']?.value == 'ordered';
          final isCheckbox     = style.attributes['list']?.value == 'checked';

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildToolbarIcon(context: context, icon: Icons.format_bold,          isActive: isBold),
                _buildToolbarIcon(context: context, icon: Icons.format_italic,         isActive: isItalic),
                _buildToolbarIcon(context: context, icon: Icons.format_underlined,     isActive: isUnderline),
                _buildToolbarText(context: context, text: 'H1',                        isActive: isH1),
                _buildToolbarText(context: context, text: 'H2',                        isActive: isH2),
                _buildToolbarIcon(context: context, icon: Icons.format_list_bulleted,  isActive: isBulletedList),
                _buildToolbarIcon(context: context, icon: Icons.format_list_numbered,  isActive: isNumberedList),
                _buildToolbarIcon(context: context, icon: Icons.check_box_outlined,    isActive: isCheckbox),
                _buildToolbarIcon(context: context, icon: Icons.image_outlined,        isActive: false),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolbarIcon({
    required BuildContext context,
    required IconData icon,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isActive
                ? cs.onSurface.withValues(alpha: 0.2)
                : cs.onSurface.withValues(alpha: 0.07),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? cs.onSurface : cs.onSurface.withValues(alpha: 0.54),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarText({
    required BuildContext context,
    required String text,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isActive
                ? cs.onSurface.withValues(alpha: 0.2)
                : cs.onSurface.withValues(alpha: 0.07),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isActive ? cs.onSurface : cs.onSurface.withValues(alpha: 0.54),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
