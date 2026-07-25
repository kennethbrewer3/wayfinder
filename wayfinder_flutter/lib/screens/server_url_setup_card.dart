import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../core/app_globals.dart';
import '../core/server_config.dart';
import '../features/access/providers/api_server_url_view_model.dart';

/// API server URL editor for connection / sign-in screens.
///
/// - **Web:** normal inline [TextField] (physical keyboard; no soft-IME issues).
/// - **iOS/Android:** tappable summary row (no IME). Tap opens a full-screen
///   route on AuthGate's nested [Navigator] so soft-keyboard editing is not
///   under AuthGate / MediaQuery rebuilds.
class ServerUrlSetupCard extends ConsumerStatefulWidget {
  const ServerUrlSetupCard({super.key});

  @override
  ConsumerState<ServerUrlSetupCard> createState() => _ServerUrlSetupCardState();
}

class _ServerUrlSetupCardState extends ConsumerState<ServerUrlSetupCard> {
  late final TextEditingController _controller;

  /// Soft-keyboard platforms where AuthGate rebuilds fight the IME.
  bool get _useIsolatedEditor =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: apiUrlForDeviceForm(appServerConfig.apiUrl) ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save([String? raw]) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final apiUrl = await ref
        .read(apiServerUrlViewModelProvider.notifier)
        .save(raw ?? _controller.text);
    if (apiUrl == null || !mounted) {
      return;
    }
    if (_controller.text != apiUrl) {
      _controller.value = TextEditingValue(
        text: apiUrl,
        selection: TextSelection.collapsed(offset: apiUrl.length),
      );
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.accessServerUrlApplied(apiUrl),
        ),
      ),
    );
  }

  Future<void> _openMobileEditor() async {
    final l10n = AppLocalizations.of(context)!;
    final edited = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _ApiServerUrlEditorPage(
          initialUrl: _controller.text,
          title: l10n.settingsServerUrl,
          hintText: l10n.accessServerUrlHint,
          helpText: l10n.accessServerUrlHelp,
          saveLabel: l10n.settingsSaveServerUrl,
        ),
      ),
    );
    if (edited == null || !mounted) {
      return;
    }
    _controller.value = TextEditingValue(
      text: edited,
      selection: TextSelection.collapsed(offset: edited.length),
    );
    await _save(edited);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final displayed = _controller.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.settingsServerConnectionTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.accessServerUrlHelp,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        if (_useIsolatedEditor)
          // Plain bordered row — not InputDecorator (label + hint + child Text
          // were painting on top of each other).
          Material(
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: theme.colorScheme.outline),
            ),
            child: InkWell(
              onTap: _openMobileEditor,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.settingsServerUrl,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayed.isEmpty
                                ? l10n.accessServerUrlHint
                                : displayed,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: displayed.isEmpty
                                  ? theme.hintColor
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.edit_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          TextField(
            controller: _controller,
            keyboardType: TextInputType.url,
            autocorrect: false,
            enableSuggestions: false,
            smartDashesType: SmartDashesType.disabled,
            smartQuotesType: SmartQuotesType.disabled,
            spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: l10n.settingsServerUrl,
              hintText: l10n.accessServerUrlHint,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _save(),
          ),
        const _ApiServerUrlMessages(),
        const SizedBox(height: 12),
        _ApiServerUrlSaveButton(
          onPressed: () async {
            if (_useIsolatedEditor) {
              if (_controller.text.trim().isEmpty) {
                await _openMobileEditor();
                return;
              }
              await _save();
              return;
            }
            await _save();
          },
        ),
      ],
    );
  }
}

/// Full-screen URL editor — owns its own controller / focus.
class _ApiServerUrlEditorPage extends StatefulWidget {
  const _ApiServerUrlEditorPage({
    required this.initialUrl,
    required this.title,
    required this.hintText,
    required this.helpText,
    required this.saveLabel,
  });

  final String initialUrl;
  final String title;
  final String hintText;
  final String helpText;
  final String saveLabel;

  @override
  State<_ApiServerUrlEditorPage> createState() =>
      _ApiServerUrlEditorPageState();
}

class _ApiServerUrlEditorPageState extends State<_ApiServerUrlEditorPage> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl);
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            Text(
              widget.helpText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              // Prefer plain text over [TextInputType.url]: URL keyboards
              // (esp. Gboard) keep aggressive compose/autocomplete that can
              // re-insert text after backspace when the connection blips.
              keyboardType: TextInputType.text,
              autocorrect: false,
              enableSuggestions: false,
              smartDashesType: SmartDashesType.disabled,
              smartQuotesType: SmartQuotesType.disabled,
              spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: widget.title,
                hintText: widget.hintText,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submit,
              child: Text(widget.saveLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApiServerUrlMessages extends ConsumerWidget {
  const _ApiServerUrlMessages();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(
      apiServerUrlViewModelProvider.select((s) => s.errorMessage),
    );
    if (error == null) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        error,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}

class _ApiServerUrlSaveButton extends ConsumerWidget {
  const _ApiServerUrlSaveButton({required this.onPressed});

  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final saving = ref.watch(
      apiServerUrlViewModelProvider.select((s) => s.saving),
    );

    return FilledButton(
      onPressed: saving ? null : onPressed,
      child: saving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(l10n.settingsSaveServerUrl),
    );
  }
}
