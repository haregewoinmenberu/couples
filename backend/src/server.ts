import express from 'express';
import cors from 'cors';
import path from 'path';
import { usersRouter } from './routes/users';
import { couplesRouter } from './routes/couples';
import { memoriesRouter } from './routes/memories';
import { songsRouter } from './routes/songs';
import { playlistsRouter } from './routes/playlists';
import { dedicationsRouter } from './routes/dedications';
import { chatRouter } from './routes/chat';
import { adminRouter } from './routes/admin';
import { privacyRouter } from './routes/privacy';
import { invitationsRouter } from './routes/invitations';
import { youtubeRouter } from './routes/youtube';

const app = express();
const PORT = process.env.PORT ?? 3400;

app.use(cors({ origin: '*' }));
app.use(express.json());

// Static files
app.use('/uploads', express.static(path.join(process.cwd(), 'uploads')));
app.use('/downloads', express.static(path.join(process.cwd(), 'public/downloads')));

// API routes
app.use('/api/users', usersRouter);
app.use('/api/couples', couplesRouter);
app.use('/api/memories', memoriesRouter);
app.use('/api/songs', songsRouter);
app.use('/api/playlists', playlistsRouter);
app.use('/api/dedications', dedicationsRouter);
app.use('/api/chat', chatRouter);

// Admin dashboard (HTML page + JSON API)
app.use('/admin', adminRouter);

// Privacy / consent API
app.use('/api/privacy', privacyRouter);

// Phone-number invitations
app.use('/api/invitations', invitationsRouter);

// YouTube search (keyless, nothing stored)
app.use('/api/youtube', youtubeRouter);

// Health
app.get('/health', (_req, res) => res.json({ ok: true }));

app.listen(PORT, () => {
  console.log(`OurSound API running on http://localhost:${PORT}`);
  console.log(`Admin dashboard: http://localhost:${PORT}/admin`);
});
