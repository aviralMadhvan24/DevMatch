import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gitforge/core/theme/app_theme.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onSave;
  final VoidCallback onInfo;

  const ActionButtons({
    super.key,
    required this.onSkip,
    required this.onSave,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Skip button
          _ActionButton(
            onTap: onSkip,
            icon: Icons.close_rounded,
            size: 52,
            iconSize: 24,
            color: AppColors.accentRed,
            tooltip: 'Skip',
          )
              .animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.3, end: 0, delay: 200.ms),
          const SizedBox(width: 16),
          // Info/Details button (smaller, center)
          _ActionButton(
            onTap: onInfo,
            icon: Icons.info_outline_rounded,
            size: 42,
            iconSize: 18,
            color: AppColors.textSecondary,
            tooltip: 'Details',
          )
              .animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.3, end: 0, delay: 300.ms),
          const SizedBox(width: 16),
          // Save button
          _ActionButton(
            onTap: onSave,
            icon: Icons.bookmark_add_rounded,
            size: 52,
            iconSize: 24,
            color: AppColors.accentGreen,
            tooltip: 'Save',
          )
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.3, end: 0, delay: 400.ms),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final double size;
  final double iconSize;
  final Color color;
  final String tooltip;

  const _ActionButton({
    required this.onTap,
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.color,
    required this.tooltip,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.color.withOpacity(0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              color: widget.color,
              size: widget.iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
