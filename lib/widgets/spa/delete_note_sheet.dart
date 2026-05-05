import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/note_provider.dart';

class DeleteNoteSheet extends StatelessWidget {
  final String noteId;

  const DeleteNoteSheet({super.key, required this.noteId});

  @override
  Widget build(BuildContext context) {
    const Color sheetColor = Color(0xFF1E1E2A);
    const Color itemColor = Color(0xFF2A2A38);
    const Color deleteRed = Color(0xFFD32F2F);
    const Color iconBgRed = Color(0xFF3A1E24);
    const Color textColor = Colors.white;
    const Color subtitleColor = Colors.grey;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: sheetColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            decoration: const BoxDecoration(
              color: iconBgRed,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_outline,
                color: Colors.redAccent, size: 32),
          ),
          const SizedBox(height: 24),

          // Titles
          const Text(
            'Delete this note?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This note will be moved to trash.',
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
                Provider.of<NoteProvider>(context, listen: false)
                    .deleteNote(noteId);

                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                    color: textColor,
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
              child: const Text(
                'Cancel',
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
