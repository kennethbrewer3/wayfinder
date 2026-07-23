import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../lines/models/bearing_reference.dart';
import '../../lines/providers/bearing_reference_provider.dart';
import '../../lines/utils/bearing_utils.dart';
import '../utils/magnetic_declination.dart';

const _compassAssetPath = 'assets/map/compass_rose.svg';
const _compassSize = 72.0;
const _rotationStepDegrees = 5.0;

/// Compass rose with map rotation controls (bottom-left of the map stack).
class MapCompassRoseOverlay extends ConsumerStatefulWidget {
  const MapCompassRoseOverlay({
    super.key,
    required this.mapController,
  });

  final MapController mapController;

  @override
  ConsumerState<MapCompassRoseOverlay> createState() =>
      _MapCompassRoseOverlayState();
}

class _MapCompassRoseOverlayState extends ConsumerState<MapCompassRoseOverlay> {
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

  void _rotateBy(double deltaDegrees) {
    final current = widget.mapController.camera.rotation;
    widget.mapController.rotate(current + deltaDegrees);
  }

  void _resetRotation() {
    widget.mapController.rotate(0);
  }

  Future<void> _toggleBearingReference() async {
    final current = ref.read(bearingReferenceProvider);
    final next = switch (current) {
      BearingReference.trueNorth => BearingReference.magnetic,
      BearingReference.magnetic => BearingReference.trueNorth,
    };
    await ref.read(bearingReferenceProvider.notifier).setReference(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final camera = widget.mapController.camera;
    final bearingReference = ref.watch(bearingReferenceProvider);
    final declination = magneticDeclinationDegrees(location: camera.center);
    final trueNorthAngle = northScreenAngle(
      anchor: camera.center,
      camera: camera,
    );
    // Magnetic north lies east of true north when declination is positive.
    final displayAngle = switch (bearingReference) {
      BearingReference.trueNorth => trueNorthAngle,
      BearingReference.magnetic =>
        trueNorthAngle + (declination * math.pi / 180),
    };
    final northColor = switch (bearingReference) {
      BearingReference.trueNorth => colors.error,
      BearingReference.magnetic => colors.primary,
    };
    final roseColor = colors.onSurface;
    final northLabel = switch (bearingReference) {
      BearingReference.trueNorth => 'N',
      BearingReference.magnetic => 'MN',
    };
    final modeHint = switch (bearingReference) {
      BearingReference.trueNorth => 'True',
      BearingReference.magnetic => 'Mag',
    };
    final declinationLabel = formatMagneticDeclination(declination);

    return Material(
      color: colors.surface.withValues(alpha: 0.94),
      elevation: 2,
      shadowColor: colors.shadow,
      borderRadius: BorderRadius.circular(10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: northColor.withValues(alpha: 0.65),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onDoubleTap: _resetRotation,
                onLongPress: _toggleBearingReference,
                child: Tooltip(
                  message:
                      'Double-tap: reset rotation\n'
                      'Long-press: toggle true / magnetic north',
                  child: SizedBox(
                    width: _compassSize,
                    height: _compassSize,
                    child: Transform.rotate(
                      angle: displayAngle,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            _compassAssetPath,
                            key: ValueKey(
                              'compass-rose-${roseColor.toARGB32()}-'
                              '${northColor.toARGB32()}',
                            ),
                            width: _compassSize,
                            height: _compassSize,
                            colorFilter: ColorFilter.mode(
                              roseColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          Align(
                            alignment: const Alignment(0, -0.78),
                            child: Text(
                              northLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: northColor,
                                fontWeight: FontWeight.w800,
                                height: 1,
                                fontSize: northLabel.length > 1 ? 11 : 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$modeHint · $declinationLabel',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: northColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: _compassSize,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _RotateButton(
                      tooltip: 'Rotate left 5°',
                      icon: Icons.rotate_left,
                      color: colors.onSurface,
                      onPressed: () => _rotateBy(-_rotationStepDegrees),
                    ),
                    _RotateButton(
                      tooltip: 'Rotate right 5°',
                      icon: Icons.rotate_right,
                      color: colors.onSurface,
                      onPressed: () => _rotateBy(_rotationStepDegrees),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RotateButton extends StatelessWidget {
  const _RotateButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: color),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 28, height: 28),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: color,
      ),
    );
  }
}
