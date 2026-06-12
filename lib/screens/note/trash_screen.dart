import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nota/l10n/app_localizations.dart';
import '../../controllers/note_provider.dart';
import '../../model/note_model.dart';
import 'package:intl/intl.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NoteProvider>().fetchTrashNotes();
    });
  }

  void _showDeleteDialog(BuildContext context, NoteModel note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Delete Permanently?',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          'This action cannot be undone. Are you sure you want to permanently delete this note?',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<NoteProvider>().permanentlyDeleteNote(note.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note permanently deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        final notes = provider.trashNotes;

        if (notes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline,
                    size: 64, color: cs.onSurface.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)?.trashIsEmpty ?? 'Trash is empty',
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.7),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return _TrashNoteCard(
              note: note,
              onRestore: () {
                context.read<NoteProvider>().restoreNote(note.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note restored successfully')),
                );
              },
              onDelete: () => _showDeleteDialog(context, note),
            );
          },
        );
      },
    );
  }
}

class _TrashNoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _TrashNoteCard({
    required this.note,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151821) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.onSurface.withOpacity(0.05),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    note.title.isNotEmpty ? note.title : 'Untitled Note',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  dateFormat.format(note.updatedAt),
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (note.preview != null && note.preview!.isNotEmpty)
              Text(
                note.preview!,
                style: TextStyle(
                  color: cs.onSurface.withOpacity(0.6),
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onRestore,
                  icon: const Icon(Icons.restore, color: Colors.teal, size: 18),
                  label: const Text(
                    'Restore',
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_forever, color: Colors.red, size: 18),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
