import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gitforge/core/theme/app_theme.dart';
import 'package:gitforge/features/discovery/presentation/providers/app_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;

  Future<void> _loginWithGithub() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).loginWithGithub('mock_code');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Background grid pattern
          Positioned.fill(child: _BackgroundGrid()),
          // Glow orbs
          Positioned(
            top: -100,
            right: -80,
            child: _GlowOrb(color: AppColors.accentGreen, size: 300),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: _GlowOrb(color: AppColors.accentBlue, size: 250),
          ),
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),
                  // Logo & branding
                  _buildBranding(),
                  const Spacer(flex: 1),
                  // Feature highlights
                  _buildFeatures(),
                  const Spacer(flex: 2),
                  // Auth button
                  _buildAuthButton(),
                  const SizedBox(height: 16),
                  _buildDisclaimer(),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: AppColors.gradientGreen,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(
            Icons.hub_rounded,
            color: AppColors.bg,
            size: 32,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.8, 0.8)),
        const SizedBox(height: 24),
        Text(
          'DevMatch',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 40,
                letterSpacing: -1,
              ),
        )
            .animate()
            .fadeIn(delay: 100.ms, duration: 600.ms)
            .slideX(begin: -0.2, end: 0),
        const SizedBox(height: 8),
        Text(
          'AI-powered open source\ncontribution matching.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.5,
              ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms)
            .slideX(begin: -0.2, end: 0),
      ],
    );
  }

  Widget _buildFeatures() {
    final features = [
      ('🎯', 'Smart Matching', 'Issues matched to your exact skill set'),
      ('🤖', 'AI Summaries', 'Instant understanding of any issue'),
      ('⚡', 'Quick Start', 'Contribution guides generated for you'),
    ];

    return Column(
      children: features
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FeatureRow(
                emoji: entry.value.$1,
                title: entry.value.$2,
                description: entry.value.$3,
              )
                  .animate()
                  .fadeIn(delay: (300 + entry.key * 100).ms, duration: 500.ms)
                  .slideX(begin: -0.15, end: 0),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAuthButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _loginWithGithub,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.textPrimary,
          boxShadow: [
            BoxShadow(
              color: AppColors.accentGreen.withOpacity(0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.bg,
                ),
              )
            else ...[
              _GithubIcon(),
              const SizedBox(width: 12),
              Text(
                'Continue with GitHub',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.bg,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 500.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildDisclaimer() {
    return Center(
      child: Text(
        'We only request read access to your public repos',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
        textAlign: TextAlign.center,
      ),
    ).animate().fadeIn(delay: 800.ms, duration: 500.ms);
  }
}

class _FeatureRow extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;

  const _FeatureRow({
    required this.emoji,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 13,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withOpacity(0.4)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _GithubIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.code_rounded,
      color: AppColors.bg,
      size: 20,
    );
  }
}
