import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../state/music_state.dart';
import '../../widgets/player/mini_player.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    _NavItem(label: 'Home', icon: Icons.home_rounded, path: '/home'),
    _NavItem(label: 'Chat', icon: Icons.chat_bubble_rounded, path: '/chat'),
    _NavItem(label: 'Playlists', icon: Icons.library_music_rounded, path: '/playlists'),
    _NavItem(label: 'Memories', icon: Icons.photo_library_rounded, path: '/memories'),
    _NavItem(label: 'Profile', icon: Icons.person_rounded, path: '/profile'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final idx = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (player.hasTrack) const MiniPlayer(),
              SizedBox(
                height: 64,
                child: Row(
                  children: List.generate(_tabs.length, (i) {
                    final tab = _tabs[i];
                    final selected = idx == i;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => context.go(tab.path),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: selected ? 42 : 32,
                              height: selected ? 42 : 32,
                              decoration: BoxDecoration(
                                gradient: selected
                                    ? AppColors.primaryGradient
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                tab.icon,
                                size: selected ? 22 : 20,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tab.label,
                              style: AppTextStyles.small(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String path;
  const _NavItem(
      {required this.label, required this.icon, required this.path});
}
