import '../models/playlist.dart';
import 'mock_people.dart';

final DateTime _now = DateTime.now();

List<PlaylistSongEntry> _entries(List<String> songIds, {bool alternate = true}) {
  return List.generate(songIds.length, (i) {
    return PlaylistSongEntry(
      songId: songIds[i],
      addedByUserId: alternate && i.isOdd ? sophiaId : alexId,
      addedAt: _now.subtract(Duration(days: songIds.length - i)),
    );
  });
}

final List<Playlist> mockPlaylists = [
  Playlist(
    id: 'pl1',
    title: 'Our Love Songs',
    description: 'The songs that sound like us.',
    coverSeed: 0,
    createdByUserId: alexId,
    createdAt: _now.subtract(const Duration(days: 120)),
    songs: _entries(['s1', 's2', 's3', 's15', 's16', 's10']),
  ),
  Playlist(
    id: 'pl2',
    title: 'Missing You',
    description: 'For the days we are apart.',
    coverSeed: 1,
    createdByUserId: sophiaId,
    createdAt: _now.subtract(const Duration(days: 90)),
    songs: _entries(['s5', 's12', 's13']),
  ),
  Playlist(
    id: 'pl3',
    title: 'First Date',
    description: 'The playlist from the night it all started.',
    coverSeed: 2,
    createdByUserId: alexId,
    createdAt: _now.subtract(const Duration(days: 128)),
    songs: _entries(['s4', 's6', 's14', 's9']),
  ),
  Playlist(
    id: 'pl4',
    title: 'Happy Moments',
    description: 'Every time we could not stop smiling.',
    coverSeed: 3,
    createdByUserId: sophiaId,
    createdAt: _now.subtract(const Duration(days: 60)),
    songs: _entries(['s6', 's11', 's14', 's16', 's9']),
  ),
  Playlist(
    id: 'pl5',
    title: 'Romantic Nights',
    description: null,
    coverSeed: 4,
    createdByUserId: alexId,
    createdAt: _now.subtract(const Duration(days: 45)),
    songs: _entries(['s2', 's15', 's10', 's3']),
  ),
  Playlist(
    id: 'pl6',
    title: 'Songs for the Future',
    description: 'Save these for our next chapter.',
    coverSeed: 5,
    createdByUserId: sophiaId,
    createdAt: _now.subtract(const Duration(days: 10)),
    songs: _entries(['s7', 's8']),
  ),
];

Playlist playlistById(String id) => mockPlaylists.firstWhere((p) => p.id == id);
