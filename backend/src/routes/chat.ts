import { Router } from 'express';
import { prisma } from '../db';

export const chatRouter = Router();

chatRouter.get('/:coupleId', async (req, res) => {
  const { cursor, limit = '50' } = req.query;
  const messages = await prisma.chatMessage.findMany({
    where: { coupleId: req.params.coupleId },
    orderBy: { createdAt: 'desc' },
    take: Number(limit),
    ...(cursor ? { cursor: { id: cursor as string }, skip: 1 } : {}),
    include: {
      sender: { select: { id: true, fullName: true, avatarSeed: true } },
    },
  });
  res.json(messages.reverse());
});

chatRouter.post('/:coupleId', async (req, res) => {
  const { senderId, text, songId, imageUrl, type } = req.body as {
    senderId: string; text?: string; songId?: string; imageUrl?: string; type?: string;
  };
  const message = await prisma.chatMessage.create({
    data: {
      coupleId: req.params.coupleId,
      senderId,
      text: text ?? null,
      songId: songId ?? null,
      imageUrl: imageUrl ?? null,
      type: type ?? 'text',
    },
    include: { sender: { select: { id: true, fullName: true, avatarSeed: true } } },
  });
  res.status(201).json(message);
});

chatRouter.delete('/:coupleId/:messageId', async (req, res) => {
  await prisma.chatMessage.delete({ where: { id: req.params.messageId } });
  res.status(204).end();
});
