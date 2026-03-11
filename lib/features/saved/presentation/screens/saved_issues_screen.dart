import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gitforge/core/theme/app_theme.dart';
import 'package:gitforge/data/models/models.dart';
import 'package:gitforge/features/discovery/presentation/providers/app_providers.dart';

class SavedIssuesScreen extends ConsumerWidget {
  const SavedIssuesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedIssuesProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Saved Issues', style: Theme.of(context).textTheme.displayMedium),
                  savedAsync.whenData(
                    (issues) => Text(
                      '${issues.length} issues saved',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ).value ?? const SizedBox.shrink(),
                ],
              ),
            ),
            Expanded(
              child: savedAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (issues) {
                  if (issues.isEmpty) return _buildEmpty(context);
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: issues.length,
                    itemBuilder: (context, index) {
                      return _SavedIssueCard(
                        issue: issues[index],
                        index: index,
                        onRemove: () =>
                            ref.read(savedIssuesProvider.notifier).removeSavedIssue(issues[index].id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_outline_rounded, size: 64, color: AppColors.textMuted)
              .animate().fadeIn(),
          const SizedBox(height: 16),
          Text('No saved issues yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Swipe right on issues you\'re\ninterested in contributing to',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SavedIssueCard extends StatelessWidget {
  final GithubIssue issue;
  final int index;
  final VoidCallback onRemove;

  const _SavedIssueCard({
    required this.issue,
    required this.index,
    required this.onRemove,
  });

  Future<void> _openGithub() async {
    final uri = Uri.parse(issue.githubUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => context.push('/issue/${issue.id}', extra: issue),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      issue.fullRepoName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ),
                  _DiffBadge(difficulty: issue.difficulty),
                  const SizedBox(width: 8),
                  _MatchBadge(score: issue.matchScore),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                issue.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                issue.aiSummary,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: issue.requiredSkills
                    .take(3)
                    .map((s) => _SkillPill(skill: s))
                    .toList(),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _openGithub,
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.textSecondary),
                            SizedBox(width: 6),
                            Text(
                              'Open on GitHub',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push('/issue/${issue.id}', extra: issue),
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.accentGreen.withOpacity(0.1),
                          border: Border.all(color: AppColors.accentGreen.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.accentGreen),
                            SizedBox(width: 6),
                            Text(
                              'View Guide',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 80).ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }
}

class _DiffBadge extends StatelessWidget {
  final Difficulty difficulty;
  const _DiffBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: difficulty.color.withOpacity(0.1),
      ),
      child: Text(
        difficulty.label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: difficulty.color),
      ),
    );
  }
}

class _MatchBadge extends StatelessWidget {
  final double score;
  const _MatchBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${(score * 100).round()}%',
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.accentGreen,
      ),
    );
  }
}

class _SkillPill extends StatelessWidget {
  final String skill;
  const _SkillPill({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: AppColors.bgSurface,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        skill,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }
}
