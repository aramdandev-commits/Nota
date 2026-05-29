import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../controllers/note_formatting_controller.dart';

class RichTextToolbar extends StatelessWidget {
  final quill.QuillController controller;
  final NoteFormattingController formattingController;

  const RichTextToolbar({
    super.key,
    required this.controller,
    required this.formattingController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final toolbarBgColor =
        isDark ? const Color(0xFF111116) : const Color(0xFFF0F0F5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: toolbarBgColor,
        border: Border(
          top: BorderSide(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: ListenableBuilder(
        listenable: Listenable.merge([controller, formattingController]),
        builder: (context, _) {
          final style = controller.getSelectionStyle();
          final isBold = formattingController.isBold;
          final isItalic = formattingController.isItalic;
          final isUnderline = formattingController.isUnderline;
          final isStrike = style.containsKey('strike');
          final isH1 = formattingController.isH1;
          final isH2 = formattingController.isH2;
          final isBullet = formattingController.isBulletedList;
          final isOrdered = formattingController.isNumberedList;
          final isCheckbox = formattingController.isCheckbox;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ToolbarButton(
                  icon: Icons.format_bold,
                  isActive: isBold,
                  onTap: () => _toggleFormat(quill.Attribute.bold, isBold),
                ),
                _ToolbarButton(
                  icon: Icons.format_italic,
                  isActive: isItalic,
                  onTap: () => _toggleFormat(quill.Attribute.italic, isItalic),
                ),
                _ToolbarButton(
                  icon: Icons.format_underline,
                  isActive: isUnderline,
                  onTap: () =>
                      _toggleFormat(quill.Attribute.underline, isUnderline),
                ),
                _ToolbarButton(
                  icon: Icons.format_strikethrough,
                  isActive: isStrike,
                  onTap: () =>
                      _toggleFormat(quill.Attribute.strikeThrough, isStrike),
                ),
                _Divider(),
                _ToolbarTextButton(
                  text: 'H1',
                  isActive: isH1,
                  onTap: () => _toggleFormat(quill.Attribute.h1, isH1),
                ),
                _ToolbarTextButton(
                  text: 'H2',
                  isActive: isH2,
                  onTap: () => _toggleFormat(quill.Attribute.h2, isH2),
                ),
                _Divider(),
                _ToolbarButton(
                  icon: Icons.format_list_bulleted,
                  isActive: isBullet,
                  onTap: () => _toggleFormat(quill.Attribute.ul, isBullet),
                ),
                _ToolbarButton(
                  icon: Icons.format_list_numbered,
                  isActive: isOrdered,
                  onTap: () => _toggleFormat(quill.Attribute.ol, isOrdered),
                ),
                _ToolbarButton(
                  icon: Icons.check_box_outlined,
                  isActive: isCheckbox,
                  onTap: () =>
                      _toggleFormat(quill.Attribute.unchecked, isCheckbox),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _toggleFormat(quill.Attribute attribute, bool isApplied) {
    controller.formatSelection(
        isApplied ? quill.Attribute.clone(attribute, null) : attribute);
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolbarButton(
      {required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive
                ? cs.primary.withValues(alpha: 0.15)
                : cs.onSurface.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isActive ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _ToolbarTextButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolbarTextButton(
      {required this.text, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive
                ? cs.primary.withValues(alpha: 0.15)
                : cs.onSurface.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color:
                    isActive ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
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

extension AttributeUnsetExt on quill.Attribute {
  quill.Attribute get unset => quill.Attribute.clone(this, null);
}
