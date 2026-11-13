import { Router } from 'express';
import { prisma } from '../db';

export const playlistsRouter = Router();

playlistsRouter.get('/', async (req, res) => {
  const { coupleId } = req.query;
  const playlists = await prisma.playlist.findMany({
    where: coupleId ? { coupleId: coupleId as string } : undefined,
    orderBy: { createdAt: 'desc' },
    include: {
      createdBy: { select: { id: true, fullName: true } },
      _count: { select: { items: true } },
    },
  });
  res.json(playlists);
});

playlistsRouter.get('/:id', async (req, res) => {
  const pl = await prisma.playlist.findUnique({
    where: { id: req.params.id },
    include: {
      createdBy: { select: { id: true, fullName: true } },
      items: { orderBy: { addedAt: 'asc' }, include: { song: true } },
    },
  });
  if (!pl) { res.status(404).json({ error: 'Not found' }); return; }
  res.json(pl);
});

playlistsRouter.post('/', async (req, res) => {
  const { name, description, coupleId, createdById, isShared } = req.body as {
    name: string; description?: string; coupleId?: string; createdById: string; isShared?: boolean;
  };
  const pl = await prisma.playlist.create({
    data: { name, description, coupleId, createdById, isShared: isShared ?? true },
  });
  res.status(201).json(pl);
});

playlistsRouter.post('/:id/songs', async (req, res) => {
  const { songId } = req.body as { songId: string };
  const item = await prisma.playlistItem.create({
    data: { playlistId: req.params.id, songId },
    include: { song: true },
  });
  res.status(201).json(item);
});

playlistsRouter.delete('/:id/songs/:songId', async (req, res) => {
  await prisma.playlistItem.deleteMany({
    where: { playlistId: req.params.id, songId: req.params.songId },
  });
  res.status(204).end();
});

playlistsRouter.delete('/:id', async (req, res) => {
  await prisma.playlist.delete({ where: { id: req.params.id } });
  res.status(204).end();
});
