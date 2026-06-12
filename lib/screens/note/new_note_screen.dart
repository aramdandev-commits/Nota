import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nota/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../widgets/note/note_app_bar.dart';
import '../../controllers/note_provider.dart';
import '../../controllers/space_details_provider.dart';
import '../../model/note_model.dart';
import '../../controllers/note_formatting_controller.dart';

class NewNoteScreen extends StatefulWidget {
  final NoteModel? note;
  final String? spaceId;

  const NewNoteScreen({super.key, this.note, this.spaceId});

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

  final FocusNode _titleFocusNode = FocusNode();

  final ValueNotifier<String> _saveStateNotifier =
      ValueNotifier<String>('Saved');
  
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _isNewNote = widget.note == null;
    _noteId =
        widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    _createdAt = widget.note?.createdAt ?? DateTime.now();

    _titleController = TextEditingController(text: widget.note?.title ?? '');

    _titleFocusNode.addListener(() {
      if (_titleFocusNode.hasFocus) {
        _webViewController
            .runJavaScript("if (window.quill) window.quill.blur();");
      }
    });

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
            _injectThemeAndInitialize();
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

  void _injectThemeAndInitialize() {
    if (!mounted) return;

    final bgHex =
        '#${Theme.of(context).scaffoldBackgroundColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
    final textHex =
        '#${(Theme.of(context).textTheme.bodyLarge?.color ?? Theme.of(context).colorScheme.onSurface).value.toRadixString(16).padLeft(8, '0').substring(2)}';

    String payload = "null";
    if (widget.note != null && widget.note!.content.isNotEmpty) {
      final firstElement = widget.note!.content.first;
      if (firstElement is Map && firstElement.containsKey('ops')) {
        // Already a Quill Delta object {ops: [...]}
        payload = jsonEncode(firstElement);
      } else {
        // Raw ops array — wrap into a Delta object for Quill
        payload = jsonEncode({'ops': widget.note!.content});
      }
    }

    _webViewController.runJavaScript('''
      document.body.style.setProperty('--bg-color', '$bgHex');
      document.body.style.setProperty('--text-color', '$textHex');
      
      try {
        if (window.initEditor) {
          window.initEditor();
        }
        const content = $payload;
        if (content) {
          if (window.quill) {
            window.quill.setContents(content);
          }
        }
      } catch (e) {
        console.error('Initialization failed:', e);
      }
    ''');
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _saveStateNotifier.dispose();
    _titleController.dispose();
    _titleFocusNode.dispose();
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

      // Fetch plain text for the preview
      final rawText = await _webViewController.runJavaScriptReturningResult(
          "window.quill ? window.quill.getText() : document.body.innerText;");
      String cleanPreview =
          rawText.toString().replaceAll('"', '').replaceAll(r'\n', ' ').trim();
      if (cleanPreview.length > 60) {
        cleanPreview = "${cleanPreview.substring(0, 60)}...";
      }

      // Fetch Delta JSON string from JS
      List<dynamic> contentPayload = [];
      try {
        final rawDeltaStr =
            await _webViewController.runJavaScriptReturningResult(
                "JSON.stringify(window.quill.getContents());");
        String cleanDeltaStr = rawDeltaStr.toString();
        // Remove outer quotes and unescape string if it comes back double-escaped from JS
        if (cleanDeltaStr.startsWith('"') && cleanDeltaStr.endsWith('"')) {
          cleanDeltaStr = jsonDecode(cleanDeltaStr);
        }

        // Parse it into a Dart Map
        Map<String, dynamic> deltaJson = jsonDecode(cleanDeltaStr);
        contentPayload = [deltaJson];
      } catch (e) {
        // Fallback or error
      }

      final updatedNote = NoteModel(
        id: _noteId,
        spaceId: widget.spaceId,
        title: title,
        preview: cleanPreview,
        content: contentPayload,
        createdAt: _createdAt,
        updatedAt: DateTime.now(),
      );

      try {
        if (widget.note != null) {
          // Editing existing note
          if (widget.spaceId != null) {
            await context.read<SpaceDetailsProvider>().updateNote(
                widget.spaceId!, _noteId, title, contentPayload, cleanPreview);
          } else {
            await context
                .read<NoteProvider>()
                .saveNote(updatedNote, isNew: false);
          }
        } else {
          // Creating new note
          if (widget.spaceId != null) {
            if (_isNewNote) {
              await context.read<SpaceDetailsProvider>().createNote(
                  widget.spaceId!, title, contentPayload, cleanPreview);
              _isNewNote = false;
            } else {
              await context.read<SpaceDetailsProvider>().updateNote(
                  widget.spaceId!,
                  _noteId,
                  title,
                  contentPayload,
                  cleanPreview);
            }
          } else {
            final newId = await context
                .read<NoteProvider>()
                .saveNote(updatedNote, isNew: _isNewNote);
            if (mounted && _isNewNote) {
              _noteId = newId;
              _isNewNote = false;
            }
          }
        }

        if (mounted) {
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
                focusNode: _titleFocusNode,
                onChanged: (value) {
                  // Instantly clear error message state when typing valid text
                  if (_errorMessage != null) {
                    setState(() {
                      _errorMessage = null;
                    });
                  }
                },
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.untitledNote,
                  errorText: _errorMessage,
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
