import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


enum SummaryState { initial, loading, generated, editing }

class AiSummaryGeneratedSheet extends StatefulWidget {

  final Function(String)? onInsert;

  const AiSummaryGeneratedSheet({super.key, this.onInsert});

  @override
  State<AiSummaryGeneratedSheet> createState() => _AiSummaryGeneratedSheetState();
}

class _AiSummaryGeneratedSheetState extends State<AiSummaryGeneratedSheet> {
  SummaryState _currentState = SummaryState.initial;
  final TextEditingController _summaryController = TextEditingController();

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }


  Future<void> _generateSummaryFromAI() async {
    setState(() {
      _currentState = SummaryState.loading;
    });

    try {
      // TODO: 1. اربط الـ API بتاعك هنا
      // TODO: 2. ابعت محتوى النوتة للـ AI
      // final response = await myAiService.summarize(noteContent);

      // محاكاة لوقت الرد من السيرفر (شيلها وقت الربط)
      await Future.delayed(const Duration(seconds: 2));

      // النتيجة الوهمية (استبدلها بـ response الموديل)
      final generatedText = "This note discusses the key aspects of the NOTA project — an AI-powered note-taking platform designed for bilingual users.\n\n**Main Points:**\n• AI summarization and real-time collaboration\n• Full RTL support for Arabic language\n• Modern dark theme with clean mobile UX\n• Cross-platform: MacBook, iOS, and Android";

      if (mounted) {
        setState(() {
          _summaryController.text = generatedText;
          _currentState = SummaryState.generated;
        });
      }
    } catch (e) {
      // TODO: Handle Error (Show SnackBar)
      if (mounted) {
        setState(() => _currentState = SummaryState.initial);
      }
    }
  }

  void _copyToClipboard() async {
    if (_summaryController.text.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _summaryController.text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Summary copied to clipboard'),
            backgroundColor: Color(0xFF3D7AF9),
            duration: Duration(seconds: 2),
          ),
        );
      }
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
    const Color sheetColor = Color(0xFF1E1E2A);
    const Color textColor = Colors.white;
    const Color subtitleColor = Colors.grey;
    const Color buttonColorStart = Color(0xFFE520A4);
    const Color buttonColorEnd = Color(0xFF7A36DC);
    const Color closeButtonColor = Color(0xFF2A2A38);


    const Color summaryBoxColor = Color(0xFF242038);


    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: _currentState == SummaryState.initial
            ? MediaQuery.of(context).size.height * 0.45
            : MediaQuery.of(context).size.height * 0.55,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        decoration: const BoxDecoration(
          color: sheetColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'AI Summary',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'AI-generated summary of your note',
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
                    decoration: const BoxDecoration(color: closeButtonColor, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: subtitleColor, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),


            Expanded(
              child: _buildBody(summaryBoxColor, closeButtonColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(Color summaryBoxColor, Color secondaryBtnColor) {
    switch (_currentState) {
      case SummaryState.loading:
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF7A36DC)),
        );

      case SummaryState.generated:
      case SummaryState.editing:
        final isEditing = _currentState == SummaryState.editing;
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
                  border: Border.all(color: const Color(0xFF7A36DC).withValues(alpha: 0.3)),
                ),
                child: isEditing
                    ? TextField(
                  controller: _summaryController,
                  style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Edit your summary...',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                )
                    : SingleChildScrollView(
                  child: Text(
                    _summaryController.text,
                    style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _insertSummary,
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      label: const Text('Insert', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        setState(() {
                          _currentState = isEditing ? SummaryState.generated : SummaryState.editing;
                        });
                      },
                      icon: Icon(isEditing ? Icons.check : Icons.edit_outlined, color: Colors.white, size: 18),
                      label: Text(isEditing ? 'Save' : 'Edit', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    icon: const Icon(Icons.copy_rounded, color: Colors.white54, size: 20),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _generateSummaryFromAI,
                icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                label: const Text(
                  'Generate Summary',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
    }
  }
}