import 'package:flutter/material.dart';
import 'package:nota/l10n/app_localizations.dart';
import '../../model/note_model.dart';

/// Dropdown for selecting a saved note to analyze.
class AiNoteSelector extends StatelessWidget {
  final List<NoteModel> notes;
  final NoteModel? selected;
  final ValueChanged<NoteModel?> onChanged;

  const AiNoteSelector({
    super.key,
    required this.notes,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF1A1A2E) : Theme.of(context).cardColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.onSurface.withValues(alpha: 0.07)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<NoteModel>(
          value: selected,
          isExpanded: true,
          dropdownColor: bgColor,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: cs.onSurface.withValues(alpha: 0.5)),
          hint: Row(
            children: [
              Icon(Icons.description_outlined,
                  color: cs.onSurface.withValues(alpha: 0.3), size: 18),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.selectNote,
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.3),
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          items: notes.map((note) {
            return DropdownMenuItem<NoteModel>(
              value: note,
              child: Text(
                note.title.isNotEmpty ? note.title : 'Untitled Note',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
