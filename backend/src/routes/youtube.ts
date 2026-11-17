import { Router } from 'express';

export const youtubeRouter = Router();

type YtResult = {
  id: string;
  title: string;
  artist: string;
  thumbnail: string;
  url: string;
};

// Keyless YouTube search: read the public results page for video ids, then
// use oEmbed for reliable titles/authors. Nothing is stored on the server.
youtubeRouter.get('/search', async (req, res) => {
  const q = String(req.query.q ?? '').trim();
  if (!q) {
    res.status(400).json({ error: 'q is required' });
    return;
  }

  try {
    const html = await fetch(
      `https://www.youtube.com/results?search_query=${encodeURIComponent(q)}`,
      {
        headers: {
          'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept-Language': 'en-US,en;q=0.9',
        },
      },
    ).then((r) => r.text());

    const ids = [
      ...new Set(
        [...html.matchAll(/"videoId":"([\w-]{11})"/g)].map((m) => m[1]),
      ),
    ].slice(0, 8);

    const results = await Promise.all(
      ids.map(async (id): Promise<YtResult | null> => {
        try {
          const o: any = await fetch(
            `https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=${id}&format=json`,
          ).then((r) => (r.ok ? r.json() : null));
          if (!o) return null;
          return {
            id,
            title: o.title ?? id,
            artist: o.author_name ?? 'YouTube',
            thumbnail: `https://img.youtube.com/vi/${id}/hqdefault.jpg`,
            url: `https://www.youtube.com/watch?v=${id}`,
          };
        } catch {
          return null;
        }
      }),
    );
    res.json(results.filter(Boolean));
  } catch (e: any) {
    res.status(502).json({ error: 'Search unavailable', detail: e.message });
  }
});
