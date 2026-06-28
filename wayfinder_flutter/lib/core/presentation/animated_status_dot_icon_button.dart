import 'package:flutter/material.dart';

/// Icon button with a small status dot that pulses while [isLoading].
class AnimatedStatusDotIconButton extends StatefulWidget {
  const AnimatedStatusDotIconButton({
    super.key,
    required this.isReady,
    required this.isLoading,
    required this.tooltip,
    required this.icon,
    this.onPressed,
  });

  final bool isReady;
  final bool isLoading;
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  State<AnimatedStatusDotIconButton> createState() =>
      _AnimatedStatusDotIconButtonState();
}

class _AnimatedStatusDotIconButtonState extends State<AnimatedStatusDotIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnimation = Tween<double>(begin: 0.35, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(AnimatedStatusDotIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.isLoading) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController
        ..stop()
        ..value = 1;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _dotColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (widget.isReady) {
      return colorScheme.brightness == Brightness.dark
          ? const Color(0xFF81C784)
          : const Color(0xFF2E7D32);
    }
    if (widget.isLoading) {
      return colorScheme.primary;
    }
    return colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = _dotColor(context);

    return IconButton(
      tooltip: widget.tooltip,
      onPressed: widget.onPressed,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(widget.icon),
          Positioned(
            right: -1,
            bottom: -1,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: widget.isLoading ? _pulseAnimation.value : 1,
                  child: child,
                );
              },
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress bar shown while background work is still running.
class ActivityProgressBar extends StatelessWidget {
  const ActivityProgressBar({
    super.key,
    this.progress,
    this.label,
  });

  /// When null, shows an indeterminate progress bar.
  final double? progress;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentLabel = progress == null
        ? null
        : '${(progress!.clamp(0.0, 1.0) * 100).round()}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (progress == null)
          const LinearProgressIndicator()
        else
          LinearProgressIndicator(value: progress!.clamp(0.0, 1.0)),
        if (label != null || percentLabel != null) ...[
          const SizedBox(height: 4),
          Text(
            [?label, ?percentLabel].join(' · '),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
