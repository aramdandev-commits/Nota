import 'package:flutter/material.dart';
import 'package:nota/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../controllers/note_provider.dart';

class DeleteNoteSheet extends StatelessWidget {
  final String noteId;
  final bool isTrash;
  final VoidCallback? onDeleted;

  const DeleteNoteSheet({super.key, required this.noteId, this.isTrash = false, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color sheetColor = isDark
        ? const Color(0xFF1E1E2A)
        : Theme.of(context).scaffoldBackgroundColor;
    final Color itemColor =
        isDark ? const Color(0xFF2A2A38) : Theme.of(context).cardColor;
    const Color deleteRed = Color(0xFFD32F2F);
    final Color iconBgRed =
        isDark ? const Color(0xFF3A1E24) : const Color(0xFFFEF2F2);
    final Color textColor = cs.onSurface;
    final Color subtitleColor = cs.onSurface.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: sheetColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconBgRed,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_outline,
                color: Colors.redAccent, size: 32),
          ),
          const SizedBox(height: 24),

          // Titles
          Text(
            AppLocalizations.of(context)!.deleteThisNote,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isTrash
                ? AppLocalizations.of(context)!.thisCannotBe
                : AppLocalizations.of(context)!.moveToTrash,
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 32),

          // Delete Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: deleteRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () {
                if (isTrash) {
                  Provider.of<NoteProvider>(context, listen: false)
                      .permanentlyDeleteNote(noteId);
                } else {
                  Provider.of<NoteProvider>(context, listen: false)
                      .moveNoteToTrash(noteId);
                }

                if (onDeleted != null) {
                  onDeleted!();
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text(
                AppLocalizations.of(context)!.delete,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: itemColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(
                    color: subtitleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
