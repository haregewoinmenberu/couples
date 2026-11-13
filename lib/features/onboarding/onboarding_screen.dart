import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../widgets/common/primary_button.dart';

class _OnboardPage {
  final String title;
  final String subtitle;
  final int seed;
  final IconData icon;

  const _OnboardPage(
      {required this.title,
      required this.subtitle,
      required this.seed,
      required this.icon});
}

const _pages = [
  _OnboardPage(
    title: 'Music brings hearts closer.',
    subtitle:
        'Share songs, feelings, and special moments with the person you love.',
    seed: 0,
    icon: Icons.favorite_rounded,
  ),
  _OnboardPage(
    title: 'Every song tells a story.',
    subtitle:
        'Create playlists, send music messages, and save your favorite memories together.',
    seed: 2,
    icon: Icons.playlist_play_rounded,
  ),
  _OnboardPage(
    title: 'Your own world for two.',
    subtitle:
        'Connect with your partner and build a shared musical journey.',
    seed: 5,
    icon: Icons.people_rounded,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _ctrl.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut);
    } else {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () => context.go('/welcome'),
                  child: Text('Skip',
                      style: AppTextStyles.body(
                          color: AppColors.textSecondary)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _OnboardPageView(page: _pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _page ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _page
                              ? AppColors.rose
                              : AppColors.border,
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: _page == _pages.length - 1 ? 'Get Started' : 'Next',
                    onTap: _next,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPageView extends StatelessWidget {
  final _OnboardPage page;
  const _OnboardPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              gradient: artworkGradient(page.seed),
              borderRadius: BorderRadius.circular(40),
            ),
            child:
                Icon(page.icon, color: Colors.white, size: 72),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: AppTextStyles.h1(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            page.subtitle,
            style:
                AppTextStyles.bodyLarge(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
