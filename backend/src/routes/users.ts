import { Router } from 'express';
import { prisma } from '../db';

export const usersRouter = Router();

usersRouter.get('/', async (_req, res) => {
  const users = await prisma.user.findMany({
    orderBy: { createdAt: 'desc' },
    include: {
      coupleAsA: { select: { id: true, anniversaryDate: true } },
      coupleAsB: { select: { id: true, anniversaryDate: true } },
      _count: { select: { memories: true, dedications: true, chatMessages: true } },
    },
  });
  res.json(users);
});

usersRouter.get('/by-email/:email', async (req, res) => {
  const user = await prisma.user.findUnique({
    where: { email: decodeURIComponent(req.params.email) },
    include: {
      coupleAsA: { include: { userB: { select: { id: true, fullName: true, username: true, avatarSeed: true, phoneNumber: true } } } },
      coupleAsB: { include: { userA: { select: { id: true, fullName: true, username: true, avatarSeed: true, phoneNumber: true } } } },
    },
  });
  if (!user) { res.status(404).json({ error: 'Not found' }); return; }
  res.json(user);
});

usersRouter.get('/by-username/:username', async (req, res) => {
  const user = await prisma.user.findUnique({
    where: { username: req.params.username },
    include: {
      coupleAsA: { include: { userB: { select: { id: true, fullName: true, username: true, avatarSeed: true, phoneNumber: true } } } },
      coupleAsB: { include: { userA: { select: { id: true, fullName: true, username: true, avatarSeed: true, phoneNumber: true } } } },
    },
  });
  if (!user) { res.status(404).json({ error: 'Not found' }); return; }
  res.json(user);
});

usersRouter.get('/:id', async (req, res) => {
  const user = await prisma.user.findUnique({
    where: { id: req.params.id },
    include: {
      coupleAsA: true,
      coupleAsB: true,
      memories: { orderBy: { date: 'desc' }, take: 10 },
      dedications: { orderBy: { createdAt: 'desc' }, take: 10, include: { song: true } },
      _count: { select: { memories: true, dedications: true, chatMessages: true, playlists: true } },
    },
  });
  if (!user) { res.status(404).json({ error: 'Not found' }); return; }
  res.json(user);
});

usersRouter.post('/', async (req, res) => {
  const { fullName, username, email, phoneNumber, countryCode, avatarSeed } = req.body as Record<string, string>;
  const user = await prisma.user.create({
    data: { fullName, username, email, phoneNumber, countryCode: countryCode ?? '+1', avatarSeed: avatarSeed ?? '0' },
  });
  res.status(201).json(user);
});

usersRouter.delete('/:id', async (req, res) => {
  await prisma.user.delete({ where: { id: req.params.id } });
  res.status(204).end();
});
