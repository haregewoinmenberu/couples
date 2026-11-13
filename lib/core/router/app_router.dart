import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/app_state.dart';

// Onboarding & Auth
import '../../features/onboarding/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/welcome_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/create_account_screen.dart';
import '../../features/auth/profile_setup_screen.dart';
import '../../features/auth/phone_verify_screen.dart';

// Connection / Invitation
import '../../features/connection/invite_method_screen.dart';
import '../../features/connection/qr_invitation_screen.dart';
import '../../features/connection/invite_by_phone_screen.dart';
import '../../features/connection/join_partner_screen.dart';
import '../../features/connection/otp_verify_screen.dart';
import '../../features/connection/connection_success_screen.dart';
import '../../features/connection/already_connected_screen.dart';

// Main shell
import '../../features/home/main_shell.dart';

// Home
import '../../features/home/home_screen.dart';

// Chat
import '../../features/chat/chat_screen.dart';

// Music
import '../../features/music/music_discovery_screen.dart';
import '../../features/player/player_screen.dart';

// Playlists
import '../../features/playlists/playlists_screen.dart';
import '../../features/playlists/playlist_detail_screen.dart';

// Memories
import '../../features/memories/memories_screen.dart';
import '../../features/memories/add_memory_screen.dart';
import '../../features/memories/memory_detail_screen.dart';

// Mood
import '../../features/mood/mood_screen.dart';

// Daily Questions
import '../../features/questions/questions_screen.dart';

// Challenges
import '../../features/challenges/challenges_screen.dart';
import '../../features/challenges/challenge_detail_screen.dart';

// Dedication
import '../../features/dedication/dedication_screen.dart';

// Listen Together
import '../../features/listen_together/listen_together_screen.dart';

// Stats
import '../../features/stats/stats_screen.dart';

// Profile
import '../../features/profile/profile_screen.dart';

// Settings
import '../../features/settings/settings_screen.dart';

// Privacy
import '../../features/privacy/privacy_screen.dart';

// Notifications
import '../../features/notifications/notifications_screen.dart';

// Favorites
import '../../features/favorites/favorites_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final authenticated = session.isAuthenticated;
      final onAuthPath = state.matchedLocation.startsWith('/auth') ||
          state.matchedLocation.startsWith('/onboarding') ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation.startsWith('/connection');

      if (!authenticated && !onAuthPath) return '/welcome';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: '/auth/create',
          builder: (_, __) => const CreateAccountScreen()),
      GoRoute(
          path: '/auth/profile',
          builder: (_, __) => const ProfileSetupScreen()),
      GoRoute(
          path: '/auth/phone-verify',
          builder: (_, __) => const PhoneVerifyScreen()),

      // Connection flow
      GoRoute(
          path: '/connection/invite',
          builder: (_, __) => const InviteMethodScreen()),
      GoRoute(
          path: '/connection/invite/qr',
          builder: (_, __) => const QRInvitationScreen()),
      GoRoute(
          path: '/connection/invite/phone',
          builder: (_, __) => const InviteByPhoneScreen()),
      GoRoute(
          path: '/connection/join',
          builder: (_, __) => const JoinPartnerScreen()),
      GoRoute(
          path: '/connection/otp',
          builder: (_, state) => OTPVerifyScreen(
                phone: state.extra as String? ?? '',
              )),
      GoRoute(
          path: '/connection/success',
          builder: (_, __) => const ConnectionSuccessScreen()),
      GoRoute(
          path: '/connection/already',
          builder: (_, __) => const AlreadyConnectedScreen()),

      // Main shell with bottom nav
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
          GoRoute(
              path: '/music', builder: (_, __) => const MusicDiscoveryScreen()),
          GoRoute(
              path: '/memories',
              builder: (_, __) => const MemoriesScreen()),
          GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // Player (full-screen, outside shell)
      GoRoute(
          path: '/player',
          builder: (_, state) =>
              PlayerScreen(songId: state.extra as String? ?? 's1')),

      // Playlists
      GoRoute(
          path: '/playlists',
          builder: (_, __) => const PlaylistsScreen()),
      GoRoute(
          path: '/playlists/:id',
          builder: (_, state) =>
              PlaylistDetailScreen(playlistId: state.pathParameters['id']!)),

      // Memory detail / add
      GoRoute(
          path: '/memories/add',
          builder: (_, __) => const AddMemoryScreen()),
      GoRoute(
          path: '/memories/:id',
          builder: (_, state) =>
              MemoryDetailScreen(memoryId: state.pathParameters['id']!)),

      // Extra feature screens
      GoRoute(path: '/mood', builder: (_, __) => const MoodScreen()),
      GoRoute(
          path: '/questions',
          builder: (_, __) => const QuestionsScreen()),
      GoRoute(
          path: '/challenges',
          builder: (_, __) => const ChallengesScreen()),
      GoRoute(
          path: '/challenges/:id',
          builder: (_, state) => ChallengeDetailScreen(
              challengeId: state.pathParameters['id']!)),
      GoRoute(
          path: '/dedication',
          builder: (_, __) => const DedicationScreen()),
      GoRoute(
          path: '/listen-together',
          builder: (_, __) => const ListenTogetherScreen()),
      GoRoute(path: '/stats', builder: (_, __) => const StatsScreen()),
      GoRoute(
          path: '/settings',
          builder: (_, __) => const SettingsScreen()),
      GoRoute(
          path: '/notifications',
          builder: (_, __) => const NotificationsScreen()),
      GoRoute(
          path: '/favorites',
          builder: (_, __) => const FavoritesScreen()),
      GoRoute(
          path: '/privacy',
          builder: (_, __) => const PrivacyScreen()),
    ],
  );
});
