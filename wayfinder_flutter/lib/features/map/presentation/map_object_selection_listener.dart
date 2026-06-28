import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../map/providers/selected_map_object_provider.dart';
import '../../markers/presentation/map_object_details_dialog.dart';

class MapObjectSelectionListener extends ConsumerStatefulWidget {
  const MapObjectSelectionListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<MapObjectSelectionListener> createState() =>
      _MapObjectSelectionListenerState();
}

class _MapObjectSelectionListenerState
    extends ConsumerState<MapObjectSelectionListener> {
  SelectedMapObject? _lastDialogSelection;
  bool _detailsDialogOpen = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<SelectedMapObject?>(
      selectedMapObjectProvider,
      (previous, next) {
        if (next == null) {
          _lastDialogSelection = null;
          if (_detailsDialogOpen && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            _detailsDialogOpen = false;
          }
          return;
        }

        if (!ref
            .read(selectedMapObjectProvider.notifier)
            .consumeOpenDetailsForSelection()) {
          _lastDialogSelection = next;
          return;
        }

        if (next == _lastDialogSelection && _detailsDialogOpen) {
          return;
        }

        _lastDialogSelection = next;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) {
            return;
          }

          if (_detailsDialogOpen && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }

          _detailsDialogOpen = true;
          await showMapObjectDetailsDialog(
            context: context,
            ref: ref,
            selection: next,
          );
          if (mounted) {
            _detailsDialogOpen = false;
          }
        });
      },
    );

    return widget.child;
  }
}
