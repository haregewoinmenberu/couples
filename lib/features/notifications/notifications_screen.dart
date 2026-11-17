import 'package:flutter/material.dart';
import '../../core/utils/navigation_helpers.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/models/app_notification.dart';
import '../../state/content_state.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final unread = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.safePop(),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Row(
          children: [
            Text('Notifications', style: AppTextStyles.h3()),
            if (unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.rose,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$unread',
                    style: AppTextStyles.small(color: Colors.white)),
              ),
            ],
          ],
        ),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => ref
                  .read(notificationsProvider.notifier)
                  .markAllRead(),
              child: Text('Mark all read',
                  style: AppTextStyles.caption(color: AppColors.rose)),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: notifications.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final n = notifications[i];
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(notificationsProvider.notifier)
                        .markRead(n.id);
                    _handleTap(context, n);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: n.isRead
                          ? AppColors.cardWhite
                          : AppColors.softPink,
                      borderRadius:
                          BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: n.isRead
                            ? AppColors.border
                            : AppColors.rose.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: n.isRead
                                ? AppColors.backgroundSecondary
                                : AppColors.softPink,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _iconFor(n.type),
                            color: AppColors.rose,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.title,
                                  style: AppTextStyles.bodyMedium()),
                              const SizedBox(height: 2),
                              Text(n.body,
                                  style: AppTextStyles.body(
                                      color: AppColors.textSecondary),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(timeAgo(n.createdAt),
                                  style: AppTextStyles.small()),
                            ],
                          ),
                        ),
                        if (!n.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(
                                color: AppColors.rose,
                                shape: BoxShape.circle),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  IconData _iconFor(NotificationType type) {
    return switch (type) {
      NotificationType.songSent => Icons.music_note_rounded,
      NotificationType.message => Icons.chat_bubble_rounded,
      NotificationType.playlistUpdated => Icons.playlist_play_rounded,
      NotificationType.memoryAdded => Icons.photo_library_rounded,
      NotificationType.dedication => Icons.favorite_rounded,
      NotificationType.challengeInvite => Icons.sports_esports_rounded,
      NotificationType.dailyQuestion => Icons.help_outline_rounded,
      NotificationType.reaction => Icons.emoji_emotions_rounded,
    };
  }

  void _handleTap(BuildContext context, AppNotification n) {
    switch (n.type) {
      case NotificationType.songSent:
      case NotificationType.dedication:
        context.push('/music');
      case NotificationType.message:
        context.go('/chat');
      case NotificationType.playlistUpdated:
        context.push('/playlists');
      case NotificationType.memoryAdded:
        context.go('/memories');
      case NotificationType.challengeInvite:
        context.push('/challenges');
      case NotificationType.dailyQuestion:
        context.push('/questions');
      default:
        break;
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_none_rounded,
              size: 60, color: AppColors.textSecondary),
          const SizedBox(height: 14),
          Text('No notifications yet',
              style: AppTextStyles.h3(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text('You\'re all caught up!',
              style: AppTextStyles.body(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
