import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'map_object_markdown_links.dart';

MarkdownStyleSheet mapObjectMarkdownStyleSheet(
  ThemeData theme, {
  Color? color,
  TextStyle? baseStyle,
}) {
  final textColor = color ?? theme.colorScheme.onSurfaceVariant;
  final style =
      baseStyle ??
      theme.textTheme.bodyMedium?.copyWith(
        color: textColor,
        height: 1.4,
      );

  return MarkdownStyleSheet(
    p: style,
    strong: style?.copyWith(fontWeight: FontWeight.w600),
    em: style?.copyWith(fontStyle: FontStyle.italic),
    listBullet: style,
    listIndent: 20,
    blockSpacing: 8,
    h1: style?.copyWith(fontWeight: FontWeight.w700, fontSize: 18),
    h2: style?.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
    h3: style?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
    blockquote: style?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    ),
    code: style?.copyWith(
      fontFamily: 'monospace',
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
    ),
    a: style?.copyWith(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
    ),
  );
}

class MapObjectMarkdownBody extends StatelessWidget {
  const MapObjectMarkdownBody({
    super.key,
    required this.markdown,
    this.color,
  });

  final String markdown;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MarkdownBody(
      // Soft-break long URLs so narrow layouts (phones, side panels) wrap
      // instead of overflowing. fitContent:false stretches to parent width.
      data: softWrapLongUrls(markdown),
      shrinkWrap: true,
      fitContent: false,
      styleSheet: mapObjectMarkdownStyleSheet(theme, color: color),
      onTapLink: (text, href, title) {
        handleMapObjectMarkdownLink(context, href);
      },
    );
  }
}

/// Inserts zero-width spaces after common URL delimiters so Flutter can wrap.
@visibleForTesting
String softWrapLongUrls(String markdown) {
  return markdown.replaceAllMapped(
    RegExp(r'https?://[^\s<>\[\]()]+'),
    (match) {
      final url = match[0]!;
      final out = StringBuffer();
      for (var i = 0; i < url.length; i++) {
        out.write(url[i]);
        final ch = url[i];
        if (i < url.length - 1 && '/&=?#._%-'.contains(ch)) {
          out.write('\u200B');
        }
      }
      return out.toString();
    },
  );
}
