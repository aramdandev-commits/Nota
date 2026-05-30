import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../model/space_note_model.dart';
import '../../controllers/note_formatting_controller.dart';
import '../../widgets/note/note_app_bar.dart';

class SpaceNoteViewScreen extends StatefulWidget {
  final SpaceNoteModel note;

  const SpaceNoteViewScreen({super.key, required this.note});
  @override
  State<SpaceNoteViewScreen> createState() => _SpaceNoteViewScreenState();
}

class _SpaceNoteViewScreenState extends State<SpaceNoteViewScreen> {
  late final WebViewController _controller;
  late final TextEditingController _titleController;
  final NoteFormattingController _formattingController =
      NoteFormattingController();
  Map<String, dynamic> _activeFormats = {};
  final ValueNotifier<String> _saveStateNotifier = ValueNotifier<String>('Saved');

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);

    _controller = WebViewController()
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
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _injectThemeAndInitialize();
          },
        ),
      );
    _loadLocalHtml();
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
    }
  }

  @override
  void dispose() {
    _saveStateNotifier.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalHtml() async {
    String htmlContent =
        await rootBundle.loadString('assets/web_editor/index.html');
    _controller.loadHtmlString(htmlContent, baseUrl: 'https://nota.local');
  }

  void _injectThemeAndInitialize() {
    if (!mounted) return;

    final bgHex =
        '#${Theme.of(context).scaffoldBackgroundColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
    final textHex =
        '#${(Theme.of(context).textTheme.bodyLarge?.color ?? Theme.of(context).colorScheme.onSurface).value.toRadixString(16).padLeft(8, '0').substring(2)}';

    _controller.runJavaScript('''
      document.body.style.setProperty('--bg-color', '$bgHex');
      document.body.style.setProperty('--text-color', '$textHex');
      window.initEditor('${widget.note.id}', 'DUMMY_TOKEN_TESTING', 'wss://synopsis-cursive-ethics.ngrok-free.dev');
    ''');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        widget.note.title = _titleController.text;
        Navigator.pop(context, widget.note);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: ValueListenableBuilder<String>(
            valueListenable: _saveStateNotifier,
            builder: (context, saveState, child) {
              return NoteAppBar(saveState: saveState, noteId: widget.note.id);
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title & Date Header ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Untitled Note',
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
                          DateFormat('MMM dd, yyyy  hh:mm a')
                              .format(widget.note.createdAt),
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.38),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // ── Content ──────────────────────────────────────────────
              Expanded(
                child: WebViewWidget(controller: _controller),
              ),
              // ── Native Formatting Toolbar ────────────────────────────
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
                            onTap: () => _controller
                                .runJavaScript("window.toggleFormat('bold');"),
                          ),
                          _ToolbarButton(
                            icon: Icons.format_italic,
                            isActive: _formattingController.isItalic,
                            onTap: () => _controller.runJavaScript(
                                "window.toggleFormat('italic');"),
                          ),
                          _ToolbarButton(
                            icon: Icons.format_underline,
                            isActive: _formattingController.isUnderline,
                            onTap: () => _controller.runJavaScript(
                                "window.toggleFormat('underline');"),
                          ),
                          _ToolbarButton(
                            icon: Icons.format_strikethrough,
                            isActive: _activeFormats['strike'] == true,
                            onTap: () => _controller.runJavaScript(
                                "window.toggleFormat('strike');"),
                          ),
                          _Divider(),
                          _ToolbarTextButton(
                            text: 'H1',
                            isActive: _formattingController.isH1,
                            onTap: () => _controller.runJavaScript(
                                "window.toggleFormat('header', 1);"),
                          ),
                          _ToolbarTextButton(
                            text: 'H2',
                            isActive: _formattingController.isH2,
                            onTap: () => _controller.runJavaScript(
                                "window.toggleFormat('header', 2);"),
                          ),
                          _Divider(),
                          _ToolbarButton(
                            icon: Icons.format_list_bulleted,
                            isActive: _formattingController.isBulletedList,
                            onTap: () => _controller.runJavaScript(
                                "window.toggleFormat('list', 'bullet');"),
                          ),
                          _ToolbarButton(
                            icon: Icons.format_list_numbered,
                            isActive: _formattingController.isNumberedList,
                            onTap: () => _controller.runJavaScript(
                                "window.toggleFormat('list', 'ordered');"),
                          ),
                          _ToolbarButton(
                            icon: Icons.check_box_outlined,
                            isActive: _formattingController.isCheckbox,
                            onTap: () => _controller.runJavaScript(
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

  const _ToolbarButton(
      {required this.icon, required this.isActive, required this.onTap});

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

  const _ToolbarTextButton(
      {required this.text, required this.isActive, required this.onTap});

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
