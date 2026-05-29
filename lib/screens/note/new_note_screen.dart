import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nota/l10n/app_localizations.dart';
import 'package:nota/l10n/app_localizations_ar.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../widgets/note/note_app_bar.dart';
import '../../controllers/note_provider.dart';
import '../../model/note_model.dart';
import '../../controllers/note_formatting_controller.dart';

class NewNoteScreen extends StatefulWidget {
  final DateTime? createdAt;
  final String? noteId;

  const NewNoteScreen({super.key, this.createdAt, this.noteId});

  @override
  State<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
  late final TextEditingController _titleController;
  late final WebViewController _webViewController;
  final NoteFormattingController _formattingController =
      NoteFormattingController();
  Map<String, dynamic> _activeFormats = {};

  late final DateTime _createdAt;
  late String _noteId;
  bool _isNewNote = false;
  Timer? _debounceTimer;

  final ValueNotifier<String> _saveStateNotifier =
      ValueNotifier<String>('Saved');

  @override
  void initState() {
    super.initState();

    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    NoteModel? existingNote;

    if (widget.noteId != null) {
      try {
        existingNote =
            noteProvider.notes.firstWhere((n) => n.id == widget.noteId);
      } catch (e) {
        existingNote = null;
      }
    }

    _isNewNote = existingNote == null && widget.noteId == null;

    _noteId = existingNote?.id ??
        widget.noteId ??
        DateTime.now().millisecondsSinceEpoch.toString();
    _createdAt = existingNote?.createdAt ?? widget.createdAt ?? DateTime.now();

    _titleController = TextEditingController(text: existingNote?.title ?? '');

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FormatChannel',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final formats = jsonDecode(message.message) as Map<String, dynamic>;
            if (mounted) {
              setState(() {
                _activeFormats = formats;
              });
              _formattingController.updateFormats(formats);
            }
          } catch (e) {
            // ignore parsing errors
          }
        },
      )
      ..addJavaScriptChannel(
        'TextChangeChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == 'changed') {
            _saveStateNotifier.value = 'Saving...';
            _onTextChanged();
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _injectThemeAndInitialize(existingNote?.content ?? '');

            final noteContent = existingNote?.content ?? '';
            if (noteContent.isNotEmpty && noteContent != 'No content') {
              _webViewController
                  .runJavaScript("window.loadEditorState('$noteContent');");
            }
          },
        ),
      );

    _loadLocalHtml();

    if (_webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
    }

    _titleController.addListener(_onTextChanged);
  }

  Future<void> _loadLocalHtml() async {
    String htmlContent =
        await rootBundle.loadString('assets/web_editor/index.html');
    _webViewController.loadHtmlString(htmlContent,
        baseUrl: 'https://nota.local');
  }

  void _injectThemeAndInitialize(String initialContent) {
    if (!mounted) return;

    final bgHex =
        '#${Theme.of(context).scaffoldBackgroundColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
    final textHex =
        '#${(Theme.of(context).textTheme.bodyLarge?.color ?? Theme.of(context).colorScheme.onSurface).value.toRadixString(16).padLeft(8, '0').substring(2)}';

    // Escape initial content securely if needed
    final safeContent =
        initialContent.replaceAll("'", "\\'").replaceAll('\n', '\\n');

    _webViewController.runJavaScript('''
      document.body.style.setProperty('--bg-color', '$bgHex');
      document.body.style.setProperty('--text-color', '$textHex');
      
      if (window.initEditor) {
        window.initEditor('$_noteId', 'DUMMY_TOKEN', 'wss://synopsis-cursive-ethics.ngrok-free.dev');
      }
      
    ''');
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _saveStateNotifier.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!mounted) return;

    if (_saveStateNotifier.value != 'Saving...') {
      _saveStateNotifier.value = 'Saving...';
    }

    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;

      final title = _titleController.text.isEmpty
          ? 'Untitled Note'
          : _titleController.text;

      // Yjs base64 encoding/decoding logic hook
      String contentString = '';
      try {
        final contentResult = await _webViewController
            .runJavaScriptReturningResult('window.getEditorState()');
        contentString = contentResult.toString().replaceAll('"', '');
        if (contentString == 'null') contentString = '';
      } catch (e) {
        // Fallback
      }

      final updatedNote = NoteModel(
        id: _noteId,
        title: title,
        content: contentString,
        createdAt: _createdAt,
        updatedAt: DateTime.now(),
      );

      try {
        final newId = await context
            .read<NoteProvider>()
            .saveNote(updatedNote, isNew: _isNewNote);
        if (mounted) {
          if (_isNewNote) {
            _noteId = newId;
            _isNewNote = false;
          }
          _saveStateNotifier.value = 'Saved';
        }
      } catch (e) {
        if (mounted) {
          _saveStateNotifier.value = 'Error';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ValueListenableBuilder<String>(
          valueListenable: _saveStateNotifier,
          builder: (context, saveState, child) {
            return NoteAppBar(saveState: saveState, noteId: _noteId);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.untitledNote,
                  hintStyle: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.25),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                cursorColor: Colors.blueAccent,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: cs.onSurface.withValues(alpha: 0.38),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MMM dd, yyyy  hh:mm a').format(_createdAt),
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.38),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: WebViewWidget(controller: _webViewController),
              ),
              ListenableBuilder(
                listenable: _formattingController,
                builder: (context, _) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF111116)
                          : const Color(0xFFF0F0F5),
                      border: Border(
                        top: BorderSide(
                          color: cs.onSurface.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _ToolbarButton(
                            icon: Icons.format_bold,
                            isActive: _formattingController.isBold,
                            onTap: () => _webViewController
                                .runJavaScript("window.toggleFormat('bold');"),
                          ),
                          _ToolbarButton(
                            icon: Icons.format_italic,
                            isActive: _formattingController.isItalic,
                            onTap: () => _webViewController.runJavaScript(
                                "window.toggleFormat('italic');"),
                          ),
                          _ToolbarButton(
                            icon: Icons.format_underline,
                            isActive: _formattingController.isUnderline,
                            onTap: () => _webViewController.runJavaScript(
                                "window.toggleFormat('underline');"),
                          ),
                          _ToolbarButton(
                            icon: Icons.format_strikethrough,
                            isActive: _activeFormats['strike'] == true,
                            onTap: () => _webViewController.runJavaScript(
                                "window.toggleFormat('strike');"),
                          ),
                          _Divider(),
                          _ToolbarTextButton(
                            text: 'H1',
                            isActive: _formattingController.isH1,
                            onTap: () => _webViewController.runJavaScript(
                                "window.toggleFormat('header', 1);"),
                          ),
                          _ToolbarTextButton(
                            text: 'H2',
                            isActive: _formattingController.isH2,
                            onTap: () => _webViewController.runJavaScript(
                                "window.toggleFormat('header', 2);"),
                          ),
                          _Divider(),
                          _ToolbarButton(
                            icon: Icons.format_list_bulleted,
                            isActive: _formattingController.isBulletedList,
                            onTap: () => _webViewController.runJavaScript(
                                "window.toggleFormat('list', 'bullet');"),
                          ),
                          _ToolbarButton(
                            icon: Icons.format_list_numbered,
                            isActive: _formattingController.isNumberedList,
                            onTap: () => _webViewController.runJavaScript(
                                "window.toggleFormat('list', 'ordered');"),
                          ),
                          _ToolbarButton(
                            icon: Icons.check_box_outlined,
                            isActive: _formattingController.isCheckbox,
                            onTap: () => _webViewController.runJavaScript(
                                "window.toggleFormat('list', 'unchecked');"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive
                ? cs.primary.withValues(alpha: 0.15)
                : cs.onSurface.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isActive ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _ToolbarTextButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolbarTextButton({
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive
                ? cs.primary.withValues(alpha: 0.15)
                : cs.onSurface.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color:
                    isActive ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
