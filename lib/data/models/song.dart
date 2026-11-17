class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final int artworkSeed;
  final Duration duration;
  final List<String> moods;
  final List<String> genres;
  final bool isEthiopian;
  final String? audioUrl;
  final String? youtubeId;
  final String? thumbnailUrl;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.artworkSeed,
    required this.duration,
    this.moods = const [],
    this.genres = const [],
    this.isEthiopian = false,
    this.audioUrl,
    this.youtubeId,
    this.thumbnailUrl,
  });

  bool get isYouTube => youtubeId != null && youtubeId!.isNotEmpty;

  String get durationLabel {
    final m = duration.inMinutes;
    final s = duration.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  /// A streamable URL for playback. The bundled catalogue uses public-domain
  /// audio from Wikimedia Commons (served with CORS `*`); a song can override
  /// it with its own [audioUrl].
  static const List<String> _demoTracks = [
    'https://upload.wikimedia.org/wikipedia/commons/3/3f/Moonlight_Sonata_%28Sharp_c_minor_Sonata%29_2nd_Movement_Beethoven_JMC%2CHan.ogg',
    'https://upload.wikimedia.org/wikipedia/commons/7/7b/L._Sarason_-_Piano_Sonata_-_Scherzo.ogg',
    'https://upload.wikimedia.org/wikipedia/commons/1/1c/Beethoven_arietta_from_Piano_Sonata_32%2C_bars_96-7.wav',
    'https://upload.wikimedia.org/wikipedia/commons/f/fe/Beethoven_-_Piano_Sonata_No._28_in_A_Major%2C_Op._101_-_I._Etwas_lebhaft%2C_und_mit_der_innigsten_Empfindung.ogg',
    'https://upload.wikimedia.org/wikipedia/commons/b/bb/Beethoven_-_Piano_Sonata_No._28_in_A_Major%2C_Op._101_-_II._Lebhaft._Marschm%C3%A4%C3%9Fig.ogg',
    'https://upload.wikimedia.org/wikipedia/commons/c/c8/Example.ogg',
  ];

  String get playableUrl {
    if (audioUrl != null && audioUrl!.isNotEmpty) return audioUrl!;
    return _demoTracks[artworkSeed.abs() % _demoTracks.length];
  }

  factory Song.fromJson(Map<String, dynamic> j) => Song(
        id: j['id'] as String,
        title: j['title'] as String,
        artist: j['artist'] as String,
        album: j['album'] as String,
        artworkSeed: (j['artworkSeed'] as num?)?.toInt() ?? 0,
        duration: Duration(seconds: (j['durationSecs'] as num?)?.toInt() ?? 0),
        moods: List<String>.from(j['moods'] as List? ?? []),
        genres: List<String>.from(j['genres'] as List? ?? []),
        isEthiopian: j['isEthiopian'] as bool? ?? false,
        audioUrl: j['audioUrl'] as String?,
        youtubeId: j['youtubeId'] as String?,
        thumbnailUrl: j['thumbnailUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'artworkSeed': artworkSeed,
        'durationSecs': duration.inSeconds,
        'moods': moods,
        'genres': genres,
        'isEthiopian': isEthiopian,
        'audioUrl': audioUrl,
        'youtubeId': youtubeId,
        'thumbnailUrl': thumbnailUrl,
      };
}
