import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:gitforge/core/theme/app_theme.dart';
import 'package:gitforge/features/discovery/presentation/providers/app_providers.dart';
import 'package:gitforge/data/models/models.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final List<String> _selectedInterests = ['Frontend', 'Developer Tools'];
  final List<String> _allInterests = [
    'Frontend', 'Backend', 'Mobile', 'DevOps', 'ML/AI',
    'Developer Tools', 'Security', 'Data Engineering', 'Open Source',
    'Documentation', 'Testing', 'Performance',
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profile = authState.profile ?? MockData.sampleProfile;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('Your Dev Profile'),
        actions: [
          TextButton(
            onPressed: () => context.go('/discovery'),
            child: Text(
              'Skip',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(profile).animate().fadeIn(duration: 500.ms),
            const SizedBox(height: 24),
            _buildStatsRow(profile)
                .animate()
                .fadeIn(delay: 100.ms, duration: 500.ms),
            const SizedBox(height: 28),
            _buildSkillsSection(profile)
                .animate()
                .fadeIn(delay: 200.ms, duration: 500.ms),
            const SizedBox(height: 28),
            _buildInterestsSection()
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms),
            const SizedBox(height: 32),
            _buildConfirmButton()
                .animate()
                .fadeIn(delay: 400.ms, duration: 500.ms),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(DeveloperProfile profile) {
    return Container(
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
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(
                colors: AppColors.gradientGreen,
              ),
            ),
            child: Center(
              child: Text(
                profile.displayName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.code_rounded,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '@${profile.githubUsername}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                if (profile.bio != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    profile.bio!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(DeveloperProfile profile) {
    return Row(
      children: [
        _StatCard(
          value: profile.totalContributions.toString(),
          label: 'Contributions',
          icon: Icons.commit_rounded,
        ),
        const SizedBox(width: 10),
        _StatCard(
          value: profile.publicRepos.toString(),
          label: 'Repos',
          icon: Icons.folder_open_rounded,
        ),
        const SizedBox(width: 10),
        _StatCard(
          value: profile.followers.toString(),
          label: 'Followers',
          icon: Icons.people_rounded,
        ),
      ],
    );
  }

  Widget _buildSkillsSection(DeveloperProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome_rounded,
                size: 16, color: AppColors.accentGreen),
            const SizedBox(width: 8),
            Text(
              'Detected Skills',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'AI analyzed',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...profile.skills.map(
          (skill) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SkillBar(skill: skill),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contribution Interests',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Select areas you\'d like to contribute to',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allInterests.map((interest) {
            final isSelected = _selectedInterests.contains(interest);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedInterests.remove(interest);
                  } else {
                    _selectedInterests.add(interest);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isSelected
                      ? AppColors.accentGreen.withOpacity(0.15)
                      : AppColors.bgCard,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentGreen
                        : AppColors.border,
                    width: 1,
                  ),
                ),
                child: Text(
                  interest,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppColors.accentGreen
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: () => context.go('/discovery'),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: AppColors.gradientGreen,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentGreen.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Start Discovering Issues',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.bg,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

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
            Icon(icon, size: 18, color: AppColors.accentBlue),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillBar extends StatelessWidget {
  final SkillEntry skill;

  const _SkillBar({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            skill.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LinearPercentIndicator(
            lineHeight: 6,
            percent: skill.proficiency,
            backgroundColor: AppColors.bgSurface,
            linearGradient: LinearGradient(
              colors: skill.proficiency > 0.8
                  ? AppColors.gradientGreen
                  : AppColors.gradientBlue,
            ),
            barRadius: const Radius.circular(3),
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${(skill.proficiency * 100).round()}%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
