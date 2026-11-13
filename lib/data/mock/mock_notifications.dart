import '../models/app_notification.dart';

final DateTime _now = DateTime.now();

final List<AppNotification> mockNotifications = [
  AppNotification(
    id: 'n1',
    type: NotificationType.songSent,
    title: 'Sophia sent you a song',
    body: 'Perfect — Ed Sheeran',
    createdAt: _now.subtract(const Duration(minutes: 20)),
  ),
  AppNotification(
    id: 'n2',
    type: NotificationType.message,
    title: 'New message from Sophia',
    body: 'Can\'t wait to see you tonight',
    createdAt: _now.subtract(const Duration(minutes: 38)),
  ),
  AppNotification(
    id: 'n3',
    type: NotificationType.memoryAdded,
    title: 'New memory added',
    body: 'Sophia added "Our Anniversary"',
    createdAt: _now.subtract(const Duration(hours: 6)),
    isRead: true,
  ),
  AppNotification(
    id: 'n4',
    type: NotificationType.dedication,
    title: 'You received a dedication',
    body: 'Sophia dedicated "All of Me" to you',
    createdAt: _now.subtract(const Duration(hours: 20)),
    isRead: true,
  ),
  AppNotification(
    id: 'n5',
    type: NotificationType.dailyQuestion,
    title: 'Sophia answered today\'s question',
    body: '"What is your favorite memory together?"',
    createdAt: _now.subtract(const Duration(days: 1, hours: 2)),
    isRead: true,
  ),
  AppNotification(
    id: 'n6',
    type: NotificationType.challengeInvite,
    title: 'New couple challenge',
    body: '"Guess My Song" is ready to play',
    createdAt: _now.subtract(const Duration(days: 2)),
    isRead: true,
  ),
  AppNotification(
    id: 'n7',
    type: NotificationType.reaction,
    title: 'Sophia reacted to a song',
    body: '❤️ on "A Thousand Years"',
    createdAt: _now.subtract(const Duration(days: 3)),
    isRead: true,
  ),
];
