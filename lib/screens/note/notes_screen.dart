import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nota/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../controllers/note_provider.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF3377FF), size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.allNotes,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          final notes = noteProvider.notes;

          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined,
                      size: 80, color: cs.onSurface.withValues(alpha: 0.15)),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noNotesFoundYet,
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.54),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.noteCreationGuide,
                    style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.38),
                        fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20.0),
            itemCount: notes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final note = notes[index];

              String previewText = AppLocalizations.of(context)!.noContent;
              try {
                if (note.content.isNotEmpty) {
                  final List<dynamic> ops = jsonDecode(note.content);
                  previewText = ops
                      .map((op) => op['insert']?.toString() ?? '')
                      .join('')
                      .replaceAll('\n', ' ')
                      .trim();
                  if (previewText.length > 80) {
                    previewText = '${previewText.substring(0, 80)}...';
                  }
                }
              } catch (e) {
                previewText = note.content;
                if (previewText.length > 80) {
                  previewText = '${previewText.substring(0, 80)}...';
                }
              }

              return GestureDetector(
                onTap: () => context.push('/new-note', extra: note.id),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: cs.onSurface.withValues(alpha: 0.06)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title.isNotEmpty
                            ? note.title
                            : AppLocalizations.of(context)!.untitledNote,
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        previewText.isNotEmpty
                            ? previewText
                            : AppLocalizations.of(context)!.emptyNote,
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.54),
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Updated: ${note.updatedAt.toString().substring(0, 10)}',
                            style: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.38),
                              fontSize: 12,
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: cs.onSurface.withValues(alpha: 0.25),
                              size: 18),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: GestureDetector(
        onTap: () => context.push('/new-note'),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFE520A4), Color(0xFF7A36DC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE520A4).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
