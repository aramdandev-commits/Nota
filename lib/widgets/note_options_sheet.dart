import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/note_provider.dart';

import 'delete_note_sheet.dart';
import 'note_info_sheet.dart';
import 'move_to_space_sheet.dart';
import 'share_note_sheet.dart';

class NoteOptionsSheet extends StatelessWidget {
  final String noteId;

  const NoteOptionsSheet({super.key, required this.noteId});

  @override
  Widget build(BuildContext context) {
    const Color sheetColor = Color(0xFF1E1E2A);
    const Color itemColor = Color(0xFF2A2A38);
    const Color destructiveColor = Color(0xFF3A1E24);
    const Color iconAccentColor = Color(0xFF3D7AF9);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: sheetColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Options',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: itemColor, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.grey, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Share Button
          _buildOptionItem(
            icon: Icons.share_outlined,
            iconColor: iconAccentColor,
            title: 'Share',
            bgColor: itemColor,
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const ShareNoteSheet(),
              );
            },
          ),
          const SizedBox(height: 10),

          // Move to Space Button
          _buildOptionItem(
            icon: Icons.folder_outlined,
            iconColor: Colors.tealAccent,
            title: 'Move to Space',
            subtitle: 'Research Space',
            showArrow: true,
            bgColor: itemColor,
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const MoveToSpaceSheet(),
              );
            },
          ),
          const SizedBox(height: 10),

          // Note Info Button
          _buildOptionItem(
            icon: Icons.info_outline_rounded,
            iconColor: Colors.cyanAccent,
            title: 'Note Info',
            showArrow: true,
            bgColor: itemColor,
            onTap: () {
              final note = Provider.of<NoteProvider>(context, listen: false)
                  .notes
                  .firstWhere((n) => n.id == noteId);

              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => NoteInfoSheet(
                  createdAt: note.updatedAt,
                  modifiedAt: note.updatedAt,
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Delete Button
          _buildOptionItem(
            icon: Icons.delete_outline_rounded,
            iconColor: Colors.redAccent,
            title: 'Delete Note',
            titleColor: Colors.redAccent,
            bgColor: destructiveColor,
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => DeleteNoteSheet(noteId: noteId),
              );
            },
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    Color titleColor = Colors.white,
    String? subtitle,
    bool showArrow = false,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: titleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ],
              ),
            ),
            if (showArrow)
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
