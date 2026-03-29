class AppConstants {
  static const String baseUrl = 'http://127.0.0.1:8000/v1';
  static const String githubOAuthUrl = 'https://github.com/login/oauth/authorize';
  static const String githubClientId = 'YOUR_GITHUB_CLIENT_ID';
  static const String jwtStorageKey = 'jwt_token';
  static const String userStorageKey = 'user_data';
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int swipeCardCount = 5;
}

class ApiEndpoints {
  static const String auth = '/auth/github';
  static const String profile = '/profile';
  static const String recommendations = '/recommendations';
  static const String savedIssues = '/saved-issues';
  static const String saveIssue = '/issues/save';
  static const String skipIssue = '/issues/skip';
  static const String contributionGuide = '/issues/{id}/guide';
}

class RouteNames {
  static const String login = '/login';
  static const String profileSetup = '/profile-setup';
  static const String discovery = '/discovery';
  static const String savedIssues = '/saved';
  static const String issueDetail = '/issue/:id';
  static const String settings = '/settings';
}
