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

class AIAnalyzeScreen extends StatefulWidget {
  const AIAnalyzeScreen({super.key});

  @override
  State<AIAnalyzeScreen> createState() => _AIAnalyzeScreenState();
}

class _AIAnalyzeScreenState extends State<AIAnalyzeScreen> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NoteProvider>().resetSummaryState();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _onGenerate(BuildContext context, AiAnalyzeProvider provider, NoteProvider noteProvider) async {
    if (provider.mode == AiAnalyzeMode.pasteText) {
      final text = _textController.text.trim();
      if (text.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter some text to summarize'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      try {
        await noteProvider.summarizeText(text);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to request summary: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (provider.selectedNote != null) {
        try {
          await noteProvider.generateSummary(provider.selectedNote!.id);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to request summary: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
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

                    if (noteProvider.isSummarizing || noteProvider.isSummarizeSuccess) ...[
                      // ── Note Analysis WebSocket State ──────────────────
                      const SizedBox(height: 40),
                      if (noteProvider.isSummarizing)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(color: Color(0xFF7A36DC)),
                              const SizedBox(height: 16),
                              Text(
                                'Summary in progress',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Summarized successfully!',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your note has been updated with the summary.',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).cardColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  noteProvider.resetSummaryState();
                                },
                                icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.onSurface, size: 18),
                                label: Text('New Analysis',
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                    ] else ...[
                      // ── Input area ───────────────────────────────────
                      AiModeToggle(
                        selected: aiProvider.mode,
                        onChanged: (mode) {
                          aiProvider.setMode(mode);
                          noteProvider.resetSummaryState();
                        },
                      ),
                      const SizedBox(height: 20),

                      if (aiProvider.mode == AiAnalyzeMode.pasteText)
                        AiTextInput(controller: _textController)
                      else
                        AiNoteSelector(
                          notes: noteProvider.notes,
                          selected: aiProvider.selectedNote,
                          onChanged: (note) {
                            if (note != null) {
                              aiProvider.selectNote(note);
                              noteProvider.resetSummaryState();
                            }
                          },
                        ),
                      const SizedBox(height: 24),

                      AiGenerateButton(
                        isLoading: noteProvider.isSummarizing,
                        onTap: () => _onGenerate(context, aiProvider, noteProvider),
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

