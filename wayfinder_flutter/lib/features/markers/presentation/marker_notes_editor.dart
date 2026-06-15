import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:markdown_quill/markdown_quill.dart';

final _markdownDocument = md.Document(encodeHtml: false);
final _markdownToDelta = MarkdownToDelta(markdownDocument: _markdownDocument);
final _deltaToMarkdown = DeltaToMarkdown();

QuillController createMarkerNotesController({String? markdown}) {
  final trimmed = markdown?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return QuillController(
      document: Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  final delta = _markdownToDelta.convert(trimmed);
  return QuillController(
    document: Document.fromDelta(delta),
    selection: const TextSelection.collapsed(offset: 0),
  );
}

String markerNotesToMarkdown(QuillController controller) {
  final markdown = _deltaToMarkdown.convert(controller.document.toDelta()).trim();
  return markdown;
}

class MarkerNotesEditor extends StatelessWidget {
  const MarkerNotesEditor({
    super.key,
    required this.controller,
  });

  final QuillController controller;

  static const _editorHeight = 140.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Notes',
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              QuillSimpleToolbar(
                controller: controller,
                config: const QuillSimpleToolbarConfig(
                  showFontFamily: false,
                  showFontSize: false,
                  showSearchButton: false,
                  showSubscript: false,
                  showSuperscript: false,
                  showColorButton: false,
                  showBackgroundColorButton: false,
                  showInlineCode: true,
                  showQuote: true,
                  showLink: true,
                  showListCheck: true,
                ),
              ),
              const Divider(height: 1),
              SizedBox(
                height: _editorHeight,
                child: QuillEditor.basic(
                  controller: controller,
                  config: QuillEditorConfig(
                    placeholder: 'Add notes (saved as Markdown)...',
                    padding: const EdgeInsets.all(12),
                    scrollable: true,
                    autoFocus: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
