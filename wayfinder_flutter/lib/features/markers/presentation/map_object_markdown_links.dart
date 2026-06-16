import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

Uri? normalizeMarkdownLinkUri(String href) {
  final trimmed = href.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  final parsed = Uri.tryParse(trimmed);
  if (parsed != null && parsed.hasScheme) {
    return parsed;
  }

  return Uri.tryParse('https://$trimmed');
}

Future<void> handleMapObjectMarkdownLink(
  BuildContext context,
  String? href,
) async {
  if (href == null || href.trim().isEmpty) {
    return;
  }

  final trimmed = href.trim();
  if (trimmed.startsWith('/') && context.mounted) {
    context.push(trimmed);
    return;
  }

  final uri = normalizeMarkdownLinkUri(trimmed);
  if (uri == null) {
    return;
  }

  final launched = await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );

  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open link: $trimmed')),
    );
  }
}
