class MoodOption {
  final String label;
  final String emoji;

  const MoodOption(this.label, this.emoji);
}

const List<MoodOption> moodOptions = [
  MoodOption('In Love', '😍'),
  MoodOption('Missing You', '🥺'),
  MoodOption('Happy', '😊'),
  MoodOption('Sad', '😢'),
  MoodOption('Relaxed', '😌'),
  MoodOption('Romantic', '💕'),
  MoodOption('Lonely', '🫂'),
  MoodOption('Thinking of You', '💭'),
  MoodOption('Excited', '🤩'),
  MoodOption('Grateful', '🙏'),
];

const List<String> discoveryMoodFilters = [
  'In Love',
  'Happy',
  'Relaxing',
  'Romantic',
  'Missing You',
  'Sad',
  'Lonely',
  'Thinking of You',
];
