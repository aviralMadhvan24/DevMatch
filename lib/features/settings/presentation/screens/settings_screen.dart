import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:gitforge/core/theme/app_theme.dart';
import 'package:gitforge/data/models/models.dart';
import 'package:gitforge/features/discovery/presentation/providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final profile = authState.profile ?? MockData.sampleProfile;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: _buildProfileHeader(context, profile),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: _buildStats(context, profile),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: _buildSkillsSection(context, profile),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: _buildSettingsSection(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, DeveloperProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Profile', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [AppColors.bgCard, AppColors.bgSurface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentGreen,
                      AppColors.accentBlue,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    profile.displayName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.bg,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.code_rounded, size: 13, color: AppColors.accentGreen),
                        const SizedBox(width: 4),
                        Text(
                          '@${profile.githubUsername}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.accentGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (profile.bio != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        profile.bio!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms),
      ],
    );
  }

  Widget _buildStats(BuildContext context, DeveloperProfile profile) {
    return Row(
      children: [
        _StatCard(value: profile.totalContributions.toString(), label: 'Commits', icon: Icons.commit_rounded, color: AppColors.accentGreen),
        const SizedBox(width: 10),
        _StatCard(value: profile.publicRepos.toString(), label: 'Repos', icon: Icons.folder_open_rounded, color: AppColors.accentBlue),
        const SizedBox(width: 10),
        _StatCard(value: profile.followers.toString(), label: 'Followers', icon: Icons.people_rounded, color: AppColors.accentPurple),
      ],
    ).animate().fadeIn(delay: 100.ms, duration: 500.ms);
  }

  Widget _buildSkillsSection(BuildContext context, DeveloperProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.accentGreen),
            const SizedBox(width: 8),
            Text('Your Skills', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.accentPurple.withOpacity(0.1),
              ),
              child: Text(
                'AI analyzed',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accentPurple),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.bgCard,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: profile.skills.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _SkillRow(skill: entry.value, index: entry.key),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Languages
        Text('Primary Languages', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textMuted, letterSpacing: 0.8)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: profile.primaryLanguages.map((lang) => _LangChip(lang: lang)).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms);
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.bgCard,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                subtitle: 'Match alerts & updates',
                trailing: Switch(
                  value: true,
                  onChanged: (_) {},
                  activeThumbColor: AppColors.accentGreen,
                ),
              ),
              const Divider(height: 1, color: AppColors.border, indent: 56),
              _SettingsTile(
                icon: Icons.psychology_outlined,
                title: 'AI Preferences',
                subtitle: 'Customize match algorithm',
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
                onTap: () {},
              ),
              const Divider(height: 1, color: AppColors.border, indent: 56),
              _SettingsTile(
                icon: Icons.shield_outlined,
                title: 'Privacy',
                subtitle: 'Data & security settings',
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
                onTap: () {},
              ),
              const Divider(height: 1, color: AppColors.border, indent: 56),
              _SettingsTile(
                icon: Icons.logout_rounded,
                title: 'Sign Out',
                subtitle: 'Log out of DevMatch',
                titleColor: AppColors.accentRed,
                onTap: () => ref.read(authProvider.notifier).logout(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              Text(
                'DevMatch v1.0.0',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 4),
              Text(
                'Open Source Contribution Platform',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms);
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.bgCard,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  final SkillEntry skill;
  final int index;

  const _SkillRow({required this.skill, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            skill.name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LinearPercentIndicator(
            lineHeight: 5,
            percent: skill.proficiency,
            backgroundColor: AppColors.bgSurface,
            linearGradient: LinearGradient(
              colors: skill.proficiency > 0.8 ? AppColors.gradientGreen : AppColors.gradientBlue,
            ),
            barRadius: const Radius.circular(3),
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(skill.proficiency * 100).round()}%',
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
        ),
      ],
    ).animate().fadeIn(delay: (index * 60).ms, duration: 400.ms);
  }
}

class _LangChip extends StatelessWidget {
  final String lang;
  const _LangChip({required this.lang});

  static const _colors = {
    'TypeScript': Color(0xFF3178C6),
    'JavaScript': Color(0xFFF7DF1E),
    'Python': Color(0xFF3572A5),
    'Go': Color(0xFF00ACD7),
    'Dart': Color(0xFF00B4AB),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[lang] ?? AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 6),
          Text(lang, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.bgSurface,
              ),
              child: Icon(icon, size: 16, color: titleColor ?? AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
