import '../models/memory.dart';
import 'mock_people.dart';

final DateTime _now = DateTime.now();

final List<Memory> mockMemories = [
  Memory(
    id: 'm1',
    title: 'Our First Meeting',
    description:
        'We met at the little café on 5th street. You ordered the same coffee as me and we laughed about it for an hour.',
    date: _now.subtract(const Duration(days: 128)),
    location: 'Sunrise Café',
    photoSeeds: [0, 1],
    attachedSongId: 's4',
    createdByUserId: alexId,
    isFavorite: true,
    reactions: const ['❤️', '🥹'],
  ),
  Memory(
    id: 'm2',
    title: 'Our First Trip',
    description: 'Three days at the coast, chasing sunsets and forgetting our phones existed.',
    date: _now.subtract(const Duration(days: 95)),
    location: 'Half Moon Bay',
    photoSeeds: [2, 3, 4],
    attachedSongId: 's7',
    createdByUserId: sophiaId,
    isFavorite: true,
    reactions: const ['❤️', '🌅'],
  ),
  Memory(
    id: 'm3',
    title: 'A Special Evening',
    description: 'You cooked dinner for the first time and the kitchen nearly caught fire. Best meal ever anyway.',
    date: _now.subtract(const Duration(days: 70)),
    location: 'Home',
    photoSeeds: [5],
    attachedSongId: 's16',
    createdByUserId: alexId,
    reactions: const ['😂', '❤️'],
  ),
  Memory(
    id: 'm4',
    title: 'Our Anniversary',
    description: 'One year of us. You surprised me with tickets to the show I had been talking about for months.',
    date: _now.subtract(const Duration(days: 30)),
    location: 'Downtown Theatre',
    photoSeeds: [6, 7],
    attachedSongId: 's3',
    createdByUserId: sophiaId,
    isFavorite: true,
    reactions: const ['❤️', '🎉'],
  ),
  Memory(
    id: 'm5',
    title: 'A Moment I Will Never Forget',
    description: 'Dancing in the kitchen at 2am to no music at all, just us being ridiculous and happy.',
    date: _now.subtract(const Duration(days: 12)),
    location: null,
    photoSeeds: [8],
    attachedSongId: 's6',
    createdByUserId: alexId,
    reactions: const ['❤️'],
  ),
];

Memory memoryById(String id) => mockMemories.firstWhere((m) => m.id == id);
