import { Router } from 'express';
import { prisma } from '../db';

export const couplesRouter = Router();

couplesRouter.get('/', async (_req, res) => {
  const couples = await prisma.couple.findMany({
    orderBy: { connectedAt: 'desc' },
    include: {
      userA: { select: { id: true, fullName: true, username: true, avatarSeed: true } },
      userB: { select: { id: true, fullName: true, username: true, avatarSeed: true } },
      _count: { select: { memories: true, dedications: true, chatMessages: true, playlists: true } },
    },
  });
  res.json(couples);
});

couplesRouter.get('/:id', async (req, res) => {
  const couple = await prisma.couple.findUnique({
    where: { id: req.params.id },
    include: {
      userA: true,
      userB: true,
      memories: { orderBy: { date: 'desc' } },
      dedications: { orderBy: { createdAt: 'desc' }, include: { song: true, fromUser: { select: { fullName: true } } } },
      playlists: { include: { _count: { select: { items: true } } } },
      _count: { select: { memories: true, dedications: true, chatMessages: true } },
    },
  });
  if (!couple) { res.status(404).json({ error: 'Not found' }); return; }
  res.json(couple);
});

couplesRouter.get('/for-user/:userId', async (req, res) => {
  const { userId } = req.params;
  const couple = await prisma.couple.findFirst({
    where: { OR: [{ userAId: userId }, { userBId: userId }] },
    include: {
      userA: { select: { id: true, fullName: true, username: true, avatarSeed: true, phoneNumber: true } },
      userB: { select: { id: true, fullName: true, username: true, avatarSeed: true, phoneNumber: true } },
    },
  });
  if (!couple) { res.status(404).json({ error: 'Not found' }); return; }
  res.json(couple);
});

couplesRouter.post('/', async (req, res) => {
  const { userAId, userBId, anniversaryDate } = req.body as { userAId: string; userBId: string; anniversaryDate: string };
  const couple = await prisma.couple.create({
    data: { userAId, userBId, anniversaryDate: new Date(anniversaryDate) },
  });
  res.status(201).json(couple);
});
