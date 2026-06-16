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

  static const _radius = 56.0;
  static const _buttonSize = 56.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            radius: _radius,
            buttonSize: _buttonSize,
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
    required this.center,
  });

  final MapRadialMenuAction action;
  final double angle;
  final double radius;
  final double buttonSize;
  final Offset center;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dx = center.dx + math.cos(angle) * radius - buttonSize / 2;
    final dy = center.dy + math.sin(angle) * radius - buttonSize / 2;

    return Positioned(
      left: dx,
      top: dy,
      child: Tooltip(
        message: action.label,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    action.icon,
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    action.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      height: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
