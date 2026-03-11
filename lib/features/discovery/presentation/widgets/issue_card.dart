import 'package:flutter/material.dart';
import 'package:gitforge/core/theme/app_theme.dart';
import 'package:gitforge/data/models/models.dart';

class IssueCard extends StatelessWidget {
  final GithubIssue issue;
  final bool isTop;

  const IssueCard({
    super.key,
    required this.issue,
    this.isTop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: AppColors.gradientCard,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isTop ? AppColors.borderActive : AppColors.border,
          width: isTop ? 1.5 : 1,
        ),
        boxShadow: isTop
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: AppColors.accentGreen.withOpacity(0.05),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(context),
                  const SizedBox(height: 12),
                  _buildAISummary(context),
                  const Spacer(),
                  _buildSkills(context),
                  const SizedBox(height: 12),
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Repo info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: AppColors.bgSurface,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.folder_open_rounded,
                        size: 12,
                        color: AppColors.accentBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      issue.fullRepoName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentBlue,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (issue.repoLanguage != null)
                      _LangDot(language: issue.repoLanguage!),
                    const SizedBox(width: 10),
                    const Icon(Icons.star_rounded,
                        size: 12, color: AppColors.accentOrange),
                    const SizedBox(width: 3),
                    Text(
                      _formatCount(issue.repoStars),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.chat_bubble_outline_rounded,
                        size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 3),
                    Text(
                      issue.commentsCount.toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Match score
          _MatchScoreBadge(score: issue.matchScore),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      issue.title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 17,
            height: 1.4,
          ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAISummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.bgSurface,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 12, color: AppColors.accentPurple),
              const SizedBox(width: 6),
              Text(
                'AI SUMMARY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentPurple,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            issue.aiSummary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSkills(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Skills',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: 11,
                letterSpacing: 0.8,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: issue.requiredSkills
              .map((skill) => _SkillChip(skill: skill))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        _DifficultyBadge(difficulty: issue.difficulty),
        const Spacer(),
        Text(
          '#${issue.issueNumber}',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

class _MatchScoreBadge extends StatelessWidget {
  final double score;

  const _MatchScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final percentage = (score * 100).round();
    final color = score >= 0.9
        ? AppColors.accentGreen
        : score >= 0.75
            ? AppColors.accentBlue
            : AppColors.accentOrange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'match',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.7),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final Difficulty difficulty;

  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: difficulty.color.withOpacity(0.1),
        border: Border.all(color: difficulty.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(difficulty.icon, size: 12, color: difficulty.color),
          const SizedBox(width: 5),
          Text(
            difficulty.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: difficulty.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String skill;

  const _SkillChip({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: AppColors.bgSurface,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        skill,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _LangDot extends StatelessWidget {
  final String language;

  const _LangDot({required this.language});

  static const _colors = {
    'TypeScript': Color(0xFF3178C6),
    'JavaScript': Color(0xFFF7DF1E),
    'Python': Color(0xFF3572A5),
    'Go': Color(0xFF00ACD7),
    'Rust': Color(0xFFDEA584),
    'Java': Color(0xFFB07219),
    'Dart': Color(0xFF00B4AB),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[language] ?? AppColors.textMuted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          language,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// Swipe overlay indicators
class SwipeOverlay extends StatelessWidget {
  final double swipeProgress; // -1.0 to 1.0
  final bool isRight;

  const SwipeOverlay({
    super.key,
    required this.swipeProgress,
    required this.isRight,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = swipeProgress.abs().clamp(0.0, 1.0);

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              (isRight ? AppColors.accentGreen : AppColors.accentRed)
                  .withOpacity(opacity * 0.3),
              Colors.transparent,
            ],
            begin: isRight ? Alignment.centerLeft : Alignment.centerRight,
            end: isRight ? Alignment.centerRight : Alignment.centerLeft,
          ),
        ),
        child: Center(
          child: Opacity(
            opacity: opacity,
            child: Transform.rotate(
              angle: isRight ? -0.3 : 0.3,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color:
                        isRight ? AppColors.accentGreen : AppColors.accentRed,
                    letterSpacing: 2,
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
