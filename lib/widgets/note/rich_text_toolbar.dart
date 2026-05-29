import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class RichTextToolbar extends StatelessWidget {
  final quill.QuillController controller;

  const RichTextToolbar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final style = controller.getSelectionStyle();
          final isBold = style.containsKey('bold');
          final isItalic = style.containsKey('italic');
          final isUnderline = style.containsKey('underline');
          final isStrike = style.containsKey('strike');
          final isH1 = style.attributes['header']?.value == 1;
          final isH2 = style.attributes['header']?.value == 2;
          final isBullet = style.attributes['list']?.value == 'bullet';
          final isOrdered = style.attributes['list']?.value == 'ordered';

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
                  onTap: () => _toggleFormat(quill.Attribute.underline, isUnderline),
                ),
                _ToolbarButton(
                  icon: Icons.format_strikethrough,
                  isActive: isStrike,
                  onTap: () => _toggleFormat(quill.Attribute.strikeThrough, isStrike),
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
                _Divider(),
                _ToolbarButton(
                  icon: Icons.format_clear,
                  isActive: false,
                  onTap: () {
                    final selection = controller.selection;
                    if (!selection.isCollapsed) {
                      controller.formatSelection(quill.Attribute.clone(quill.Attribute.bold, null));
                      controller.formatSelection(quill.Attribute.clone(quill.Attribute.italic, null));
                      controller.formatSelection(quill.Attribute.clone(quill.Attribute.underline, null));
                      controller.formatSelection(quill.Attribute.clone(quill.Attribute.strikeThrough, null));
                      controller.formatSelection(quill.Attribute.clone(quill.Attribute.h1, null));
                      controller.formatSelection(quill.Attribute.clone(quill.Attribute.h2, null));
                      controller.formatSelection(quill.Attribute.clone(quill.Attribute.ul, null));
                      controller.formatSelection(quill.Attribute.clone(quill.Attribute.ol, null));
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _toggleFormat(quill.Attribute attribute, bool isApplied) {
    controller.formatSelection(isApplied ? quill.Attribute.clone(attribute, null) : attribute);
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

  const _ToolbarButton({required this.icon, required this.isActive, required this.onTap});

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
            color: isActive ? const Color(0xFF383848) : const Color(0xFF2A2A35),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isActive ? cs.onSurface : cs.onSurface.withValues(alpha: 0.6),
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

  const _ToolbarTextButton({required this.text, required this.isActive, required this.onTap});

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
            color: isActive ? const Color(0xFF383848) : const Color(0xFF2A2A35),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isActive ? cs.onSurface : cs.onSurface.withValues(alpha: 0.6),
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
