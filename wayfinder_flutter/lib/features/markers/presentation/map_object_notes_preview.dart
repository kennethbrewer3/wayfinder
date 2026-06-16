import 'package:flutter/material.dart';

import 'map_object_markdown.dart';

class MapObjectNotesPreview extends StatelessWidget {
  const MapObjectNotesPreview({
    super.key,
    required this.markdown,
    this.maxHeight = 56,
    this.color,
  });

  final String markdown;
  final double maxHeight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: MapObjectMarkdownBody(
          markdown: markdown,
          color: color,
        ),
      ),
    );
  }
}
