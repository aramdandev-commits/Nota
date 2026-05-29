import 'package:flutter/material.dart';
import 'package:nota/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:nota/helper/app_theme.dart';
import '../../controllers/note_provider.dart';

import '../spa/delete_note_sheet.dart';
import 'note_info_sheet.dart';
import '../spa/move_to_space_sheet.dart';
import 'share_note_sheet.dart';

class NoteOptionsSheet extends StatelessWidget {
  final String noteId;

  const NoteOptionsSheet({super.key, required this.noteId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sheetBg = AppTheme.sheetColor(context);
    final itemBg = AppTheme.itemColor(context);
    const Color destructiveColor = Color(0xFF3A1E24);
    const Color iconAccentColor = Color(0xFF3D7AF9);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.options,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration:
                      BoxDecoration(color: itemBg, shape: BoxShape.circle),
                  child: Icon(Icons.close,
                      color: cs.onSurface.withValues(alpha: 0.5), size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildOptionItem(
            context: context,
            icon: Icons.share_outlined,
            iconColor: iconAccentColor,
            title: AppLocalizations.of(context)!.share,
            bgColor: itemBg,
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
          _buildOptionItem(
            context: context,
            icon: Icons.folder_outlined,
            iconColor: Colors.tealAccent,
            title: AppLocalizations.of(context)!.moveToSpaces,
            subtitle: AppLocalizations.of(context)!.researchSpace,
            showArrow: true,
            bgColor: itemBg,
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
          _buildOptionItem(
            context: context,
            icon: Icons.info_outline_rounded,
            iconColor: Colors.cyanAccent,
            title: AppLocalizations.of(context)!.noteInfo,
            showArrow: true,
            bgColor: itemBg,
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
          _buildOptionItem(
            context: context,
            icon: Icons.delete_outline_rounded,
            iconColor: Colors.redAccent,
            title: AppLocalizations.of(context)!.deleteNote,
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
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? titleColor,
    String? subtitle,
    bool showArrow = false,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final effectiveTitleColor = titleColor ?? cs.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: effectiveTitleColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow)
              Icon(Icons.chevron_right_rounded,
                  color: cs.onSurface.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
