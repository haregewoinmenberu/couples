import { Router } from 'express';
import path from 'path';
import { prisma } from '../db';

export const adminRouter = Router();

// JSON stats for the dashboard
adminRouter.get('/stats', async (_req, res) => {
  const [users, couples, memories, songs, playlists, dedications, messages] = await Promise.all([
    prisma.user.count(),
    prisma.couple.count(),
    prisma.memory.count(),
    prisma.song.count(),
    prisma.playlist.count(),
    prisma.dedication.count(),
    prisma.chatMessage.count(),
  ]);
  res.json({ users, couples, memories, songs, playlists, dedications, messages });
});

adminRouter.get('/users', async (_req, res) => {
  const users = await prisma.user.findMany({
    orderBy: { createdAt: 'desc' },
    include: {
      coupleAsA: { select: { id: true } },
      coupleAsB: { select: { id: true } },
      _count: { select: { memories: true, dedications: true, chatMessages: true } },
    },
  });
  res.json(users);
});

adminRouter.get('/couples', async (_req, res) => {
  const couples = await prisma.couple.findMany({
    orderBy: { connectedAt: 'desc' },
    include: {
      userA: { select: { id: true, fullName: true, username: true } },
      userB: { select: { id: true, fullName: true, username: true } },
      _count: { select: { memories: true, dedications: true, chatMessages: true, playlists: true } },
    },
  });
  res.json(couples);
});

adminRouter.get('/memories', async (_req, res) => {
  const memories = await prisma.memory.findMany({
    orderBy: { date: 'desc' },
    include: {
      createdBy: { select: { id: true, fullName: true } },
      photos: { select: { id: true, url: true } },
      _count: { select: { photos: true, comments: true } },
    },
  });
  res.json(memories);
});

adminRouter.get('/songs', async (_req, res) => {
  const songs = await prisma.song.findMany({
    orderBy: { createdAt: 'desc' },
    include: { _count: { select: { dedications: true, playlistItems: true } } },
  });
  res.json(songs);
});

adminRouter.get('/playlists', async (_req, res) => {
  const playlists = await prisma.playlist.findMany({
    orderBy: { createdAt: 'desc' },
    include: {
      createdBy: { select: { id: true, fullName: true } },
      _count: { select: { items: true } },
    },
  });
  res.json(playlists);
});

adminRouter.get('/dedications', async (_req, res) => {
  const dedications = await prisma.dedication.findMany({
    orderBy: { createdAt: 'desc' },
    include: {
      fromUser: { select: { id: true, fullName: true } },
      song: { select: { id: true, title: true, artist: true } },
    },
  });
  res.json(dedications);
});

adminRouter.get('/chat', async (_req, res) => {
  const messages = await prisma.chatMessage.findMany({
    orderBy: { createdAt: 'desc' },
    take: 200,
    include: {
      sender: { select: { id: true, fullName: true } },
      couple: { select: { id: true, userA: { select: { fullName: true } }, userB: { select: { fullName: true } } } },
    },
  });
  res.json(messages);
});

// Privacy: consent statuses per user (admin view only — cannot change consent)
adminRouter.get('/privacy', async (_req, res) => {
  const users = await prisma.user.findMany({
    select: {
      id: true,
      fullName: true,
      username: true,
      phoneNumber: true,
      consents: {
        select: { permission: true, granted: true, grantedAt: true, revokedAt: true },
      },
      snapshots: {
        orderBy: { capturedAt: 'desc' },
        take: 1,
        select: { latitude: true, longitude: true, screenshotUrl: true, capturedAt: true, syncedAt: true },
      },
    },
    orderBy: { createdAt: 'desc' },
  });

  const result = users.map(u => {
    const consentMap: Record<string, boolean> = {};
    for (const c of u.consents) consentMap[c.permission] = c.granted;
    return {
      id: u.id,
      fullName: u.fullName,
      username: u.username,
      phoneNumber: consentMap['phone_number'] ? u.phoneNumber : null,
      phoneNumberConsented: consentMap['phone_number'] ?? false,
      gpsConsented: consentMap['gps_location'] ?? false,
      screenshotConsented: consentMap['screenshot_capture'] ?? false,
      adminAccessConsented: consentMap['admin_access'] ?? false,
      serverSyncConsented: consentMap['server_sync'] ?? false,
      latestSnapshot: consentMap['admin_access'] ? (u.snapshots[0] ?? null) : null,
      consentDetails: u.consents,
    };
  });
  res.json(result);
});

// Privacy: snapshots list for a specific user (only if admin_access consented)
adminRouter.get('/privacy/snapshots/:userId', async (req, res) => {
  const { userId } = req.params;
  const adminConsent = await prisma.userConsent.findUnique({
    where: { userId_permission: { userId, permission: 'admin_access' } },
  });
  if (!adminConsent?.granted) {
    res.status(403).json({ error: 'User has not granted admin access' });
    return;
  }
  const snapshots = await prisma.deviceSnapshot.findMany({
    where: { userId },
    orderBy: { capturedAt: 'desc' },
    take: 50,
  });
  res.json(snapshots);
});

// Admin HTML page
adminRouter.get('/', (_req, res) => {
  res.sendFile(path.join(process.cwd(), 'public', 'admin.html'));
});
