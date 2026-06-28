import 'package:flutter/material.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../markers/presentation/map_object_markdown.dart';
import '../manual_content.dart';

class UserManualScreen extends StatefulWidget {
  const UserManualScreen({super.key});

  @override
  State<UserManualScreen> createState() => _UserManualScreenState();
}

class _UserManualScreenState extends State<UserManualScreen> {
  late final Future<List<ManualSection>> _sectionsFuture;
  final _scrollController = ScrollController();
  final _sectionKeys = <String, GlobalKey>{};
  String? _selectedSectionId;

  @override
  void initState() {
    super.initState();
    _sectionsFuture = loadManualMarkdown().then(parseManualSections);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  GlobalKey _keyForSection(String id) {
    return _sectionKeys.putIfAbsent(id, GlobalKey.new);
  }

  Future<void> _scrollToSection(String id) async {
    setState(() => _selectedSectionId = id);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) {
      return;
    }
    final targetContext = _keyForSection(id).currentContext;
    if (targetContext == null) {
      return;
    }
    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.userManualTitle),
      ),
      body: FutureBuilder<List<ManualSection>>(
        future: _sectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.userManualLoadFailed(snapshot.error.toString()),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final sections = snapshot.data ?? const [];
          if (sections.isEmpty) {
            return Center(child: Text(l10n.userManualEmpty));
          }

          final isWide = MediaQuery.sizeOf(context).width >= 900;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ManualTableOfContents(
                  sections: sections,
                  selectedSectionId: _selectedSectionId,
                  onSectionSelected: _scrollToSection,
                  width: 280,
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _ManualBody(
                    sections: sections,
                    scrollController: _scrollController,
                    sectionKeys: _sectionKeys,
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: SizedBox(
                  height: 52,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: sections.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final section = sections[index];
                      final selected = section.id == _selectedSectionId;
                      return FilterChip(
                        label: Text(section.title),
                        selected: selected,
                        onSelected: (_) => _scrollToSection(section.id),
                      );
                    },
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _ManualBody(
                  sections: sections,
                  scrollController: _scrollController,
                  sectionKeys: _sectionKeys,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ManualTableOfContents extends StatelessWidget {
  const _ManualTableOfContents({
    required this.sections,
    required this.selectedSectionId,
    required this.onSectionSelected,
    required this.width,
  });

  final List<ManualSection> sections;
  final String? selectedSectionId;
  final ValueChanged<String> onSectionSelected;
  final double width;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.userManualContentsTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                final selected = section.id == selectedSectionId;
                return ListTile(
                  dense: true,
                  selected: selected,
                  title: Text(section.title),
                  onTap: () => onSectionSelected(section.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualBody extends StatelessWidget {
  const _ManualBody({
    required this.sections,
    required this.scrollController,
    required this.sectionKeys,
  });

  final List<ManualSection> sections;
  final ScrollController scrollController;
  final Map<String, GlobalKey> sectionKeys;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          final key = sectionKeys.putIfAbsent(section.id, GlobalKey.new);
          return KeyedSubtree(
            key: key,
            child: Padding(
              padding: EdgeInsets.only(bottom: index == sections.length - 1 ? 0 : 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  MapObjectMarkdownBody(markdown: section.markdown),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
