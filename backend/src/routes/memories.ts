import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { prisma } from '../db';

const uploadDir = path.join(process.cwd(), 'uploads', 'memories');
fs.mkdirSync(uploadDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, uploadDir),
  filename: (_req, file, cb) => cb(null, `${Date.now()}-${file.originalname}`),
});
const upload = multer({ storage, limits: { fileSize: 20 * 1024 * 1024 } });

export const memoriesRouter = Router();

memoriesRouter.get('/', async (req, res) => {
  const { coupleId } = req.query;
  const memories = await prisma.memory.findMany({
    where: coupleId ? { coupleId: coupleId as string } : undefined,
    orderBy: { date: 'desc' },
    include: {
      createdBy: { select: { id: true, fullName: true, username: true } },
      photos: true,
      songLinks: { include: { song: { select: { id: true, title: true, artist: true } } } },
      _count: { select: { comments: true, photos: true } },
    },
  });
  res.json(memories);
});

memoriesRouter.get('/:id', async (req, res) => {
  const memory = await prisma.memory.findUnique({
    where: { id: req.params.id },
    include: {
      createdBy: { select: { id: true, fullName: true } },
      photos: true,
      songLinks: { include: { song: true } },
      comments: { orderBy: { createdAt: 'asc' } },
    },
  });
  if (!memory) { res.status(404).json({ error: 'Not found' }); return; }
  res.json(memory);
});

memoriesRouter.post('/', upload.array('photos', 10), async (req, res) => {
  const { title, description, date, location, coupleId, createdByUserId, reactions, songId } = req.body as Record<string, string>;
  const files = (req.files as Express.Multer.File[]) ?? [];

  const memory = await prisma.memory.create({
    data: {
      title,
      description,
      date: new Date(date),
      location: location || null,
      coupleId: coupleId || null,
      createdByUserId,
      reactions: reactions ? (JSON.parse(reactions) as string[]) : [],
      photos: files.length ? {
        create: files.map((f) => ({ url: `/uploads/memories/${f.filename}` })),
      } : undefined,
      songLinks: songId ? { create: [{ songId }] } : undefined,
    },
    include: { photos: true },
  });
  res.status(201).json(memory);
});

memoriesRouter.delete('/:id', async (req, res) => {
  await prisma.memory.delete({ where: { id: req.params.id } });
  res.status(204).end();
});
