import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gitforge/core/theme/app_theme.dart';
import 'package:gitforge/data/models/models.dart';
import 'package:gitforge/features/discovery/presentation/providers/app_providers.dart';

class IssueDetailScreen extends ConsumerStatefulWidget {
  final String issueId;
  final GithubIssue? issue;

  const IssueDetailScreen({
    super.key,
    required this.issueId,
    this.issue,
  });

  @override
  ConsumerState<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends ConsumerState<IssueDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  GithubIssue? get _issue =>
      widget.issue ?? ref.read(selectedIssueProvider);

  Future<void> _openGithub() async {
    if (_issue == null) return;
    final uri = Uri.parse(_issue!.githubUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final issue = _issue;
    if (issue == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(),
        body: const Center(child: Text('Issue not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: AppColors.bg,
              expandedHeight: 0,
              floating: true,
              snap: true,
              pinned: true,
              title: Text(
                '#${issue.issueNumber}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: _openGithub,
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.textSecondary),
                        SizedBox(width: 6),
                        Text(
                          'GitHub',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ];
        },
        body: Column(
          children: [
            // Issue header
            _buildIssueHeader(issue),
            // Tab bar
            _buildTabBar(),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _OverviewTab(issue: issue),
                  _GuideTab(issueId: issue.id),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(issue),
    );
  }

  Widget _buildIssueHeader(GithubIssue issue) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Repo name
          Row(
            children: [
              const Icon(Icons.folder_open_rounded, size: 14, color: AppColors.accentBlue),
              const SizedBox(width: 6),
              Text(
                issue.fullRepoName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentBlue,
                ),
              ),
              const SizedBox(width: 12),
              if (issue.repoLanguage != null) ...[
                _LangDot(language: issue.repoLanguage!),
              ],
            ],
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 12),
          // Title
          Text(
            issue.title,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 22,
                  letterSpacing: -0.3,
                ),
          ).animate().fadeIn(delay: 50.ms, duration: 400.ms),
          const SizedBox(height: 16),
          // Badges row
          Row(
            children: [
              _DifficultyBadge(difficulty: issue.difficulty),
              const SizedBox(width: 10),
              _MatchBadge(score: issue.matchScore),
              const Spacer(),
              _StatPill(
                icon: Icons.star_rounded,
                value: _formatCount(issue.repoStars),
                color: AppColors.accentOrange,
              ),
              const SizedBox(width: 8),
              _StatPill(
                icon: Icons.chat_bubble_outline_rounded,
                value: issue.commentsCount.toString(),
                color: AppColors.accentBlue,
              ),
            ],
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.bgElevated,
          border: Border.all(color: AppColors.borderActive),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'AI Guide'),
        ],
      ),
    );
  }

  Widget _buildBottomBar(GithubIssue issue) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              ref.read(savedIssuesProvider.notifier).addSavedIssue(issue);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Issue saved!'),
                  backgroundColor: AppColors.accentGreen,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                color: AppColors.bgSurface,
              ),
              child: const Icon(Icons.bookmark_add_outlined, color: AppColors.textSecondary, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _openGithub,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(colors: AppColors.gradientGreen),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGreen.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.code_rounded, color: AppColors.bg, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Start Contributing',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.bg,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}

class _OverviewTab extends StatelessWidget {
  final GithubIssue issue;

  const _OverviewTab({required this.issue});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      children: [
        // AI Summary section
        _Section(
          title: 'AI Summary',
          icon: Icons.auto_awesome_rounded,
          iconColor: AppColors.accentPurple,
          child: Text(
            issue.aiSummary,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
          ),
        ),
        const SizedBox(height: 20),
        // Required skills
        _Section(
          title: 'Required Skills',
          icon: Icons.psychology_rounded,
          iconColor: AppColors.accentBlue,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: issue.requiredSkills
                .map((s) => _SkillChip(skill: s))
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        // Labels
        if (issue.labels.isNotEmpty) ...[
          _Section(
            title: 'Labels',
            icon: Icons.label_outline_rounded,
            iconColor: AppColors.accentOrange,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: issue.labels
                  .map((l) => _LabelChip(label: l))
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
        // Issue stats
        _Section(
          title: 'Repository Info',
          icon: Icons.info_outline_rounded,
          iconColor: AppColors.textMuted,
          child: Column(
            children: [
              _InfoRow('Repository', issue.fullRepoName),
              _InfoRow('Language', issue.repoLanguage ?? 'Unknown'),
              _InfoRow('Stars', _formatStars(issue.repoStars)),
              _InfoRow('Comments', issue.commentsCount.toString()),
              _InfoRow(
                'Opened',
                _formatDate(issue.createdAt),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatStars(int stars) {
    if (stars >= 1000) return '${(stars / 1000).toStringAsFixed(1)}k';
    return stars.toString();
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).round()} months ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    return 'Today';
  }
}

class _GuideTab extends ConsumerWidget {
  final String issueId;

  const _GuideTab({required this.issueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guideAsync = ref.watch(contributionGuideProvider(issueId));

    return guideAsync.when(
      loading: () => _buildLoading(context),
      error: (e, _) => Center(child: Text('Failed to generate guide: $e')),
      data: (guide) => _buildGuide(context, guide),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.accentPurple.withOpacity(0.1),
              border: Border.all(color: AppColors.accentPurple.withOpacity(0.3)),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.accentPurple, size: 28),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1.5.seconds, color: AppColors.accentPurple),
          const SizedBox(height: 20),
          Text('Generating AI contribution guide...', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            'This may take a few seconds',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildGuide(BuildContext context, String guide) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.accentPurple.withOpacity(0.1),
              ),
              child: const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.accentPurple),
            ),
            const SizedBox(width: 8),
            const Text(
              'AI GENERATED GUIDE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.accentPurple,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 20),
        // Render markdown-like guide
        _MarkdownContent(content: guide),
      ],
    );
  }
}

class _MarkdownContent extends StatelessWidget {
  final String content;

  const _MarkdownContent({required this.content});

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
          child: Text(
            line.substring(3),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.accentGreen,
                ),
          ).animate().fadeIn(delay: (i * 30).ms, duration: 400.ms),
        ));
      } else if (line.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 6),
          child: Text(
            line.substring(4),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
          ).animate().fadeIn(delay: (i * 30).ms, duration: 400.ms),
        ));
      } else if (line.startsWith('- ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.fromLTRB(4, 8, 10, 0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentGreen,
                ),
              ),
              Expanded(
                child: Text(
                  line.substring(2),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: (i * 20).ms, duration: 400.ms),
        ));
      } else if (line.startsWith('   - ')) {
        // Nested list
        widgets.add(Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 0, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.fromLTRB(4, 8, 8, 0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textMuted,
                ),
              ),
              Expanded(
                child: Text(
                  line.substring(5),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                        height: 1.5,
                        fontSize: 13,
                      ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: (i * 20).ms, duration: 400.ms),
        ));
      } else if (line.startsWith('`') && line.endsWith('`')) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: AppColors.bgSurface,
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              line.replaceAll('`', ''),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: AppColors.accentGreen,
              ),
            ),
          ).animate().fadeIn(delay: (i * 20).ms, duration: 400.ms),
        ));
      } else if (line.trim().isNotEmpty) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(
            line,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
          ).animate().fadeIn(delay: (i * 15).ms, duration: 400.ms),
        ));
      } else {
        widgets.add(const SizedBox(height: 4));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _Section({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: iconColor,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: AppColors.bgSurface,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        skill,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  final String label;
  const _LabelChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final isGoodFirst = label.contains('good first');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isGoodFirst
            ? AppColors.accentGreen.withOpacity(0.1)
            : AppColors.bgSurface,
        border: Border.all(
          color: isGoodFirst ? AppColors.accentGreen.withOpacity(0.3) : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isGoodFirst ? AppColors.accentGreen : AppColors.textSecondary,
        ),
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
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: difficulty.color),
          ),
        ],
      ),
    );
  }
}

class _MatchBadge extends StatelessWidget {
  final double score;
  const _MatchBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.accentGreen.withOpacity(0.1),
        border: Border.all(color: AppColors.accentGreen.withOpacity(0.3)),
      ),
      child: Text(
        '${(score * 100).round()}% match',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.accentGreen,
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _StatPill({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      ],
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
    'Dart': Color(0xFF00B4AB),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[language] ?? AppColors.textMuted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 4),
        Text(language, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
