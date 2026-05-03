
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class RichTextToolbar extends StatefulWidget {
  final QuillController controller;

  const RichTextToolbar({super.key, required this.controller});

  @override
  State<RichTextToolbar> createState() => _RichTextToolbarState();
}

class _RichTextToolbarState extends State<RichTextToolbar> {
  Future<void> _pickImage() async {
    final status = await Permission.photos.request();
    if (status.isGranted || status.isLimited) {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final index = widget.controller.selection.baseOffset;
        final length = widget.controller.selection.extentOffset - index;
        widget.controller.replaceText(index, length, BlockEmbed.image(image.path), null);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gallery permission is required.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      color: const Color(0xFF111116),
      child: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final style = widget.controller.getSelectionStyle();
          final isBold = style.containsKey(Attribute.bold.key);
          final isItalic = style.containsKey(Attribute.italic.key);
          final isUnderline = style.containsKey(Attribute.underline.key);
          final isH1 = style.attributes[Attribute.header.key]?.value == 1;
          final isH2 = style.attributes[Attribute.header.key]?.value == 2;
          final isBulletedList = style.attributes[Attribute.list.key]?.value == 'bullet';
          final isNumberedList = style.attributes[Attribute.list.key]?.value == 'ordered';
          final isCheckbox = style.attributes[Attribute.list.key]?.value == 'checked';

          void toggleAttribute(Attribute attribute, bool isActive) {
            widget.controller.formatSelection(isActive ? Attribute.clone(attribute, null) : attribute);
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildToolbarIcon(
                  icon: Icons.format_bold,
                  isActive: isBold,
                  onTap: () => toggleAttribute(Attribute.bold, isBold),
                ),
                _buildToolbarIcon(
                  icon: Icons.format_italic,
                  isActive: isItalic,
                  onTap: () => toggleAttribute(Attribute.italic, isItalic),
                ),
                _buildToolbarIcon(
                  icon: Icons.format_underlined,
                  isActive: isUnderline,
                  onTap: () => toggleAttribute(Attribute.underline, isUnderline),
                ),
                _buildToolbarIconText(
                  text: 'H1',
                  isActive: isH1,
                  onTap: () => toggleAttribute(Attribute.h1, isH1),
                ),
                _buildToolbarIconText(
                  text: 'H2',
                  isActive: isH2,
                  onTap: () => toggleAttribute(Attribute.h2, isH2),
                ),
                _buildToolbarIcon(
                  icon: Icons.format_list_bulleted,
                  isActive: isBulletedList,
                  onTap: () => toggleAttribute(Attribute.ul, isBulletedList),
                ),
                _buildToolbarIcon(
                  icon: Icons.format_list_numbered,
                  isActive: isNumberedList,
                  onTap: () => toggleAttribute(Attribute.ol, isNumberedList),
                ),
                _buildToolbarIcon(
                  icon: Icons.check_box_outlined,
                  isActive: isCheckbox,
                  onTap: () => toggleAttribute(Attribute.unchecked, isCheckbox),
                ),
                _buildToolbarIcon(
                  icon: Icons.image_outlined,
                  isActive: false,
                  onTap: _pickImage,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolbarIcon({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withAlpha(51) : Colors.white.withAlpha(13),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isActive ? Colors.white : Colors.white54, size: 20),
        ),
      ),
    );
  }

  Widget _buildToolbarIconText({
    required String text,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withAlpha(51) : Colors.white.withAlpha(13),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white54,
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
