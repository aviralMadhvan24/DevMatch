import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gitforge/core/constants/app_constants.dart';
import 'package:gitforge/core/network/dio_client.dart';
import 'package:gitforge/data/models/models.dart';

// ─── Auth Service ─────────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

class AuthService {
  final Ref _ref;
  final _storage = const FlutterSecureStorage();

  AuthService(this._ref);

  Future<AuthUser> loginWithGithub(String code) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.post(ApiEndpoints.auth, data: {'code': code});
    final token = response.data['token'] as String;
    await _storage.write(key: AppConstants.jwtStorageKey, value: token);
    final profile = DeveloperProfile.fromJson(
        response.data['profile'] as Map<String, dynamic>);
    return AuthUser(token: token, profile: profile);
  }

  Future<String?> getStoredToken() =>
      _storage.read(key: AppConstants.jwtStorageKey);

  Future<void> logout() =>
      _storage.delete(key: AppConstants.jwtStorageKey);
}

// ─── Profile Service ──────────────────────────────────────────────────────────

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(ref);
});

class ProfileService {
  final Ref _ref;
  ProfileService(this._ref);

  Future<DeveloperProfile> getProfile() async {
    final dio = _ref.read(dioProvider);
    final response = await dio.get(ApiEndpoints.profile);
    return DeveloperProfile.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DeveloperProfile> updateInterests(List<String> interests) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.patch(
      ApiEndpoints.profile,
      data: {'interests': interests},
    );
    return DeveloperProfile.fromJson(response.data as Map<String, dynamic>);
  }
}

// ─── Issues Service ───────────────────────────────────────────────────────────

final issuesServiceProvider = Provider<IssuesService>((ref) {
  return IssuesService(ref);
});

class IssuesService {
  final Ref _ref;
  IssuesService(this._ref);

  Future<List<GithubIssue>> getRecommendations({int page = 1}) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.get(
      ApiEndpoints.recommendations,
      queryParameters: {'page': page, 'per_page': 10},
    );
    final list = response.data['issues'] as List;
    return list
        .map((e) => GithubIssue.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<GithubIssue>> getSavedIssues() async {
    final dio = _ref.read(dioProvider);
    final response = await dio.get(ApiEndpoints.savedIssues);
    final list = response.data['issues'] as List;
    return list
        .map((e) => GithubIssue.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveIssue(String issueId) async {
    final dio = _ref.read(dioProvider);
    await dio.post(ApiEndpoints.saveIssue, data: {'issue_id': issueId});
  }

  Future<void> skipIssue(String issueId) async {
    final dio = _ref.read(dioProvider);
    await dio.post(ApiEndpoints.skipIssue, data: {'issue_id': issueId});
  }

  Future<String> getContributionGuide(String issueId) async {
    final dio = _ref.read(dioProvider);
    final endpoint =
        ApiEndpoints.contributionGuide.replaceAll('{id}', issueId);
    final response = await dio.get(endpoint);
    return response.data['guide'] as String;
  }
}
