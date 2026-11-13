import '../models/challenge.dart';

final List<Challenge> mockChallenges = [
  const Challenge(
    id: 'ch1',
    title: 'Guess My Song',
    description: 'Pick a song and see if your partner can guess why you chose it.',
    instructions:
        'Choose a song that means something to you right now. Your partner will try to guess the reason before you reveal it.',
    iconSeed: 0,
  ),
  const Challenge(
    id: 'ch2',
    title: 'Describe Me With a Song',
    description: 'Find the one song that captures your partner perfectly.',
    instructions: 'Pick a song you feel represents your partner\'s personality. Share it and explain why.',
    iconSeed: 1,
  ),
  const Challenge(
    id: 'ch3',
    title: 'Our First Song',
    description: 'Both pick the song you associate with how you met.',
    instructions: 'Independently choose the song that reminds you of the beginning of your story. Compare answers.',
    iconSeed: 2,
  ),
  const Challenge(
    id: 'ch4',
    title: 'Song of the Same Mood',
    description: 'See if you can land on the same emotional wavelength.',
    instructions: 'Pick a song that matches your mood today, without discussing it first.',
    iconSeed: 3,
  ),
  const Challenge(
    id: 'ch5',
    title: 'Dedicate a Song',
    description: 'Surprise your partner with a dedication just because.',
    instructions: 'Choose a song and write a short note dedicating it to your partner for no particular reason.',
    iconSeed: 4,
  ),
  const Challenge(
    id: 'ch6',
    title: 'Guess the Lyrics',
    description: 'Test how well you know each other\'s favorite songs.',
    instructions: 'Share a lyric snippet from a song you love and have your partner guess the title.',
    iconSeed: 5,
  ),
  const Challenge(
    id: 'ch7',
    title: 'Our Music Memories',
    description: 'Recall the songs that were playing during big moments.',
    instructions: 'Write down a song tied to a specific memory together and share what makes it special.',
    iconSeed: 6,
  ),
  const Challenge(
    id: 'ch8',
    title: 'Who Knows Me Better?',
    description: 'Answer questions about each other\'s music taste.',
    instructions: 'Answer a quick question about your own taste, then compare with what your partner guessed.',
    iconSeed: 7,
  ),
];
