import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nota/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../controllers/note_provider.dart';

enum SummaryState { initial, loading, generated, editing }

class AiSummaryGeneratedSheet extends StatefulWidget {
  final String noteId;
  final Function(String)? onInsert;

  const AiSummaryGeneratedSheet({super.key, required this.noteId, this.onInsert});

  @override
  State<AiSummaryGeneratedSheet> createState() =>
      _AiSummaryGeneratedSheetState();
}

class _AiSummaryGeneratedSheetState extends State<AiSummaryGeneratedSheet> {
  final TextEditingController _summaryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NoteProvider>(context, listen: false).resetSummaryState();
    });
  }

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  void _copyToClipboard() async {
    if (_summaryController.text.isNotEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      await Clipboard.setData(ClipboardData(text: _summaryController.text));
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Summary copied to clipboard'),
          backgroundColor: Color(0xFF3D7AF9),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _insertSummary() {
    if (widget.onInsert != null && _summaryController.text.isNotEmpty) {
      widget.onInsert!(_summaryController.text);
    }
    Navigator.pop(context);
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
    final Color summaryBoxColor =
        isDark ? const Color(0xFF242038) : cs.primary.withValues(alpha: 0.05);

    // Watch NoteProvider to rebuild on changes
    final noteProvider = context.watch<NoteProvider>();

    // Sync TextEditingController with provider when not editing
    if (!noteProvider.isEditingSummary &&
        noteProvider.summarizedText != null &&
        noteProvider.summarizedText != _summaryController.text) {
      _summaryController.text = noteProvider.summarizedText!;
    }

    // Determine current UI state
    final SummaryState currentState;
    if (noteProvider.isSummarizing) {
      currentState = SummaryState.loading;
    } else if (noteProvider.summarizedText != null) {
      currentState = noteProvider.isEditingSummary
          ? SummaryState.editing
          : SummaryState.generated;
    } else {
      currentState = SummaryState.initial;
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: currentState == SummaryState.initial
            ? MediaQuery.of(context).size.height * 0.45
            : MediaQuery.of(context).size.height * 0.55,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Indicator
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

            // Header
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
              child: _buildBody(context, noteProvider, currentState, summaryBoxColor, closeButtonColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, NoteProvider noteProvider, SummaryState currentState, Color summaryBoxColor, Color secondaryBtnColor) {
    final cs = Theme.of(context).colorScheme;

    switch (currentState) {
      case SummaryState.loading:
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF7A36DC)),
        );

      case SummaryState.generated:
      case SummaryState.editing:
        final isEditing = currentState == SummaryState.editing;
        return Column(
          children: [
            // Summary Box
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: summaryBoxColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFF7A36DC).withValues(alpha: 0.3)),
                ),
                child: isEditing
                    ? TextField(
                        controller: _summaryController,
                        style: TextStyle(
                            color: cs.onSurface, fontSize: 14, height: 1.5),
                        maxLines: null,
                        expands: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Edit your summary...',
                          hintStyle: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.5)),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Text(
                          _summaryController.text,
                          style: TextStyle(
                              color: cs.onSurface, fontSize: 14, height: 1.5),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                // + Insert Button
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A2B75), Color(0xFF381F59)],
                      ),
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _insertSummary,
                      icon:
                          const Icon(Icons.add, color: Colors.white, size: 18),
                      label: const Text('Insert',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Edit / Save Button
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryBtnColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (isEditing) {
                          noteProvider.summarizedText = _summaryController.text;
                          noteProvider.isEditingSummary = false;
                        } else {
                          noteProvider.isEditingSummary = true;
                        }
                      },
                      icon: Icon(isEditing ? Icons.check : Icons.edit_outlined,
                          color: cs.onSurface, size: 18),
                      label: Text(isEditing ? 'Save' : 'Edit',
                          style: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Copy Button
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: secondaryBtnColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _copyToClipboard,
                    icon: Icon(Icons.copy_rounded,
                        color: cs.onSurface.withValues(alpha: 0.5), size: 20),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
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
                icon: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 20),
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
