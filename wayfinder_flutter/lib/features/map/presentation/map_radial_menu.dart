import 'dart:math' as math;

import 'package:flutter/material.dart';

class MapRadialMenuAction {
  const MapRadialMenuAction({
    required this.icon,
    required this.label,
    required this.onSelected,
  });

  final IconData icon;
  final String label;
  final VoidCallback onSelected;
}

class MapRadialMenu extends StatelessWidget {
  const MapRadialMenu({
    super.key,
    required this.center,
    required this.actions,
  });

  final Offset center;
  final List<MapRadialMenuAction> actions;

  static const _buttonSize = 48.0;
  static const _labelWidth = 84.0;

  double _radiusForCount(int count) {
    return switch (count) {
      <= 3 => 56.0,
      <= 5 => 72.0,
      _ => 80.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = _radiusForCount(actions.length);

    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: ColoredBox(
            color: Colors.black.withValues(alpha: 0.12),
          ),
        ),
        Positioned(
          left: center.dx - 6,
          top: center.dy - 6,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
        for (var index = 0; index < actions.length; index++)
          _RadialMenuButton(
            action: actions[index],
            angle: _angleForIndex(index, actions.length),
            radius: radius,
            buttonSize: _buttonSize,
            labelWidth: _labelWidth,
            center: center,
          ),
      ],
    );
  }

  double _angleForIndex(int index, int count) {
    if (count == 1) {
      return -math.pi / 2;
    }
    final startAngle = -math.pi / 2;
    final sweep = (2 * math.pi) / count;
    return startAngle + sweep * index;
  }
}

class _RadialMenuButton extends StatelessWidget {
  const _RadialMenuButton({
    required this.action,
    required this.angle,
    required this.radius,
    required this.buttonSize,
    required this.labelWidth,
    required this.center,
  });

  final MapRadialMenuAction action;
  final double angle;
  final double radius;
  final double buttonSize;
  final double labelWidth;
  final Offset center;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonCenter = Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );

    return Positioned(
      left: buttonCenter.dx - labelWidth / 2,
      top: buttonCenter.dy - buttonSize / 2,
      width: labelWidth,
      child: Tooltip(
        message: action.label,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(buttonSize / 2),
                color: theme.colorScheme.surface,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: action.onSelected,
                  borderRadius: BorderRadius.circular(buttonSize / 2),
                  child: SizedBox(
                    width: buttonSize,
                    height: buttonSize,
                    child: Icon(
                      action.icon,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  action.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    height: 1.15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
