import { Router } from 'express';
import { prisma } from '../db';

export const invitationsRouter = Router();

const inviterSelect = {
  id: true,
  fullName: true,
  username: true,
  avatarSeed: true,
} as const;

// Create an invitation addressed to a phone number.
invitationsRouter.post('/', async (req, res) => {
  const { inviterId, inviteePhone, code, expiresAt } = req.body as {
    inviterId: string;
    inviteePhone: string;
    code?: string;
    expiresAt?: string;
  };
  if (!inviterId || !inviteePhone) {
    res.status(400).json({ error: 'inviterId and inviteePhone are required' });
    return;
  }

  try {
    const invitation = await prisma.invitation.create({
      data: {
        code: code ?? `OS-${Date.now().toString(36).toUpperCase()}`,
        inviterId,
        inviteePhone,
        expiresAt: expiresAt ? new Date(expiresAt) : new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      },
      include: { inviter: { select: inviterSelect } },
    });
    res.status(201).json(invitation);
  } catch (e: any) {
    res.status(409).json({ error: 'Invitation could not be created', detail: e.message });
  }
});

// Find a pending invitation for a device phone number. This is what the
// invitee's app calls on first launch to decide whether they are a couple.
invitationsRouter.get('/by-phone/:phone', async (req, res) => {
  const phone = decodeURIComponent(req.params.phone);
  const invitation = await prisma.invitation.findFirst({
    where: {
      inviteePhone: phone,
      status: 'pending',
      expiresAt: { gt: new Date() },
    },
    orderBy: { createdAt: 'desc' },
    include: { inviter: { select: inviterSelect } },
  });
  if (!invitation) {
    res.status(404).json({ error: 'No invitation for this number' });
    return;
  }
  res.json(invitation);
});

// Invitations created by a user (for status / re-connect flows).
invitationsRouter.get('/by-inviter/:inviterId', async (req, res) => {
  const invitations = await prisma.invitation.findMany({
    where: { inviterId: req.params.inviterId },
    orderBy: { createdAt: 'desc' },
    include: { inviter: { select: inviterSelect } },
  });
  res.json(invitations);
});

invitationsRouter.patch('/:id/accept', async (req, res) => {
  const invitation = await prisma.invitation.update({
    where: { id: req.params.id },
    data: { status: 'accepted' },
    include: { inviter: { select: inviterSelect } },
  });
  res.json(invitation);
});
