import { Router } from 'express';
import { prisma } from '../db';

export const dedicationsRouter = Router();

dedicationsRouter.get('/', async (req, res) => {
  const { coupleId, fromUserId } = req.query;
  const dedications = await prisma.dedication.findMany({
    where: {
      ...(coupleId ? { coupleId: coupleId as string } : {}),
      ...(fromUserId ? { fromUserId: fromUserId as string } : {}),
    },
    orderBy: { createdAt: 'desc' },
    include: {
      fromUser: { select: { id: true, fullName: true, username: true } },
      song: { select: { id: true, title: true, artist: true, artworkSeed: true } },
    },
  });
  res.json(dedications);
});

dedicationsRouter.get('/:id', async (req, res) => {
  const d = await prisma.dedication.findUnique({
    where: { id: req.params.id },
    include: {
      fromUser: { select: { id: true, fullName: true } },
      song: true,
    },
  });
  if (!d) { res.status(404).json({ error: 'Not found' }); return; }
  res.json(d);
});

dedicationsRouter.post('/', async (req, res) => {
  const { fromUserId, songId, coupleId, type, message, photoSeed, scheduledFor } = req.body as {
    fromUserId: string; songId: string; coupleId?: string; type: string;
    message: string; photoSeed?: number; scheduledFor?: string;
  };
  const dedication = await prisma.dedication.create({
    data: {
      fromUserId, songId, coupleId, type, message,
      photoSeed: photoSeed ?? null,
      scheduledFor: scheduledFor ? new Date(scheduledFor) : null,
      delivered: !scheduledFor,
    },
    include: { song: { select: { title: true, artist: true } } },
  });
  res.status(201).json(dedication);
});

dedicationsRouter.delete('/:id', async (req, res) => {
  await prisma.dedication.delete({ where: { id: req.params.id } });
  res.status(204).end();
});
