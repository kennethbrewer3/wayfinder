/// Loads and parses the bundled user manual markdown asset.
library;

import 'package:flutter/services.dart';

class ManualSection {
  const ManualSection({
    required this.id,
    required this.title,
    required this.markdown,
  });

  final String id;
  final String title;
  final String markdown;
}

const manualAssetPath = 'assets/manual/user_manual.md';

Future<String> loadManualMarkdown() {
  return rootBundle.loadString(manualAssetPath);
}

List<ManualSection> parseManualSections(String markdown) {
  final lines = markdown.split('\n');
  final sections = <ManualSection>[];
  final buffer = StringBuffer();
  String? currentTitle;
  String? currentId;

  void flush() {
    final title = currentTitle;
    if (title == null) {
      return;
    }
    sections.add(
      ManualSection(
        id: currentId ?? _slugify(title),
        title: title,
        markdown: buffer.toString().trim(),
      ),
    );
    buffer.clear();
  }

  for (final line in lines) {
    if (line.startsWith('## ')) {
      flush();
      currentTitle = line.substring(3).trim();
      currentId = _slugify(currentTitle);
      continue;
    }
    if (currentTitle != null) {
      if (buffer.isNotEmpty) {
        buffer.writeln();
      }
      buffer.write(line);
    }
  }
  flush();
  return sections;
}

String _slugify(String title) {
  return title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}
