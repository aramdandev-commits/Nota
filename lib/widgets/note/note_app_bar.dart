import 'package:flutter/material.dart';
import 'package:nota/l10n/app_localizations.dart';
import 'package:nota/widgets/note/ai_summary_generated_sheet.dart';
import 'package:nota/widgets/note/note_options_sheet.dart';
import 'package:nota/widgets/note/share_note_sheet.dart';

class NoteAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String saveState;
  final String noteId;

  const NoteAppBar({
    super.key,
    required this.saveState,
    required this.noteId,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Back Button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back_ios_new,
                      color: Colors.blueAccent, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!.myNotes,
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Center: Saved status
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                saveState,
                key: ValueKey<String>(saveState),
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.38),
                  fontSize: 14,
                ),
              ),
            ),

            // Right: Action buttons
            Row(
              children: [
                // Avatars
                SizedBox(
                  width: 50,
                  height: 32,
                  child: Stack(
                    children: [
                      Positioned(
                        right: 18,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.pinkAccent,
                          child: const Text(
                            'ME',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.lightBlue,
                          child: const Text(
                            'SK',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // AI Summary button
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => AiSummaryGeneratedSheet(noteId: noteId),
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: Colors.purpleAccent, size: 20),
                  ),
                ),
                const SizedBox(width: 8),



                // More options button
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => NoteOptionsSheet(noteId: noteId),
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.onSurface.withValues(alpha: 0.07),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.more_horiz,
                        color: cs.onSurface.withValues(alpha: 0.7), size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
