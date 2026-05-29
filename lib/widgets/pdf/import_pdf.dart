import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nota/l10n/app_localizations.dart';

class ImportPdfBody extends StatefulWidget {
  const ImportPdfBody({super.key});

  @override
  State<ImportPdfBody> createState() => _ImportPdfBodyState();
}

class _ImportPdfBodyState extends State<ImportPdfBody> {
  // ── State ──────────────────────────────────────────────────────────────────

  bool _isPicking = false;

  // Once a file is picked these are set and we switch to the processing view
  String? _fileName;
  String? _fileSize;

  // Progress goes from 0.0 to 1.0
  double _progress = 0.0;

  // The fake timer that ticks progress forward
  Timer? _timer;

  // ── File picking ───────────────────────────────────────────────────────────

  Future<void> _pickPdf() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Format the file size nicely (e.g. "65.0 KB" or "2.3 MB")
        final bytes = file.size;
        final sizeLabel = bytes < 1024 * 1024
            ? '${(bytes / 1024).toStringAsFixed(1)} KB'
            : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

        setState(() {
          _fileName = file.name;
          _fileSize = sizeLabel;
        });

        // Start the fake processing animation
        _startFakeProcessing();
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  // ── Fake processing ────────────────────────────────────────────────────────
  //
  // This simulates OCR progress with a Timer that fires every 80ms.
  // Each tick adds a small random amount so it feels natural, not robotic.
  //
  // TO REPLACE WITH REAL API:
  //   - Remove this method and the Timer
  //   - Call your OCR endpoint here
  //   - As the server sends progress updates, call:
  //       setState(() => _progress = newValueBetween0and1);

  void _startFakeProcessing() {
    _progress = 0.0;

    // Tick every 80ms → ~4 seconds to reach 100%
    _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        // Slow down as we approach 95% (feels like waiting for server)
        final increment = _progress < 0.9 ? 0.018 : 0.004;
        _progress = (_progress + increment).clamp(0.0, 1.0);
      });

      if (_progress >= 1.0) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Show processing view once a file has been picked
    if (_fileName != null) {
      return _ProcessingView(
        fileName: _fileName!,
        fileSize: _fileSize!,
        progress: _progress,
      );
    }

    // Otherwise show the file picker view
    return _PickerView(
      isPicking: _isPicking,
      onTap: _pickPdf,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PickerView  –  "Tap to select a PDF file" + Browse Files button
// ─────────────────────────────────────────────────────────────────────────────

class _PickerView extends StatelessWidget {
  const _PickerView({required this.isPicking, required this.onTap});

  final bool isPicking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(
          children: [
            // Upload icon / spinner
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF2A1A3E),
                borderRadius: BorderRadius.circular(18),
              ),
              child: isPicking
                  ? const Padding(
                      padding: EdgeInsets.all(18),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF9810FA),
                      ),
                    )
                  : const Icon(
                      Icons.upload_rounded,
                      color: Color(0xFF9810FA),
                      size: 30,
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.tapToSelectPdf,
              style: TextStyle(
                color: Color(0xFFF0F0F8),
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.pdfFileDescription,
              style: TextStyle(
                color: Color(0xFF6A7282),
                fontSize: 13,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 20),
            // Browse Files button
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9810FA), Color(0xFFDB2777)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_open_rounded,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.browseFiles,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
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

// ─────────────────────────────────────────────────────────────────────────────
// _ProcessingView  –  file info + progress bar + step list
// ─────────────────────────────────────────────────────────────────────────────

class _ProcessingView extends StatelessWidget {
  const _ProcessingView({
    required this.fileName,
    required this.fileSize,
    required this.progress,
  });

  final String fileName;
  final String fileSize;

  /// 0.0 → 1.0.  Drive this from your API later.
  final double progress;

  // Which step is currently active based on progress thresholds
  _StepState _stateFor(_StepSlot slot) {
    // Each step occupies roughly one third of the progress range
    const thresholds = [0.33, 0.66, 0.95]; // end of each step
    final i = slot.index;

    if (progress >= 1.0) return _StepState.done; // all done at 100%
    if (progress >= thresholds[i]) return _StepState.done;
    // Is this the currently active step?
    final prevDone = i == 0 || progress >= thresholds[i - 1];
    if (prevDone) return _StepState.active;
    return _StepState.pending;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    final isDone = progress >= 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── File info card ─────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Row(
            children: [
              // PDF icon badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A1020),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Color(0xFFE53935),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFF0F0F8),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fileSize,
                      style: const TextStyle(
                        color: Color(0xFF6A7282),
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── "Processing PDF  32%" ──────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.processingPdf,
              style: TextStyle(
                color: Color(0xFFF0F0F8),
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$pct%',
              style: const TextStyle(
                color: Color(0xFFF0F0F8),
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Gradient progress bar ──────────────────────────────────────────
        _ProgressBar(progress: progress),

        const SizedBox(height: 20),

        // ── Step list ──────────────────────────────────────────────────────
        _StepRow(
          label: AppLocalizations.of(context)!.analyzingPages,
          state: _stateFor(_StepSlot.analyzing),
        ),
        const SizedBox(height: 8),
        _StepRow(
          label: AppLocalizations.of(context)!.recognizingText,
          state: _stateFor(_StepSlot.recognizing),
        ),
        const SizedBox(height: 8),
        _StepRow(
          label: AppLocalizations.of(context)!.formattingContent,
          state: _stateFor(_StepSlot.formatting),
        ),

        // "Conversion Complete" card – only visible when done
        if (isDone) ...[
          const SizedBox(height: 8),
          _StepRow(
            label: AppLocalizations.of(context)!.conversionComplete,
            sublabel: AppLocalizations.of(context)!.processedPages,
            state: _StepState.done,
            highlight: true,
          ),
        ],

        const SizedBox(height: 4),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small helpers
// ─────────────────────────────────────────────────────────────────────────────

// The three OCR steps in order
enum _StepSlot { analyzing, recognizing, formatting }

// Visual state of a single step row
enum _StepState { pending, active, done }

// ── Gradient progress bar ─────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          // Track (background)
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E30),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Fill (animated width)
          AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            height: 6,
            width: constraints.maxWidth * progress,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9810FA), Color(0xFF3B82F6)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9810FA).withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

// ── Single step row ───────────────────────────────────────────────────────────

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.label,
    required this.state,
    this.sublabel,
    this.highlight = false,
  });

  final String label;
  final String? sublabel;
  final _StepState state;

  /// True for the "Conversion Complete" card (green background)
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    // Pick colours based on state
    final Color labelColor;
    final Color bgColor;
    final Color borderColor;

    switch (state) {
      case _StepState.pending:
        labelColor = const Color(0xFF3A3A50); // dim – not reached yet
        bgColor = Colors.transparent;
        borderColor = Colors.transparent;
      case _StepState.active:
        labelColor = const Color(0xFFF0F0F8); // bright – currently running
        bgColor = const Color(0xFF1A1A2E);
        borderColor = const Color(0xFF9810FA).withValues(alpha: 0.3);
      case _StepState.done:
        labelColor = highlight
            ? const Color(0xFF4ADE80) // green for completion card
            : const Color(0xFFF0F0F8);
        bgColor = highlight ? const Color(0xFF0D2010) : const Color(0xFF1A1A2E);
        borderColor = highlight
            ? const Color(0xFF4ADE80).withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.06);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          _StepIcon(state: state),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (sublabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    sublabel!,
                    style: const TextStyle(
                      color: Color(0xFF4ADE80),
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step icon (circle / spinner / checkmark) ──────────────────────────────────

class _StepIcon extends StatelessWidget {
  const _StepIcon({required this.state});
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case _StepState.pending:
        // Empty circle outline
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF3A3A50), width: 1.5),
          ),
        );
      case _StepState.active:
        // Spinning purple indicator
        return const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9810FA)),
          ),
        );
      case _StepState.done:
        // Solid green checkmark
        return Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF4ADE80),
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
        );
    }
  }
}
