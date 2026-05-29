import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../widgets/note/note_app_bar.dart';
import '../../widgets/note/rich_text_toolbar.dart';
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
  late final quill.QuillController _quillController;
  final NoteFormattingController _formattingController = NoteFormattingController();

  late final DateTime _createdAt;
  late final String _noteId;
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

    _noteId = existingNote?.id ??
        widget.noteId ??
        DateTime.now().millisecondsSinceEpoch.toString();
    _createdAt = existingNote?.createdAt ?? widget.createdAt ?? DateTime.now();

    _titleController = TextEditingController(text: existingNote?.title ?? '');

    quill.Document document;
    if (existingNote != null && existingNote.content.isNotEmpty) {
      try {
        document = quill.Document.fromJson(jsonDecode(existingNote.content));
      } catch (e) {
        document = quill.Document()..insert(0, existingNote.content);
      }
    } else {
      document = quill.Document();
    }

    _quillController = quill.QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );

    _titleController.addListener(_onTextChanged);
    _quillController.document.changes.listen((_) => _onTextChanged());
    _quillController.addListener(_updateFormattingState);
  }

  void _updateFormattingState() {
    if (!mounted) return;
    final style = _quillController.getSelectionStyle();
    final Map<String, dynamic> nativeFormatsMap = {
      'bold': style.containsKey('bold'),
      'italic': style.containsKey('italic'),
      'underline': style.containsKey('underline'),
      'header': style.attributes['header']?.value,
      'list': style.attributes['list']?.value,
    };
    _formattingController.updateFormats(nativeFormatsMap);
  }

  @override
  void dispose() {
    _quillController.removeListener(_updateFormattingState);
    _debounceTimer?.cancel();
    _saveStateNotifier.dispose();
    _titleController.dispose();
    _quillController.dispose();
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

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        final title = _titleController.text.isEmpty
            ? 'Untitled Note'
            : _titleController.text;
        final contentJson =
            jsonEncode(_quillController.document.toDelta().toJson());

        final updatedNote = NoteModel(
          id: _noteId,
          title: title,
          content: contentJson,
          createdAt: _createdAt,
          updatedAt: DateTime.now(),
        );

        context.read<NoteProvider>().saveNote(updatedNote);

        _saveStateNotifier.value = 'Saved';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'Untitled Note',
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.25),
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
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.38),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MMM dd, yyyy  hh:mm a').format(_createdAt),
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.38),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.85),
                    fontSize: 16,
                    height: 1.5,
                  ),
                  child: quill.QuillEditor.basic(
                    controller: _quillController,
                  ),
                ),
              ),
              RichTextToolbar(
                controller: _quillController,
                formattingController: _formattingController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
