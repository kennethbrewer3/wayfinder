import 'package:flutter/material.dart';

/// Outlined URL field with an http/https scheme dropdown.
///
/// [controller] always holds the full URL (`scheme://host…`). When the host
/// part is empty, [controller] is empty (not `https://`) so save/clear logic
/// that checks `trim().isEmpty` keeps working.
class HttpUrlField extends StatefulWidget {
  const HttpUrlField({
    super.key,
    required this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.helperText,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final bool enabled;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  State<HttpUrlField> createState() => _HttpUrlFieldState();
}

class _HttpUrlParts {
  const _HttpUrlParts({required this.scheme, required this.rest});

  /// `http` or `https`.
  final String scheme;
  final String rest;

  static _HttpUrlParts parse(String raw) {
    final trimmed = raw.trim();
    final lower = trimmed.toLowerCase();
    if (lower.startsWith('https://')) {
      return _HttpUrlParts(scheme: 'https', rest: trimmed.substring(8));
    }
    if (lower.startsWith('http://')) {
      return _HttpUrlParts(scheme: 'http', rest: trimmed.substring(7));
    }
    return _HttpUrlParts(scheme: 'https', rest: trimmed);
  }

  /// Hint text without a leading scheme, for the host field.
  static String stripSchemeFromHint(String? hint) {
    if (hint == null || hint.trim().isEmpty) {
      return 'host.example.com';
    }
    return parse(hint).rest;
  }

  String get full {
    final r = rest.trim();
    if (r.isEmpty) {
      return '';
    }
    return '$scheme://$r';
  }
}

class _HttpUrlFieldState extends State<HttpUrlField> {
  late String _scheme;
  late final TextEditingController _restController;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    final parts = _HttpUrlParts.parse(widget.controller.text);
    _scheme = parts.scheme;
    _restController = TextEditingController(text: parts.rest);
    widget.controller.addListener(_onExternalControllerChanged);
  }

  @override
  void didUpdateWidget(covariant HttpUrlField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onExternalControllerChanged);
      widget.controller.addListener(_onExternalControllerChanged);
      _applyExternalText(widget.controller.text);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onExternalControllerChanged);
    _restController.dispose();
    super.dispose();
  }

  void _onExternalControllerChanged() {
    if (_syncing) {
      return;
    }
    _applyExternalText(widget.controller.text);
  }

  void _applyExternalText(String text) {
    final parts = _HttpUrlParts.parse(text);
    if (parts.scheme == _scheme && parts.rest == _restController.text) {
      return;
    }
    setState(() {
      _scheme = parts.scheme;
      if (_restController.text != parts.rest) {
        _restController.value = TextEditingValue(
          text: parts.rest,
          selection: TextSelection.collapsed(offset: parts.rest.length),
        );
      }
    });
  }

  void _pushToController() {
    _syncing = true;
    final full = _HttpUrlParts(
      scheme: _scheme,
      rest: _restController.text,
    ).full;
    if (widget.controller.text != full) {
      widget.controller.value = TextEditingValue(
        text: full,
        selection: TextSelection.collapsed(offset: full.length),
      );
      widget.onChanged?.call(full);
    }
    _syncing = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final restHint = _HttpUrlParts.stripSchemeFromHint(widget.hintText);

    return InputDecorator(
      decoration: InputDecoration(
        labelText: widget.labelText,
        helperText: widget.helperText,
        border: const OutlineInputBorder(),
        enabled: widget.enabled,
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _scheme,
              isDense: true,
              style: theme.textTheme.bodyLarge,
              items: const [
                DropdownMenuItem(value: 'https', child: Text('https')),
                DropdownMenuItem(value: 'http', child: Text('http')),
              ],
              onChanged: widget.enabled
                  ? (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => _scheme = value);
                      _pushToController();
                    }
                  : null,
            ),
          ),
          Text(
            '://',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: _restController,
              focusNode: widget.focusNode,
              enabled: widget.enabled,
              keyboardType: TextInputType.url,
              autocorrect: false,
              enableSuggestions: false,
              smartDashesType: SmartDashesType.disabled,
              smartQuotesType: SmartQuotesType.disabled,
              spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
              textInputAction: widget.textInputAction,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: restHint,
              ),
              onChanged: (_) => _pushToController(),
              onSubmitted: (_) {
                _pushToController();
                widget.onSubmitted?.call(widget.controller.text);
              },
            ),
          ),
        ],
      ),
    );
  }
}
