import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitforge/data/models/models.dart';
import 'package:gitforge/data/services/api_services.dart';

// ─── Auth Provider ────────────────────────────────────────────────────────────

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final DeveloperProfile? profile;
  final String? error;

  const AuthState({
    required this.status,
    this.profile,
    this.error,
  });

  const AuthState.loading() : this(status: AuthStatus.loading);
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  AuthState copyWith({
    AuthStatus? status,
    DeveloperProfile? profile,
    String? error,
  }) =>
      AuthState(
        status: status ?? this.status,
        profile: profile ?? this.profile,
        error: error ?? this.error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final ProfileService _profileService;

  AuthNotifier(this._authService, this._profileService)
      : super(const AuthState.loading()) {
    _init();
  }

  Future<void> _init() async {
    final token = await _authService.getStoredToken();
    if (token != null) {
      try {
        // In production, validate token and fetch profile
        state = AuthState(
          status: AuthStatus.authenticated,
          profile: MockData.sampleProfile, // Replace with actual API call
        );
      } catch (_) {
        state = const AuthState.unauthenticated();
      }
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> loginWithGithub(String code) async {
    try {
      state = const AuthState.loading();
      // Mock login for demo
      await Future.delayed(const Duration(seconds: 2));
      state = AuthState(
        status: AuthStatus.authenticated,
        profile: MockData.sampleProfile,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState.unauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authServiceProvider),
    ref.read(profileServiceProvider),
  );
});

// ─── Issues Provider ──────────────────────────────────────────────────────────

class IssuesNotifier extends StateNotifier<AsyncValue<List<GithubIssue>>> {
  final IssuesService _service;
  int _page = 1;

  IssuesNotifier(this._service) : super(const AsyncValue.loading()) {
    loadRecommendations();
  }

  Future<void> loadRecommendations({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      state = const AsyncValue.loading();
    }
    try {
      // Use mock data for demo
      await Future.delayed(const Duration(milliseconds: 800));
      state = AsyncValue.data(MockData.sampleIssues);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void removeIssue(String id) {
    state.whenData((issues) {
      state = AsyncValue.data(issues.where((i) => i.id != id).toList());
    });
  }

  Future<void> saveIssue(String id) async {
    removeIssue(id);
    try {
      await _service.saveIssue(id);
    } catch (_) {}
  }

  Future<void> skipIssue(String id) async {
    removeIssue(id);
    try {
      await _service.skipIssue(id);
    } catch (_) {}
  }
}

final issuesProvider =
    StateNotifierProvider<IssuesNotifier, AsyncValue<List<GithubIssue>>>((ref) {
  return IssuesNotifier(ref.read(issuesServiceProvider));
});

// ─── Saved Issues Provider ────────────────────────────────────────────────────

class SavedIssuesNotifier
    extends StateNotifier<AsyncValue<List<GithubIssue>>> {
  final IssuesService _service;
  final List<GithubIssue> _localSaved = [];

  SavedIssuesNotifier(this._service) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      state = AsyncValue.data([...MockData.sampleIssues.take(2)]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void addSavedIssue(GithubIssue issue) {
    state.whenData((issues) {
      if (!issues.any((i) => i.id == issue.id)) {
        state = AsyncValue.data([issue, ...issues]);
      }
    });
  }

  void removeSavedIssue(String id) {
    state.whenData((issues) {
      state = AsyncValue.data(issues.where((i) => i.id != id).toList());
    });
  }
}

final savedIssuesProvider =
    StateNotifierProvider<SavedIssuesNotifier, AsyncValue<List<GithubIssue>>>(
        (ref) {
  return SavedIssuesNotifier(ref.read(issuesServiceProvider));
});

// ─── Selected Issue Provider ──────────────────────────────────────────────────

final selectedIssueProvider = StateProvider<GithubIssue?>((ref) => null);

// ─── Contribution Guide Provider ─────────────────────────────────────────────

final contributionGuideProvider =
    FutureProvider.family<String, String>((ref, issueId) async {
  await Future.delayed(const Duration(seconds: 2));
  return '''## Contribution Guide

### Getting Started
1. Fork the repository to your GitHub account
2. Clone your fork locally: `git clone https://github.com/YOUR_USERNAME/REPO`
3. Create a new branch: `git checkout -b fix/issue-$issueId`

### Understanding the Issue
This issue requires you to implement changes across multiple components. The AI analysis suggests starting with the core utility functions before modifying the UI layer.

### Implementation Steps
1. **Setup Development Environment**
   - Run `npm install` to install dependencies
   - Copy `.env.example` to `.env` and configure
   
2. **Locate Relevant Files**
   - Primary: `src/components/Dashboard/`
   - Tests: `src/__tests__/Dashboard.test.tsx`
   
3. **Make Your Changes**
   - Follow existing code patterns and conventions
   - Add appropriate TypeScript types
   - Write unit tests for new functionality

4. **Testing**
   - Run `npm test` to ensure all tests pass
   - Test manually in your local environment

5. **Submit Pull Request**
   - Push your branch and create a PR
   - Reference the issue number in your PR description
   - Respond to reviewer feedback promptly

### Resources
- [Project Contributing Guide](https://github.com/repo/CONTRIBUTING.md)
- [Code Style Guide](https://github.com/repo/docs/style-guide.md)
- Related PR: #1842 (for context)
''';
});
