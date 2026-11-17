import '../../data/models/song.dart';

/// The backend stores moods as lowercase tags (e.g. "romantic", "nostalgic")
/// while the UI shows friendly labels ("In Love", "Missing You"). These helpers
/// bridge the two so filters and sections actually return songs.
const Map<String, List<String>> _aliases = {
  'inlove': ['inlove', 'romantic', 'love'],
  'romantic': ['romantic', 'love'],
  'happy': ['happy', 'excited'],
  'relaxing': ['relaxing', 'relaxed', 'classic', 'calm'],
  'sad': ['sad', 'nostalgic', 'lonely'],
  'lonely': ['lonely', 'sad', 'nostalgic'],
  'missingyou': ['missingyou', 'nostalgic', 'sad'],
  'thinkingofyou': ['thinkingofyou', 'nostalgic', 'missingyou'],
};

String _key(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');

bool songMatchesMood(Song song, String moodLabel) {
  final wanted = _aliases[_key(moodLabel)] ?? [_key(moodLabel)];
  return song.moods.any((m) => wanted.contains(_key(m)));
}

bool songMatchesAnyMood(Song song, List<String> labels) =>
    labels.any((label) => songMatchesMood(song, label));
