import { prisma } from './db';

async function main() {
  console.log('Seeding OurSound database...');

  // Users
  const alex = await prisma.user.upsert({
    where: { email: 'alex@oursound.app' },
    update: {},
    create: {
      id: 'user-alex',
      fullName: 'Alex Rivera',
      username: 'alexrivera',
      email: 'alex@oursound.app',
      phoneNumber: '+14155550101',
      countryCode: '+1',
      avatarSeed: '42',
      phoneVerified: true,
    },
  });

  const sophia = await prisma.user.upsert({
    where: { email: 'sophia@oursound.app' },
    update: {},
    create: {
      id: 'user-sophia',
      fullName: 'Sophia Chen',
      username: 'sophiachen',
      email: 'sophia@oursound.app',
      phoneNumber: '+14155550202',
      countryCode: '+1',
      avatarSeed: '17',
      phoneVerified: true,
    },
  });

  // Couple
  const couple = await prisma.couple.upsert({
    where: { userAId: alex.id },
    update: {},
    create: {
      id: 'couple-alexsophia',
      userAId: alex.id,
      userBId: sophia.id,
      anniversaryDate: new Date('2023-07-04'),
    },
  });

  // Songs
  const songs = await Promise.all([
    prisma.song.upsert({ where: { id: 'song-1' }, update: {}, create: { id: 'song-1', title: 'Perfect', artist: 'Ed Sheeran', album: '÷ (Divide)', durationSecs: 263, artworkSeed: 1, moods: ['romantic', 'happy'], genres: ['pop'], isEthiopian: false } }),
    prisma.song.upsert({ where: { id: 'song-2' }, update: {}, create: { id: 'song-2', title: 'All of Me', artist: 'John Legend', album: 'Love in the Future', durationSecs: 269, artworkSeed: 2, moods: ['romantic'], genres: ['rnb'], isEthiopian: false } }),
    prisma.song.upsert({ where: { id: 'song-3' }, update: {}, create: { id: 'song-3', title: 'A Thousand Years', artist: 'Christina Perri', album: 'The Twilight Saga', durationSecs: 285, artworkSeed: 3, moods: ['romantic', 'nostalgic'], genres: ['pop'], isEthiopian: false } }),
    prisma.song.upsert({ where: { id: 'song-4' }, update: {}, create: { id: 'song-4', title: 'Yene Lij', artist: 'Teddy Afro', album: 'Ethiopia', durationSecs: 245, artworkSeed: 4, moods: ['happy', 'romantic'], genres: ['ethiopian'], isEthiopian: true } }),
    prisma.song.upsert({ where: { id: 'song-5' }, update: {}, create: { id: 'song-5', title: 'Lomi Lomi', artist: 'Aster Aweke', album: 'Kabu', durationSecs: 230, artworkSeed: 5, moods: ['nostalgic'], genres: ['ethiopian'], isEthiopian: true } }),
    prisma.song.upsert({ where: { id: 'song-6' }, update: {}, create: { id: 'song-6', title: 'Can\'t Help Falling in Love', artist: 'Elvis Presley', album: 'Blue Hawaii', durationSecs: 182, artworkSeed: 6, moods: ['romantic', 'classic'], genres: ['pop', 'classic'], isEthiopian: false } }),
  ]);

  // Playlist
  const playlist = await prisma.playlist.upsert({
    where: { id: 'playlist-1' },
    update: {},
    create: {
      id: 'playlist-1',
      name: 'Our Songs ♥',
      description: 'The songs that define us',
      coupleId: couple.id,
      createdById: alex.id,
      isShared: true,
    },
  });
  for (const song of songs) {
    await prisma.playlistItem.upsert({
      where: { playlistId_songId: { playlistId: playlist.id, songId: song.id } },
      update: {},
      create: { playlistId: playlist.id, songId: song.id },
    });
  }

  // Memories
  const memories = await Promise.all([
    prisma.memory.upsert({
      where: { id: 'mem-1' },
      update: {},
      create: {
        id: 'mem-1',
        title: 'Our First Meeting',
        description: 'We met at the little café on 5th street. You ordered the same coffee as me and we laughed about it for an hour.',
        date: new Date(Date.now() - 128 * 86400000),
        location: 'Sunrise Café',
        coupleId: couple.id,
        createdByUserId: alex.id,
        reactions: ['❤️', '🥹'],
      },
    }),
    prisma.memory.upsert({
      where: { id: 'mem-2' },
      update: {},
      create: {
        id: 'mem-2',
        title: 'Our First Trip',
        description: 'Three days at the coast, chasing sunsets and forgetting our phones existed.',
        date: new Date(Date.now() - 95 * 86400000),
        location: 'Half Moon Bay',
        coupleId: couple.id,
        createdByUserId: sophia.id,
        reactions: ['❤️', '🌅'],
      },
    }),
    prisma.memory.upsert({
      where: { id: 'mem-3' },
      update: {},
      create: {
        id: 'mem-3',
        title: 'Our Anniversary',
        description: 'One year of us. You surprised me with tickets to the show I had been talking about for months.',
        date: new Date(Date.now() - 30 * 86400000),
        location: 'Downtown Theatre',
        coupleId: couple.id,
        createdByUserId: sophia.id,
        reactions: ['❤️', '🎉'],
      },
    }),
  ]);

  // Dedications
  await Promise.all([
    prisma.dedication.upsert({
      where: { id: 'ded-1' },
      update: {},
      create: {
        id: 'ded-1',
        fromUserId: alex.id,
        songId: songs[0].id,
        coupleId: couple.id,
        type: 'loveYou',
        message: 'This song is us. Every single word.',
        delivered: true,
      },
    }),
    prisma.dedication.upsert({
      where: { id: 'ded-2' },
      update: {},
      create: {
        id: 'ded-2',
        fromUserId: sophia.id,
        songId: songs[3].id,
        coupleId: couple.id,
        type: 'thinkingOfYou',
        message: 'Heard this and immediately thought of you 🧡',
        delivered: true,
      },
    }),
  ]);

  // Chat messages
  await Promise.all([
    prisma.chatMessage.upsert({
      where: { id: 'chat-1' },
      update: {},
      create: { id: 'chat-1', coupleId: couple.id, senderId: alex.id, text: 'Good morning ☀️', type: 'text' },
    }),
    prisma.chatMessage.upsert({
      where: { id: 'chat-2' },
      update: {},
      create: { id: 'chat-2', coupleId: couple.id, senderId: sophia.id, text: 'Good morning! 💕 Miss you', type: 'text' },
    }),
    prisma.chatMessage.upsert({
      where: { id: 'chat-3' },
      update: {},
      create: { id: 'chat-3', coupleId: couple.id, senderId: alex.id, songId: songs[0].id, text: 'This song made me think of you', type: 'song' },
    }),
  ]);

  console.log('✓ Seeded: 2 users, 1 couple, 6 songs, 1 playlist, 3 memories, 2 dedications, 3 chat messages');
}

main()
  .catch((e) => { console.error(e); process.exit(1); })
  .finally(() => prisma.$disconnect());
