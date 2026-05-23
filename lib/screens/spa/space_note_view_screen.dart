import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../model/space_note_model.dart';

class SpaceNoteViewScreen extends StatefulWidget {
  final SpaceNoteModel note;

  const SpaceNoteViewScreen({Key? key, required this.note}) : super(key: key);

  @override
  State<SpaceNoteViewScreen> createState() => _SpaceNoteViewScreenState();
}

class _SpaceNoteViewScreenState extends State<SpaceNoteViewScreen> {
  late final quill.QuillController _quillController;

  @override
  void initState() {
    super.initState();
    quill.Document doc;
    try {
      // Try parsing as Quill Delta JSON first
      final decoded = jsonDecode(widget.note.content);
      doc = quill.Document.fromJson(decoded);
    } catch (_) {
      // Plain text fallback
      doc = quill.Document()..insert(0, widget.note.content);
    }
    _quillController = quill.QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final h = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
            ? 12
            : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final note = widget.note;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios_new,
                        color: cs.onSurface, size: 20),
                  ),
                  const Spacer(),
                  // Favorite star
                  Icon(
                    note.isFavorite ? Icons.star : Icons.star_border,
                    color: note.isFavorite
                        ? const Color(0xFFFBBF24)
                        : cs.onSurface.withValues(alpha: 0.4),
                    size: 22,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.more_vert,
                      color: cs.onSurface.withValues(alpha: 0.4), size: 22),
                ],
              ),
            ),

            // ── Content ──────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      note.title,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Meta: author + date
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: const Color(0xFF6B58FF),
                          child: Text(
                            note.authorName.isNotEmpty
                                ? note.authorName[0].toUpperCase()
                                : 'A',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(note.authorName,
                            style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.6),
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        Icon(Icons.circle,
                            size: 4, color: cs.onSurface.withValues(alpha: 0.4)),
                        const SizedBox(width: 8),
                        Text(_formatDate(note.createdAt),
                            style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.4), fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tags
                    if (note.tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children:
                            note.tags.map((tag) => _TagChip(tag: tag)).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    Divider(color: cs.onSurface.withValues(alpha: 0.1)),
                    const SizedBox(height: 20),

                    // Rich text body
                    DefaultTextStyle(
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.8),
                        fontSize: 16,
                        height: 1.7,
                      ),
                      child: quill.QuillEditor.basic(
                        controller: _quillController,
                        // readOnly: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF6B58FF).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: const Color(0xFF6B58FF).withValues(alpha: 0.3)),
        ),
        child: Text(
          '#$tag',
          style: const TextStyle(
              color: Color(0xFF6B58FF),
              fontSize: 12,
              fontWeight: FontWeight.w500),
        ),
      );
}
