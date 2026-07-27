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
const _compassSize = 84.0;
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
    try {
      final current = widget.mapController.camera.rotation;
      widget.mapController.rotate(current + deltaDegrees);
    } catch (_) {
      // Map camera not ready (e.g. mid orientation change).
    }
  }

  void _resetRotation() {
    try {
      widget.mapController.rotate(0);
    } catch (_) {
      // Map camera not ready (e.g. mid orientation change).
    }
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
    final MapCamera camera;
    try {
      camera = widget.mapController.camera;
    } catch (_) {
      // Orientation / first-frame races — skip until the map camera is ready.
      return const SizedBox.shrink();
    }
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
    // Primary makes theme changes obvious; N/MN stay on the north accent.
    final roseColor = colors.primary;
    final panelColor = colors.surfaceContainerHigh;
    final chromeColor = colors.onSurface;
    final northLabel = switch (bearingReference) {
      BearingReference.trueNorth => 'N',
      BearingReference.magnetic => 'MN',
    };
    final modeHint = switch (bearingReference) {
      BearingReference.trueNorth => 'True',
      BearingReference.magnetic => 'Mag',
    };
    final declinationLabel = formatMagneticDeclination(declination);
    final themeRevision = Object.hash(
      roseColor.toARGB32(),
      panelColor.toARGB32(),
      northColor.toARGB32(),
    );

    return Material(
      key: ValueKey('compass-panel-$themeRevision'),
      color: panelColor.withValues(alpha: 0.96),
      elevation: 2,
      shadowColor: colors.shadow,
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: northColor.withValues(alpha: 0.7),
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
                  // Default long-press trigger steals the gesture on phones and
                  // shows the tip instead of toggling true/magnetic north.
                  // manual keeps mouse-hover tips on desktop/web.
                  triggerMode: TooltipTriggerMode.manual,
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
                            key: ValueKey('compass-svg-$themeRevision'),
                            width: _compassSize,
                            height: _compassSize,
                            theme: SvgTheme(currentColor: roseColor),
                            colorFilter: ColorFilter.mode(
                              roseColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          // Sit in the top band inside the outer ring, above
                          // the north pointer tip (SVG tip ≈ y=20 in 72 viewBox).
                          Align(
                            alignment: const Alignment(0, -0.92),
                            child: Text(
                              northLabel,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: northColor,
                                fontWeight: FontWeight.w800,
                                height: 1,
                                fontSize: northLabel.length > 1 ? 10 : 12,
                                letterSpacing: northLabel.length > 1 ? -0.4 : 0,
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
                      color: chromeColor,
                      onPressed: () => _rotateBy(-_rotationStepDegrees),
                    ),
                    _RotateButton(
                      tooltip: 'Rotate right 5°',
                      icon: Icons.rotate_right,
                      color: chromeColor,
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
