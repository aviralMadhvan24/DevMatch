import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitforge/features/discovery/presentation/providers/app_providers.dart';
import 'package:gitforge/features/auth/presentation/screens/login_screen.dart';
import 'package:gitforge/features/profile/presentation/screens/profile_setup_screen.dart';
import 'package:gitforge/features/discovery/presentation/screens/discovery_screen.dart';
import 'package:gitforge/features/saved/presentation/screens/saved_issues_screen.dart';
import 'package:gitforge/features/issue_detail/presentation/screens/issue_detail_screen.dart';
import 'package:gitforge/features/settings/presentation/screens/settings_screen.dart';
import 'package:gitforge/core/presentation/main_shell.dart';
import 'package:gitforge/data/models/models.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoading = authState.status == AuthStatus.loading;
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isLoginRoute = state.matchedLocation == '/login';
      final isProfileSetupRoute = state.matchedLocation == '/profile-setup';

      if (isLoading) return null;
      if (!isAuthenticated && !isLoginRoute) return '/login';
      if (isAuthenticated && isLoginRoute) return '/discovery';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/discovery',
            builder: (context, state) => const DiscoveryScreen(),
          ),
          GoRoute(
            path: '/saved',
            builder: (context, state) => const SavedIssuesScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/issue/:id',
        builder: (context, state) {
          final issue = state.extra as GithubIssue?;
          return IssueDetailScreen(
            issueId: state.pathParameters['id']!,
            issue: issue,
          );
        },
      ),
    ],
  );
});
