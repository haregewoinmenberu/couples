import { Router } from 'express';
import { prisma } from '../db';

export const songsRouter = Router();

songsRouter.get('/', async (req, res) => {
  const { genre, mood, isEthiopian, search } = req.query;
  const songs = await prisma.song.findMany({
    where: {
      ...(isEthiopian !== undefined ? { isEthiopian: isEthiopian === 'true' } : {}),
      ...(genre ? { genres: { has: genre as string } } : {}),
      ...(mood ? { moods: { has: mood as string } } : {}),
      ...(search ? {
        OR: [
          { title: { contains: search as string, mode: 'insensitive' } },
          { artist: { contains: search as string, mode: 'insensitive' } },
          { album: { contains: search as string, mode: 'insensitive' } },
        ],
      } : {}),
    },
    orderBy: { createdAt: 'desc' },
    include: { _count: { select: { dedications: true, playlistItems: true } } },
  });
  res.json(songs);
});

songsRouter.get('/:id', async (req, res) => {
  const song = await prisma.song.findUnique({
    where: { id: req.params.id },
    include: {
      dedications: { orderBy: { createdAt: 'desc' }, take: 10, include: { fromUser: { select: { fullName: true } } } },
      _count: { select: { dedications: true, playlistItems: true } },
    },
  });
  if (!song) { res.status(404).json({ error: 'Not found' }); return; }
  res.json(song);
});

songsRouter.post('/', async (req, res) => {
  const { title, artist, album, durationSecs, artworkSeed, moods, genres, isEthiopian } = req.body as {
    title: string; artist: string; album: string; durationSecs: number;
    artworkSeed?: number; moods?: string[]; genres?: string[]; isEthiopian?: boolean;
  };
  const song = await prisma.song.create({
    data: { title, artist, album, durationSecs, artworkSeed: artworkSeed ?? 0, moods: moods ?? [], genres: genres ?? [], isEthiopian: isEthiopian ?? false },
  });
  res.status(201).json(song);
});

songsRouter.delete('/:id', async (req, res) => {
  await prisma.song.delete({ where: { id: req.params.id } });
  res.status(204).end();
});
