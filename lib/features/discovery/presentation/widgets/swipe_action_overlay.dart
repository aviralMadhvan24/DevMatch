import 'package:flutter/material.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:gitforge/core/theme/app_theme.dart';

class SwipeActionOverlay extends StatelessWidget {
  final double swipeProgress;
  final SwipeDirection direction;

  const SwipeActionOverlay({
    super.key,
    required this.swipeProgress,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    if (direction == SwipeDirection.right) {
      return _buildSaveOverlay();
    } else if (direction == SwipeDirection.left) {
      return _buildSkipOverlay();
    }
    return const SizedBox.shrink();
  }

  Widget _buildSaveOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            AppColors.accentGreen.withOpacity(0.0 + swipeProgress * 0.3),
            AppColors.accentGreen.withOpacity(0.0 + swipeProgress * 0.15),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border.all(
          color: AppColors.accentGreen
              .withOpacity(0.0 + swipeProgress.clamp(0, 1) * 0.8),
          width: 2,
        ),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Opacity(
            opacity: swipeProgress.clamp(0, 1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentGreen,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentGreen.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_add_rounded,
                      color: AppColors.bg, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'SAVE',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.bg,
                      letterSpacing: 1.5,
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

  Widget _buildSkipOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            AppColors.accentRed.withOpacity(0.0 + swipeProgress * 0.15),
            AppColors.accentRed.withOpacity(0.0 + swipeProgress * 0.3),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border.all(
          color: AppColors.accentRed
              .withOpacity(0.0 + swipeProgress.clamp(0, 1) * 0.8),
          width: 2,
        ),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Opacity(
            opacity: swipeProgress.clamp(0, 1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentRed,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentRed.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.close_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'SKIP',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.5,
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
