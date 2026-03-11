import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:gitforge/core/theme/app_theme.dart';
import 'package:gitforge/data/models/models.dart';
import 'package:gitforge/features/discovery/presentation/providers/app_providers.dart';
import 'package:gitforge/features/discovery/presentation/widgets/issue_card.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  late SwipableStackController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SwipableStackController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSwipe(GithubIssue issue, SwipeDirection direction) {
    if (direction == SwipeDirection.right) {
      ref.read(issuesProvider.notifier).saveIssue(issue.id);
      ref.read(savedIssuesProvider.notifier).addSavedIssue(issue);
      _showSnackbar('Saved! Check your saved issues ✓', AppColors.accentGreen);
    } else if (direction == SwipeDirection.left) {
      ref.read(issuesProvider.notifier).skipIssue(issue.id);
    }
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final issuesAsync = ref.watch(issuesProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: issuesAsync.when(
                loading: () => _buildSkeleton(),
                error: (e, _) => _buildError(e.toString()),
                data: (issues) {
                  if (issues.isEmpty) return _buildEmpty();
                  return _buildSwipeStack(issues);
                },
              ),
            ),
            _buildActionBar(issuesAsync.value ?? []),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Discover', style: Theme.of(context).textTheme.displayMedium),
              Text('Issues matched for you', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const Spacer(),
          _HeaderButton(
            icon: Icons.tune_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 10),
          _HeaderButton(
            icon: Icons.refresh_rounded,
            onTap: () => ref.read(issuesProvider.notifier).loadRecommendations(refresh: true),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeStack(List<GithubIssue> issues) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: SwipableStack(
        controller: _controller,
        stackClipBehaviour: Clip.none,
        allowVerticalSwipe: false,
        itemCount: issues.length,
        horizontalSwipeThreshold: 0.3,
        onSwipeCompleted: (index, direction) {
          if (index < issues.length) {
            _onSwipe(issues[index], direction);
          }
        },
        overlayBuilder: (context, properties) {
          final isRight = properties.direction == SwipeDirection.right;
          return Opacity(
            opacity: properties.swipeProgress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    (isRight ? AppColors.accentGreen : AppColors.accentRed).withOpacity(0.35),
                    Colors.transparent,
                  ],
                  begin: isRight ? Alignment.centerLeft : Alignment.centerRight,
                  end: isRight ? Alignment.centerRight : Alignment.centerLeft,
                ),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: isRight ? -0.3 : 0.3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isRight ? AppColors.accentGreen : AppColors.accentRed,
                        width: 3,
                      ),
                    ),
                    child: Text(
                      isRight ? 'SAVE' : 'SKIP',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: isRight ? AppColors.accentGreen : AppColors.accentRed,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        builder: (context, properties) {
          final index = properties.index;
          if (index >= issues.length) return const SizedBox.shrink();
          final issue = issues[index];
          return GestureDetector(
            onTap: () {
              ref.read(selectedIssueProvider.notifier).state = issue;
              context.push('/issue/${issue.id}', extra: issue);
            },
            child: IssueCard(issue: issue, isTop: properties.index == 0),
          );
        },
      ),
    );
  }

  Widget _buildActionBar(List<GithubIssue> issues) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 12, 32, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ActionButton(
            icon: Icons.close_rounded,
            color: AppColors.accentRed,
            size: 56,
            onTap: () {
              if (issues.isNotEmpty) {
                _controller.next(swipeDirection: SwipeDirection.left);
              }
            },
          ),
          const SizedBox(width: 20),
          _ActionButton(
            icon: Icons.info_outline_rounded,
            color: AppColors.accentBlue,
            size: 44,
            onTap: () {
              if (issues.isNotEmpty) {
                context.push('/issue/${issues.first.id}', extra: issues.first);
              }
            },
          ),
          const SizedBox(width: 20),
          _ActionButton(
            icon: Icons.favorite_rounded,
            color: AppColors.accentGreen,
            size: 56,
            onTap: () {
              if (issues.isNotEmpty) {
                _controller.next(swipeDirection: SwipeDirection.right);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 64, color: AppColors.accentGreen)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2.seconds, color: AppColors.accentGreen),
          const SizedBox(height: 20),
          Text('All caught up!', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Check back later for new matches', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => ref.read(issuesProvider.notifier).loadRecommendations(refresh: true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentGreen),
              ),
              child: Text(
                'Refresh Recommendations',
                style: TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColors.bgCard,
          border: Border.all(color: AppColors.border),
        ),
      ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1.5.seconds, color: AppColors.bgElevated),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.accentRed),
            const SizedBox(height: 16),
            Text('Failed to load issues', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(error, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.bgCard,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.bgCard,
            border: Border.all(color: widget.color.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.15),
                blurRadius: 16,
              ),
            ],
          ),
          child: Icon(widget.icon, size: widget.size * 0.42, color: widget.color),
        ),
      ),
    );
  }
}
