import 'package:flutter/material.dart';
import 'package:nota/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../controllers/note_provider.dart';

enum SummaryState { initial, loading, success }

class AiSummaryGeneratedSheet extends StatefulWidget {
  final String noteId;

  const AiSummaryGeneratedSheet({super.key, required this.noteId});

  @override
  State<AiSummaryGeneratedSheet> createState() => _AiSummaryGeneratedSheetState();
}

class _AiSummaryGeneratedSheetState extends State<AiSummaryGeneratedSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NoteProvider>(context, listen: false).resetSummaryState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color sheetColor = isDark
        ? const Color(0xFF1E1E2A)
        : Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = cs.onSurface;
    final Color subtitleColor = cs.onSurface.withValues(alpha: 0.6);
    const Color buttonColorStart = Color(0xFFE520A4);
    const Color buttonColorEnd = Color(0xFF7A36DC);
    final Color closeButtonColor =
        isDark ? const Color(0xFF2A2A38) : Theme.of(context).cardColor;

    final noteProvider = context.watch<NoteProvider>();

    final SummaryState currentState;
    if (noteProvider.isSummarizing) {
      currentState = SummaryState.loading;
    } else if (noteProvider.isSummarizeSuccess) {
      currentState = SummaryState.success;
    } else {
      currentState = SummaryState.initial;
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.45,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [buttonColorStart, buttonColorEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.aiSummary,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppLocalizations.of(context)!.aiCard,
                          style: TextStyle(fontSize: 13, color: subtitleColor),
                        ),
                      ],
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: closeButtonColor, shape: BoxShape.circle),
                    child: Icon(Icons.close, color: subtitleColor, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _buildBody(context, noteProvider, currentState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NoteProvider noteProvider, SummaryState currentState) {
    final cs = Theme.of(context).colorScheme;

    switch (currentState) {
      case SummaryState.loading:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF7A36DC)),
              const SizedBox(height: 16),
              Text(
                'Summary in progress',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );

      case SummaryState.success:
        return Center(
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
                  color: cs.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your note has been updated with the summary.',
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );

      case SummaryState.initial:
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE520A4), Color(0xFF7A36DC)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await noteProvider.generateSummary(widget.noteId);
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Failed to request summary: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                label: Text(
                  AppLocalizations.of(context)!.generateSummary,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
    }
  }
}
