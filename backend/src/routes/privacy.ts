import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { prisma } from '../db';

export const privacyRouter = Router();

const VALID_PERMISSIONS = [
  'phone_number',
  'gps_location',
  'screenshot_capture',
  'local_storage',
  'server_sync',
  'admin_access',
] as const;

// GET /api/privacy/consent/:userId — fetch all consent records for a user
privacyRouter.get('/consent/:userId', async (req, res) => {
  const { userId } = req.params;
  const consents = await prisma.userConsent.findMany({ where: { userId } });
  const map: Record<string, boolean> = {};
  for (const p of VALID_PERMISSIONS) map[p] = false;
  for (const c of consents) map[c.permission] = c.granted;
  res.json(map);
});

// POST /api/privacy/consent — grant or revoke a single permission
privacyRouter.post('/consent', async (req, res) => {
  const { userId, permission, granted } = req.body as {
    userId: string;
    permission: string;
    granted: boolean;
  };

  if (!userId || !VALID_PERMISSIONS.includes(permission as any)) {
    res.status(400).json({ error: 'Invalid userId or permission' });
    return;
  }

  const now = new Date();
  const record = await prisma.userConsent.upsert({
    where: { userId_permission: { userId, permission } },
    create: {
      userId,
      permission,
      granted,
      grantedAt: granted ? now : null,
      revokedAt: granted ? null : now,
    },
    update: {
      granted,
      grantedAt: granted ? now : undefined,
      revokedAt: granted ? null : now,
    },
  });
  res.json(record);
});

// Snapshot upload storage
const snapshotDir = path.join(process.cwd(), 'uploads', 'snapshots');
if (!fs.existsSync(snapshotDir)) fs.mkdirSync(snapshotDir, { recursive: true });

const storage = multer.diskStorage({
  destination: snapshotDir,
  filename: (_req, file, cb) => cb(null, `${Date.now()}-${file.originalname}`),
});
const upload = multer({ storage, limits: { fileSize: 5 * 1024 * 1024 } });

// POST /api/privacy/snapshot — upload screenshot + optional GPS location
privacyRouter.post('/snapshot', upload.single('screenshot'), async (req, res) => {
  const { userId, latitude, longitude, capturedAt } = req.body as {
    userId: string;
    latitude?: string;
    longitude?: string;
    capturedAt?: string;
  };

  if (!userId) {
    res.status(400).json({ error: 'userId required' });
    return;
  }

  // Verify user has granted both screenshot_capture and server_sync
  const consents = await prisma.userConsent.findMany({
    where: {
      userId,
      permission: { in: ['screenshot_capture', 'server_sync'] },
      granted: true,
    },
  });
  if (consents.length < 2) {
    res.status(403).json({ error: 'User has not consented to screenshot capture and server sync' });
    return;
  }

  const screenshotUrl = req.file
    ? `/uploads/snapshots/${req.file.filename}`
    : null;

  const snapshot = await prisma.deviceSnapshot.create({
    data: {
      userId,
      latitude: latitude ? parseFloat(latitude) : null,
      longitude: longitude ? parseFloat(longitude) : null,
      screenshotUrl,
      capturedAt: capturedAt ? new Date(capturedAt) : new Date(),
    },
  });
  res.json(snapshot);
});
