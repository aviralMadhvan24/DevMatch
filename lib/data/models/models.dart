import 'package:flutter/material.dart';
import 'package:gitforge/core/theme/app_theme.dart';

// ─── Difficulty Enum ──────────────────────────────────────────────────────────

enum Difficulty { easy, medium, hard }

extension DifficultyExt on Difficulty {
  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  Color get color {
    switch (this) {
      case Difficulty.easy:
        return AppColors.diffEasy;
      case Difficulty.medium:
        return AppColors.diffMedium;
      case Difficulty.hard:
        return AppColors.diffHard;
    }
  }

  IconData get icon {
    switch (this) {
      case Difficulty.easy:
        return Icons.trending_flat_rounded;
      case Difficulty.medium:
        return Icons.trending_up_rounded;
      case Difficulty.hard:
        return Icons.local_fire_department_rounded;
    }
  }

  static Difficulty fromString(String s) {
    switch (s.toLowerCase()) {
      case 'easy':
        return Difficulty.easy;
      case 'hard':
        return Difficulty.hard;
      default:
        return Difficulty.medium;
    }
  }
}

// ─── GitHub Issue Model ───────────────────────────────────────────────────────

class GithubIssue {
  final String id;
  final String title;
  final String repoName;
  final String repoOwner;
  final String aiSummary;
  final Difficulty difficulty;
  final List<String> requiredSkills;
  final double matchScore; // 0.0 to 1.0
  final int issueNumber;
  final String githubUrl;
  final String? contributionGuide;
  final DateTime createdAt;
  final int commentsCount;
  final List<String> labels;
  final String? repoLanguage;
  final int repoStars;

  const GithubIssue({
    required this.id,
    required this.title,
    required this.repoName,
    required this.repoOwner,
    required this.aiSummary,
    required this.difficulty,
    required this.requiredSkills,
    required this.matchScore,
    required this.issueNumber,
    required this.githubUrl,
    this.contributionGuide,
    required this.createdAt,
    required this.commentsCount,
    required this.labels,
    this.repoLanguage,
    required this.repoStars,
  });

  factory GithubIssue.fromJson(Map<String, dynamic> json) {
    return GithubIssue(
      id: json['id'] as String,
      title: json['title'] as String,
      repoName: json['repo_name'] as String,
      repoOwner: json['repo_owner'] as String,
      aiSummary: json['ai_summary'] as String,
      difficulty: DifficultyExt.fromString(json['difficulty'] as String),
      requiredSkills: List<String>.from(json['required_skills'] as List),
      matchScore: (json['match_score'] as num).toDouble(),
      issueNumber: json['issue_number'] as int,
      githubUrl: json['github_url'] as String,
      contributionGuide: json['contribution_guide'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      commentsCount: json['comments_count'] as int,
      labels: List<String>.from(json['labels'] as List),
      repoLanguage: json['repo_language'] as String?,
      repoStars: json['repo_stars'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'repo_name': repoName,
        'repo_owner': repoOwner,
        'ai_summary': aiSummary,
        'difficulty': difficulty.label.toLowerCase(),
        'required_skills': requiredSkills,
        'match_score': matchScore,
        'issue_number': issueNumber,
        'github_url': githubUrl,
        'contribution_guide': contributionGuide,
        'created_at': createdAt.toIso8601String(),
        'comments_count': commentsCount,
        'labels': labels,
        'repo_language': repoLanguage,
        'repo_stars': repoStars,
      };

  String get matchPercentage => '${(matchScore * 100).round()}%';
  String get fullRepoName => '$repoOwner/$repoName';
}

// ─── Developer Profile Model ──────────────────────────────────────────────────

class DeveloperProfile {
  final String id;
  final String githubUsername;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final List<SkillEntry> skills;
  final List<String> primaryLanguages;
  final int totalContributions;
  final int publicRepos;
  final int followers;
  final List<String> interests;
  final DateTime joinedAt;

  const DeveloperProfile({
    required this.id,
    required this.githubUsername,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    required this.skills,
    required this.primaryLanguages,
    required this.totalContributions,
    required this.publicRepos,
    required this.followers,
    required this.interests,
    required this.joinedAt,
  });

  factory DeveloperProfile.fromJson(Map<String, dynamic> json) {
    return DeveloperProfile(
      id: json['id'] as String,
      githubUsername: json['github_username'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      skills: (json['skills'] as List)
          .map((s) => SkillEntry.fromJson(s as Map<String, dynamic>))
          .toList(),
      primaryLanguages: List<String>.from(json['primary_languages'] as List),
      totalContributions: json['total_contributions'] as int,
      publicRepos: json['public_repos'] as int,
      followers: json['followers'] as int,
      interests: List<String>.from(json['interests'] as List),
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }
}

class SkillEntry {
  final String name;
  final double proficiency; // 0.0 to 1.0
  final String category;

  const SkillEntry({
    required this.name,
    required this.proficiency,
    required this.category,
  });

  factory SkillEntry.fromJson(Map<String, dynamic> json) {
    return SkillEntry(
      name: json['name'] as String,
      proficiency: (json['proficiency'] as num).toDouble(),
      category: json['category'] as String,
    );
  }
}

// ─── Match Recommendation ─────────────────────────────────────────────────────

class MatchRecommendation {
  final GithubIssue issue;
  final double compatibilityScore;
  final List<String> matchingSkills;
  final String aiReasoning;

  const MatchRecommendation({
    required this.issue,
    required this.compatibilityScore,
    required this.matchingSkills,
    required this.aiReasoning,
  });

  factory MatchRecommendation.fromJson(Map<String, dynamic> json) {
    return MatchRecommendation(
      issue: GithubIssue.fromJson(json['issue'] as Map<String, dynamic>),
      compatibilityScore: (json['compatibility_score'] as num).toDouble(),
      matchingSkills: List<String>.from(json['matching_skills'] as List),
      aiReasoning: json['ai_reasoning'] as String,
    );
  }
}

// ─── Auth State ───────────────────────────────────────────────────────────────

class AuthUser {
  final String token;
  final DeveloperProfile profile;

  const AuthUser({required this.token, required this.profile});
}

// ─── Mock Data ────────────────────────────────────────────────────────────────

class MockData {
  static List<GithubIssue> get sampleIssues => [
        GithubIssue(
          id: '1',
          title: 'Add dark mode support to dashboard components',
          repoName: 'shadcn-ui',
          repoOwner: 'shadcn',
          aiSummary:
              'The dashboard components lack dark mode theming. This requires updating CSS variables and adding theme-aware color tokens across 12 components. Good first contribution for someone familiar with Tailwind CSS.',
          difficulty: Difficulty.easy,
          requiredSkills: ['React', 'TypeScript', 'Tailwind CSS'],
          matchScore: 0.94,
          issueNumber: 2847,
          githubUrl: 'https://github.com/shadcn/shadcn-ui/issues/2847',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          commentsCount: 8,
          labels: ['good first issue', 'enhancement'],
          repoLanguage: 'TypeScript',
          repoStars: 48200,
        ),
        GithubIssue(
          id: '2',
          title: 'Optimize bundle size - tree shake unused icons',
          repoName: 'lucide-react',
          repoOwner: 'lucide-icons',
          aiSummary:
              'Current bundle includes all 1200+ icons even when only a subset is used. Implement proper ESM tree-shaking to reduce bundle size by ~60%. Requires understanding of Rollup build configuration and ESM module system.',
          difficulty: Difficulty.medium,
          requiredSkills: ['JavaScript', 'Rollup', 'Node.js', 'ESM'],
          matchScore: 0.87,
          issueNumber: 1923,
          githubUrl: 'https://github.com/lucide-icons/lucide-react/issues/1923',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          commentsCount: 14,
          labels: ['performance', 'help wanted'],
          repoLanguage: 'JavaScript',
          repoStars: 9800,
        ),
        GithubIssue(
          id: '3',
          title: 'Implement WebSocket reconnection with exponential backoff',
          repoName: 'socket.io-client',
          repoOwner: 'socketio',
          aiSummary:
              'The current reconnection logic uses fixed intervals which causes thundering herd problems. Implement exponential backoff with jitter to reduce server load during mass reconnections. Critical for production deployments.',
          difficulty: Difficulty.hard,
          requiredSkills: ['JavaScript', 'WebSockets', 'Node.js', 'Networking'],
          matchScore: 0.82,
          issueNumber: 567,
          githubUrl: 'https://github.com/socketio/socket.io-client/issues/567',
          createdAt: DateTime.now().subtract(const Duration(days: 8)),
          commentsCount: 22,
          labels: ['bug', 'networking'],
          repoLanguage: 'TypeScript',
          repoStars: 21500,
        ),
        GithubIssue(
          id: '4',
          title: 'Add Python type stubs for better IDE support',
          repoName: 'requests',
          repoOwner: 'psf',
          aiSummary:
              'Add comprehensive PEP 484 type annotations and .pyi stub files to improve IDE autocompletion and static analysis. This is a high-impact contribution that benefits thousands of developers using the library daily.',
          difficulty: Difficulty.medium,
          requiredSkills: ['Python', 'Type Hints', 'mypy'],
          matchScore: 0.91,
          issueNumber: 6142,
          githubUrl: 'https://github.com/psf/requests/issues/6142',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          commentsCount: 5,
          labels: ['enhancement', 'good first issue'],
          repoLanguage: 'Python',
          repoStars: 51200,
        ),
        GithubIssue(
          id: '5',
          title: 'Fix memory leak in event listener cleanup',
          repoName: 'zustand',
          repoOwner: 'pmndrs',
          aiSummary:
              'Event listeners registered by subscriptions are not properly cleaned up when components unmount, causing memory leaks in long-running applications. Fix requires updating the subscription management and adding cleanup logic.',
          difficulty: Difficulty.hard,
          requiredSkills: ['React', 'TypeScript', 'State Management'],
          matchScore: 0.79,
          issueNumber: 892,
          githubUrl: 'https://github.com/pmndrs/zustand/issues/892',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          commentsCount: 31,
          labels: ['bug', 'memory-leak'],
          repoLanguage: 'TypeScript',
          repoStars: 44100,
        ),
      ];

  static DeveloperProfile get sampleProfile => DeveloperProfile(
        id: 'user_1',
        githubUsername: 'dev_coder',
        displayName: 'Alex Developer',
        avatarUrl: 'https://avatars.githubusercontent.com/u/12345678',
        bio: 'Full-stack developer passionate about open source',
        skills: [
          const SkillEntry(
              name: 'TypeScript', proficiency: 0.92, category: 'Language'),
          const SkillEntry(
              name: 'React', proficiency: 0.88, category: 'Framework'),
          const SkillEntry(
              name: 'Python', proficiency: 0.75, category: 'Language'),
          const SkillEntry(
              name: 'Node.js', proficiency: 0.82, category: 'Runtime'),
          const SkillEntry(name: 'Go', proficiency: 0.60, category: 'Language'),
          const SkillEntry(
              name: 'Docker', proficiency: 0.70, category: 'DevOps'),
        ],
        primaryLanguages: ['TypeScript', 'Python', 'Go'],
        totalContributions: 1247,
        publicRepos: 34,
        followers: 89,
        interests: ['Frontend', 'Developer Tools', 'Performance'],
        joinedAt: DateTime(2019, 3, 15),
      );
}
