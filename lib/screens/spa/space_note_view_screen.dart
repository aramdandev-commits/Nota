import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SpaceNoteViewScreen extends StatefulWidget {
  final String noteId;

  const SpaceNoteViewScreen({super.key, required this.noteId});

  @override
  State<SpaceNoteViewScreen> createState() => _SpaceNoteViewScreenState();
}

class _SpaceNoteViewScreenState extends State<SpaceNoteViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
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
      window.initEditor('${widget.noteId}', 'DUMMY_TOKEN_TESTING', 'wss://synopsis-cursive-ethics.ngrok-free.dev');
    ''');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios_new,
                        color: cs.onSurface, size: 20),
                  ),
                  const Spacer(),
                  Icon(Icons.more_vert,
                      color: cs.onSurface.withValues(alpha: 0.4), size: 22),
                ],
              ),
            ),
            // ── Content ──────────────────────────────────────────────
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}
