import 'package:flutter/material.dart';
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<NoteModel>(
          value: selected,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1A2E),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF8E9099)),
          hint: Row(
            children: const [
              Icon(Icons.description_outlined,
                  color: Color(0xFF4A4A6A), size: 18),
              SizedBox(width: 10),
              Text(
                'Select a note to analyze',
                style: TextStyle(
                  color: Color(0xFF4A4A6A),
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
                style: const TextStyle(
                  color: Colors.white,
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
