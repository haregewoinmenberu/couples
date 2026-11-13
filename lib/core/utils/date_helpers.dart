import 'package:intl/intl.dart';

String formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);

String formatShortDate(DateTime date) => DateFormat('MMM d').format(date);

String formatTime(DateTime dt) => DateFormat('h:mm a').format(dt);

String timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return formatShortDate(dt);
}

String formatDuration(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

String daysTogether(DateTime anniversary) {
  final diff = DateTime.now().difference(anniversary).inDays;
  return diff.toString();
}

String formatAnniversary(DateTime d) =>
    'Since ${DateFormat('MMM d, yyyy').format(d)}';
