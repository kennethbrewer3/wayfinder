import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../lines/utils/bearing_utils.dart';

const _compassAssetPath = 'assets/map/compass_rose.svg';
const _compassSize = 56.0;

/// Fixed north-oriented compass rose for the upper-left map corner.
class MapCompassRoseOverlay extends StatefulWidget {
  const MapCompassRoseOverlay({
    super.key,
    required this.mapController,
  });

  final MapController mapController;

  @override
  State<MapCompassRoseOverlay> createState() => _MapCompassRoseOverlayState();
}

class _MapCompassRoseOverlayState extends State<MapCompassRoseOverlay> {
  StreamSubscription<MapEvent>? _mapEvents;

  @override
  void initState() {
    super.initState();
    _mapEvents = widget.mapController.mapEventStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant MapCompassRoseOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mapController != widget.mapController) {
      _mapEvents?.cancel();
      _mapEvents = widget.mapController.mapEventStream.listen((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _mapEvents?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final camera = widget.mapController.camera;
    final northAngle = northScreenAngle(
      anchor: camera.center,
      camera: camera,
    );

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 12),
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.18),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                width: _compassSize,
                height: _compassSize,
                child: Transform.rotate(
                  angle: northAngle,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        _compassAssetPath,
                        width: _compassSize,
                        height: _compassSize,
                        colorFilter: ColorFilter.mode(
                          colors.onSurface,
                          BlendMode.srcIn,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        child: Text(
                          'N',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.error,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
