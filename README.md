# DevMatch — AI-Powered Open Source Contribution Matching

A Flutter mobile application that helps developers discover and contribute to open-source issues using AI-powered matching.

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
│
├── core/
│   ├── constants/
│   │   └── app_constants.dart         # API endpoints, keys, config
│   ├── network/
│   │   └── dio_client.dart            # Dio client + JWT interceptor
│   ├── presentation/
│   │   └── main_shell.dart            # Bottom nav shell
│   ├── router/
│   │   └── app_router.dart            # GoRouter config
│   └── theme/
│       └── app_theme.dart             # Dark theme + color palette
│
├── data/
│   ├── models/
│   │   └── models.dart                # GithubIssue, DeveloperProfile, etc.
│   └── services/
│       └── api_services.dart          # AuthService, ProfileService, IssuesService
│
└── features/
    ├── auth/
    │   └── presentation/screens/
    │       └── login_screen.dart       # GitHub OAuth login
    ├── profile/
    │   └── presentation/screens/
    │       └── profile_setup_screen.dart
    ├── discovery/
    │   └── presentation/
    │       ├── providers/
    │       │   └── app_providers.dart  # Riverpod state
    │       ├── screens/
    │       │   └── discovery_screen.dart  # Swipe UI
    │       └── widgets/
    │           └── issue_card.dart     # Card component
    ├── saved/
    │   └── presentation/screens/
    │       └── saved_issues_screen.dart
    ├── issue_detail/
    │   └── presentation/screens/
    │       └── issue_detail_screen.dart
    └── settings/
        └── presentation/screens/
            └── settings_screen.dart
```

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Dart) |
| State Management | Riverpod 2 |
| Navigation | GoRouter |
| HTTP Client | Dio with JWT interceptor |
| Secure Storage | flutter_secure_storage |
| Swipe UI | swipable_stack |
| Animations | flutter_animate |
| Fonts | google_fonts (Space Grotesk) |
| Progress | percent_indicator |

---

## 🚀 Setup & Run

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Android Studio / Xcode

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/gitforge.git
cd gitforge

# Install dependencies
flutter pub get

# Run code generation (for freezed/json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Run on device/emulator
flutter run
```

### Configuration

Update `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'https://your-api.com/v1';
static const String githubClientId = 'YOUR_GITHUB_CLIENT_ID';
```

---

## 📱 Screens

### 1. Login Screen (`/login`)
- GitHub OAuth button
- Animated background grid with glow orbs
- JWT stored securely via flutter_secure_storage
- Auto-redirects if already authenticated

### 2. Profile Setup (`/profile-setup`)
- Displays AI-detected skills with proficiency bars
- GitHub stats (contributions, repos, followers)
- Interest selection chips
- Redirects to discovery

### 3. Discovery Screen (`/discovery`) ⭐ Main Screen
- SwipableStack with issue cards
- **Swipe right** → saves issue, triggers API call
- **Swipe left** → skips issue
- Real-time SAVE/SKIP overlay indicators
- Action buttons (skip, info, save) below stack

### 4. Issue Card (component)
- Repository name + language + stars
- Match score badge (color-coded: green ≥90%, blue ≥75%)
- AI-generated summary section
- Required skills chips
- Difficulty badge (Easy/Medium/Hard)

### 5. Saved Issues (`/saved`)
- List of liked issues with swipe-in animations
- Open on GitHub button
- View AI Guide button
- Remove from saved

### 6. Issue Detail (`/issue/:id`)
- Overview tab: AI summary, skills, labels, repo info
- AI Guide tab: AI-generated step-by-step contribution guide
  - Renders markdown-like content with styled headers/bullets
  - Loading animation while AI generates
- Start Contributing CTA

### 7. Settings (`/settings`)
- Profile card with avatar
- Stats row
- Skill proficiency bars (animated)
- Language chips
- Notification toggle
- Logout

---

## 🏗 Architecture

### State Management (Riverpod)

```
authProvider          → AuthState (loading/authenticated/unauthenticated)
issuesProvider        → AsyncValue<List<GithubIssue>>
savedIssuesProvider   → AsyncValue<List<GithubIssue>>
selectedIssueProvider → GithubIssue?
contributionGuideProvider(issue) → FutureProvider<String>
```

### API Services

```
AuthService     → loginWithGithub(), getStoredToken(), logout()
ProfileService  → getProfile(), updateInterests()
IssuesService   → getRecommendations(), getSavedIssues(), saveIssue(), skipIssue(), getContributionGuide()
```

### Network (Dio Interceptors)

```
AuthInterceptor    → Attaches JWT Bearer token to all requests
LoggingInterceptor → Logs requests/responses
ErrorInterceptor   → Parses error messages from API responses
```

---

## 🎨 Design System

**Colors:**
- Background: `#0A0E1A` (deep dark navy)
- Card: `#111827`
- Accent Green: `#00FFB2` (primary actions, match scores)
- Accent Blue: `#4D9FFF` (links, secondary)
- Accent Purple: `#8B5CF6` (AI features)

**Typography:** Space Grotesk (Google Fonts)

**Difficulty Colors:**
- Easy: `#00C896` (green)
- Medium: `#FFB800` (amber)
- Hard: `#FF4757` (red)

---

## 🔌 API Integration

Replace mock data in `app_providers.dart` with real API calls:

```dart
// In IssuesNotifier.loadRecommendations():
final issues = await _service.getRecommendations(page: _page);
state = AsyncValue.data(issues);
```

The Dio client automatically attaches JWT tokens from secure storage.

---

## 📦 Building for Production

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```
