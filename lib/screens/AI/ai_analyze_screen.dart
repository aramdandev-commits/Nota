import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nota/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../controllers/ai_analyze_provider.dart';
import '../../controllers/note_provider.dart';
import '../../model/note_model.dart';
import '../../widgets/home/bottom_navigation.dart';
import '../../widgets/ai/ai_mode_toggle.dart';
import '../../widgets/ai/ai_text_input.dart';
import '../../widgets/ai/ai_note_selector.dart';
import '../../widgets/ai/ai_generate_button.dart';
import '../../widgets/ai/ai_result_card.dart';

class AIAnalyzeScreen extends StatefulWidget {
  const AIAnalyzeScreen({super.key});

  @override
  State<AIAnalyzeScreen> createState() => _AIAnalyzeScreenState();
}

class _AIAnalyzeScreenState extends State<AIAnalyzeScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _onGenerate(AiAnalyzeProvider provider) async {
    if (provider.mode == AiAnalyzeMode.pasteText) {
      await provider.analyzeText(_textController.text);
    } else {
      await provider.analyzeNote();
    }
  }

  void _onSaveAsNote(BuildContext context, AiAnalyzeProvider provider) {
    final result = provider.result;
    if (result == null) return;

    // Build plain text content and encode it as a Quill Delta JSON,
    // which is exactly what NewNoteScreen stores and reads.
    final plainText =
        'Summary:\n${result.summary}\n\nKey Points:\n${result.keyPoints.map((p) => '• $p').join('\n')}\n';

    final List<dynamic> deltaPayload = [
      {'insert': plainText}
    ];

    final note = NoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'AI Analysis',
      content: deltaPayload,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save directly via NoteProvider, then open the note in the editor.
    context.read<NoteProvider>().saveNote(note);
    context.push('/new-note', extra: note.id);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AiAnalyzeProvider(),
      child: Consumer2<AiAnalyzeProvider, NoteProvider>(
        builder: (context, aiProvider, noteProvider, _) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ───────────────────────────────────────────
                    _AiHeader(),
                    const SizedBox(height: 24),

                    if (!aiProvider.hasResult) ...[
                      // ── Input area ───────────────────────────────────
                      AiModeToggle(
                        selected: aiProvider.mode,
                        onChanged: aiProvider.setMode,
                      ),
                      const SizedBox(height: 20),

                      if (aiProvider.mode == AiAnalyzeMode.pasteText)
                        AiTextInput(controller: _textController)
                      else
                        AiNoteSelector(
                          notes: noteProvider.notes,
                          selected: aiProvider.selectedNote,
                          onChanged: (note) {
                            if (note != null) aiProvider.selectNote(note);
                          },
                        ),
                      const SizedBox(height: 24),

                      AiGenerateButton(
                        isLoading: aiProvider.status == AiAnalyzeStatus.loading,
                        onTap: () => _onGenerate(aiProvider),
                      ),

                      // ── Error state ──────────────────────────────────
                      if (aiProvider.status == AiAnalyzeStatus.error) ...[
                        const SizedBox(height: 16),
                        _ErrorBanner(message: aiProvider.errorMessage),
                      ],
                    ] else ...[
                      // ── Result area ──────────────────────────────────
                      AiResultCard(
                        result: aiProvider.result!,
                        copied: aiProvider.copied,
                        onCopy: aiProvider.markCopied,
                        onSaveAsNote: () => _onSaveAsNote(context, aiProvider),
                        onNewAnalysis: () {
                          aiProvider.reset();
                          _textController.clear();
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            bottomNavigationBar: const BottomNavigation(selectedIndex: 2),
          );
        },
      ),
    );
  }
}

// ── Private widgets ──────────────────────────────────────────────────────────

class _AiHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9810FA), Color(0xFFDB2777)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.aiAnalyzer,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.aiAnalyzerDescription,
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.5),
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String? message;
  const _ErrorBanner({this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B0D0D) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
      ),
      child: Text(
        message ?? 'Something went wrong. Please try again.',
        style: const TextStyle(
          color: Color(0xFFEF4444),
          fontSize: 13,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
