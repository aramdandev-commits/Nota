import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nota/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_provider.dart';
import '../../controllers/note_provider.dart';
import '../../services/pdf_service.dart';

class ImportPdfBody extends StatefulWidget {
  const ImportPdfBody({super.key});

  @override
  State<ImportPdfBody> createState() => _ImportPdfBodyState();
}

class _ImportPdfBodyState extends State<ImportPdfBody> {
  bool _isPicking = false;
  String? _fileName;
  String? _fileSize;
  String? _uploadError;

  // ── File picking + upload ─────────────────────────────────────────────────

  Future<void> _pickAndUpload() async {
    if (_isPicking) return;
    setState(() {
      _isPicking = true;
      _uploadError = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: false,
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final path = file.path;
      if (path == null) {
        setState(() => _uploadError = 'Cannot read file path.');
        return;
      }

      final bytes = file.size;
      final sizeLabel = bytes < 1024 * 1024
          ? '${(bytes / 1024).toStringAsFixed(1)} KB'
          : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

      setState(() {
        _fileName = file.name;
        _fileSize = sizeLabel;
      });

      // Mark processing started in NoteProvider
      final noteProvider = context.read<NoteProvider>();
      noteProvider.startPdfProcessing();

      // Get token
      final token = context.read<AuthProvider>().token;
      if (token == null) {
        setState(() => _uploadError = 'Not authenticated.');
        noteProvider.resetPdfState();
        return;
      }

      // Upload — any upload error is shown inline
      await PdfService().uploadPdf(filePath: path, token: token);
      // From here we wait for Pusher pdf.extracted event
      // NoteProvider.isPdfProcessing stays true until Pusher fires
    } catch (e) {
      setState(() => _uploadError = e.toString());
      if (mounted) context.read<NoteProvider>().resetPdfState();
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final noteProvider = context.watch<NoteProvider>();

    // When Pusher delivers the note → close sheet and show success SnackBar
    if (noteProvider.pdfNote != null) {
      final title = noteProvider.pdfNote!.title;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        noteProvider.resetPdfState();
        Navigator.of(context).pop(); // close the modal sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF4ADE80), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '"${title.isNotEmpty ? title : 'Untitled'}" saved to your notes.',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1A2A1A),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      });
    }

    // Upload error state
    final uploadError = _uploadError ?? noteProvider.pdfError;

    if (uploadError != null) {
      return _ErrorView(
        message: uploadError,
        onRetry: () {
          setState(() => _uploadError = null);
          context.read<NoteProvider>().resetPdfState();
          setState(() {
            _fileName = null;
            _fileSize = null;
          });
        },
      );
    }

    // Processing view (after file picked, waiting for Pusher)
    if (_fileName != null) {
      return _ProcessingView(
        fileName: _fileName!,
        fileSize: _fileSize!,
        isProcessing: noteProvider.isPdfProcessing,
      );
    }

    // Default: file picker view
    return _PickerView(
      isPicking: _isPicking,
      onTap: _pickAndUpload,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PickerView
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
                  : const Icon(Icons.upload_rounded,
                      color: Color(0xFF9810FA), size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.tapToSelectPdf,
              style: const TextStyle(
                color: Color(0xFFF0F0F8),
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.pdfFileDescription,
              style: const TextStyle(
                color: Color(0xFF6A7282),
                fontSize: 13,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 20),
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
                    const Icon(Icons.folder_open_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.browseFiles,
                      style: const TextStyle(
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
// _ProcessingView
// ─────────────────────────────────────────────────────────────────────────────

class _ProcessingView extends StatelessWidget {
  const _ProcessingView({
    required this.fileName,
    required this.fileSize,
    required this.isProcessing,
  });

  final String fileName;
  final String fileSize;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // File info card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A1020),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded,
                    color: Color(0xFFE53935), size: 22),
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
                    Text(fileSize,
                        style: const TextStyle(
                            color: Color(0xFF6A7282),
                            fontSize: 12,
                            fontFamily: 'Inter')),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Status row
        Row(
          children: [
            if (isProcessing)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF9810FA),
                ),
              )
            else
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4ADE80),
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 12),
              ),
            const SizedBox(width: 10),
            Text(
              isProcessing
                  ? AppLocalizations.of(context)!.processingPdf
                  : AppLocalizations.of(context)!.conversionComplete,
              style: TextStyle(
                color: isProcessing
                    ? const Color(0xFFF0F0F8)
                    : const Color(0xFF4ADE80),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Indeterminate progress bar while waiting for Pusher
        if (isProcessing)
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: const LinearProgressIndicator(
              minHeight: 6,
              backgroundColor: Color(0xFF1E1E30),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9810FA)),
            ),
          ),

        const SizedBox(height: 4),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ErrorView
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0A0A),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFE53935), size: 36),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFF0F0F8),
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9810FA), Color(0xFFDB2777)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                AppLocalizations.of(context)!.tryAgain,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
