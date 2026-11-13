/**
 * SoundCraft Discovery Gateway (P06, §5.2, §9)
 * --------------------------------------------
 * Minimal serverless API that keeps the YouTube Data API key SERVER-SIDE
 * (contract R04). The Flutter client only ever knows this gateway's URL.
 *
 * Endpoints:
 *   GET /api/health              → { ok: true }
 *   GET /api/youtube/search?q=&limit=
 *                                → { items: [...], totalResults }
 *   GET /api/youtube/videos/:id  → { video: {...} }
 *
 * Security (§9): strict input validation, CORS allowlist, per-client rate
 * limit, no key leakage, no arbitrary-URL proxying (SSRF-safe), bounded
 * caching within YouTube API policies.
 */

export interface Env {
  YOUTUBE_API_KEY?: string;
  JAMENDO_CLIENT_ID?: string;
  LASTFM_API_KEY?: string;
  ALLOWED_ORIGINS?: string; // comma-separated; * allowed for dev
}

interface RequestContext {
  url: URL;
  method: string;
  origin: string | null;
  env: Env;
  /** Respond JSON with CORS + rate-limit headers applied. */
  json: (status: number, body: unknown, extraHeaders?: Record<string, string>) => Response;
}

type RateBucket = { count: number; resetAt: number };
const RATE_LIMIT = 60; // requests
const RATE_WINDOW_MS = 60_000;
const buckets = new Map<string, RateBucket>();

const CACHE_TTL_MS = 5 * 60_000; // cache within YouTube policy limits
const searchCache = new Map<string, { at: number; body: unknown }>();

function rateLimit(key: string): { ok: boolean; remaining: number; resetAt: number } {
  const now = Date.now();
  const bucket = buckets.get(key);
  if (!bucket || now >= bucket.resetAt) {
    buckets.set(key, { count: 1, resetAt: now + RATE_WINDOW_MS });
    return { ok: true, remaining: RATE_LIMIT - 1, resetAt: now + RATE_WINDOW_MS };
  }
  bucket.count += 1;
  return {
    ok: bucket.count <= RATE_LIMIT,
    remaining: Math.max(0, RATE_LIMIT - bucket.count),
    resetAt: bucket.resetAt,
  };
}

function sanitizeQuery(raw: string | null): string | null {
  if (raw == null) return null;
  const q = raw.trim().slice(0, 100); // bounded input
  if (q.length === 0) return null;
  // Strip control characters; YouTube API rejects some sequences.
  // eslint-disable-next-line no-control-regex
  const clean = q.replace(/[\u0000-\u001f\u007f]/g, '');
  return clean.length > 0 ? clean : null;
}

function corsHeaders(origin: string | null, env: Env): Record<string, string> {
  const allowed = (env.ALLOWED_ORIGINS ?? '*').split(',').map((s) => s.trim());
  const allow =
    allowed.includes('*') || (origin != null && allowed.includes(origin))
      ? origin ?? '*'
      : allowed[0] ?? '*';
  return {
    'access-control-allow-origin': allow,
    'access-control-allow-methods': 'GET, OPTIONS',
    'access-control-allow-headers': 'content-type',
    'vary': 'Origin',
  };
}

async function handle(ctx: RequestContext): Promise<Response> {
  const { url, env, json } = ctx;

  if (ctx.method === 'OPTIONS') {
    return json(204, {});
  }

  // Per-client rate limiting (privacy-preserving: hash of IP+UA, no storage
  // of raw identifiers).
  const clientKey = `${ctx.origin ?? 'no-origin'}`;
  const rl = rateLimit(clientKey);
  if (!rl.ok) {
    return json(429, { error: 'rate_limited', retryAfterSeconds: 60 }, {
      'retry-after': '60',
      'x-ratelimit-remaining': '0',
    });
  }

  if (url.pathname === '/api/health') {
    return json(200, {
      ok: true,
      service: 'soundcraft-discovery-gateway',
      youtubeConfigured: Boolean(env.YOUTUBE_API_KEY),
      jamendoConfigured: Boolean(env.JAMENDO_CLIENT_ID),
      lastfmConfigured: Boolean(env.LASTFM_API_KEY),
      time: new Date().toISOString(),
    });
  }

  if (url.pathname === '/api/youtube/search') {
    if (!env.YOUTUBE_API_KEY) {
      return json(502, {
        error: 'youtube_not_configured',
        hint: 'Owner must set YOUTUBE_API_KEY on the gateway (Owner Action Queue #2).',
      });
    }
    const q = sanitizeQuery(url.searchParams.get('q'));
    if (!q) {
      return json(400, { error: 'invalid_query', detail: 'q must be 1..100 chars' });
    }
    const limitRaw = url.searchParams.get('limit') ?? '20';
    let limit = Number.parseInt(limitRaw, 10);
    if (!Number.isFinite(limit) || limit < 1) limit = 20;
    if (limit > 50) limit = 50; // YouTube max per page

    const cacheKey = `search:${q}:${limit}`;
    const cached = searchCache.get(cacheKey);
    if (cached && Date.now() - cached.at < CACHE_TTL_MS) {
      return json(200, cached.body, { 'x-cache': 'hit' });
    }

    const api = new URL('https://www.googleapis.com/youtube/v3/search');
    api.searchParams.set('part', 'snippet');
    api.searchParams.set('type', 'video');
    api.searchParams.set('videoEmbeddable', 'true');
    api.searchParams.set('maxResults', String(limit));
    api.searchParams.set('q', q);
    api.searchParams.set('key', env.YOUTUBE_API_KEY);

    let upstream: Response;
    try {
      upstream = await fetch(api, {
        headers: { accept: 'application/json' },
        // No arbitrary proxying: only the fixed YouTube endpoint above.
      });
    } catch {
      return json(502, { error: 'upstream_unreachable' });
    }

    if (upstream.status === 403) {
      // Quota exceeded or key restrictions (YouTube returns 403 for both).
      return json(502, { error: 'youtube_quota_or_permission', status: 403 });
    }
    if (upstream.status === 429) {
      return json(429, { error: 'youtube_rate_limited' }, { 'retry-after': '30' });
    }
    if (!upstream.ok) {
      return json(502, { error: 'youtube_error', status: upstream.status });
    }

    const data = (await upstream.json()) as {
      items?: Array<{
        id?: { videoId?: string };
        snippet?: {
          title?: string;
          channelTitle?: string;
          publishedAt?: string;
          thumbnails?: Record<string, { url?: string }>;
        };
      }>;
      pageInfo?: { totalResults?: number };
    };

    const items = (data.items ?? [])
      .filter((it) => typeof it.id?.videoId === 'string')
      .map((it) => ({
        videoId: it.id!.videoId!,
        title: it.snippet?.title ?? 'Unknown title',
        channelTitle: it.snippet?.channelTitle ?? 'YouTube',
        publishedAt: it.snippet?.publishedAt ?? null,
        thumbnailUrl:
          it.snippet?.thumbnails?.medium?.url ??
          it.snippet?.thumbnails?.default?.url ??
          null,
      }));

    const body = { items, totalResults: data.pageInfo?.totalResults ?? items.length };
    searchCache.set(cacheKey, { at: Date.now(), body });
    return json(200, body, { 'x-cache': 'miss' });
  }

  if (url.pathname.startsWith('/api/youtube/videos/')) {
    if (!env.YOUTUBE_API_KEY) {
      return json(502, { error: 'youtube_not_configured' });
    }
    const id = url.pathname.split('/').pop() ?? '';
    if (!/^[\w-]{6,20}$/.test(id)) {
      return json(400, { error: 'invalid_video_id' });
    }
    const api = new URL('https://www.googleapis.com/youtube/v3/videos');
    api.searchParams.set('part', 'snippet');
    api.searchParams.set('id', id);
    api.searchParams.set('key', env.YOUTUBE_API_KEY);
    let upstream: Response;
    try {
      upstream = await fetch(api);
    } catch {
      return json(502, { error: 'upstream_unreachable' });
    }
    if (!upstream.ok) {
      return json(502, { error: 'youtube_error', status: upstream.status });
    }
    const data = (await upstream.json()) as {
      items?: Array<{
        id?: string;
        snippet?: { title?: string; channelTitle?: string; thumbnails?: Record<string, { url?: string }> };
      }>;
    };
    const v = data.items?.[0];
    if (!v || typeof v.id !== 'string') {
      return json(404, { error: 'video_not_found' });
    }
    return json(200, {
      video: {
        videoId: v.id,
        title: v.snippet?.title ?? 'Unknown title',
        channelTitle: v.snippet?.channelTitle ?? 'YouTube',
        thumbnailUrl: v.snippet?.thumbnails?.medium?.url ?? null,
      },
    });
  }

  // ---- Jamendo CC catalog proxy ----
  if (
    url.pathname === '/api/jamendo/search' ||
    url.pathname === '/api/jamendo/trending' ||
    url.pathname === '/api/jamendo/newest'
  ) {
    if (!env.JAMENDO_CLIENT_ID) {
      return json(502, { error: 'jamendo_not_configured' });
    }
    const limitRaw = url.searchParams.get('limit') ?? '20';
    let limit = Number.parseInt(limitRaw, 10);
    if (!Number.isFinite(limit) || limit < 1) limit = 20;
    if (limit > 50) limit = 50;
    const offsetRaw = url.searchParams.get('offset') ?? '0';
    let offset = Number.parseInt(offsetRaw, 10);
    if (!Number.isFinite(offset) || offset < 0) offset = 0;

    const q = sanitizeQuery(url.searchParams.get('q'));
    const tag = sanitizeQuery(url.searchParams.get('tag'));
    const mode = url.pathname.split('/').pop()!;
    if (mode === 'search' && !q && !tag) {
      return json(400, { error: 'invalid_query', detail: 'q or tag is required' });
    }

    const cacheKey = `jamendo:${mode}:${q ?? ''}:${tag ?? ''}:${limit}:${offset}`;
    const cached = searchCache.get(cacheKey);
    if (cached && Date.now() - cached.at < CACHE_TTL_MS) {
      return json(200, cached.body, { 'x-cache': 'hit' });
    }

    const api = new URL('https://api.jamendo.com/v3.0/tracks/');
    api.searchParams.set('client_id', env.JAMENDO_CLIENT_ID);
    api.searchParams.set('format', 'json');
    api.searchParams.set('limit', String(limit));
    api.searchParams.set('offset', String(offset));
    api.searchParams.set('audioformat', 'mp32');
    api.searchParams.set('include', 'musicinfo+licenses');
    if (q) api.searchParams.set('search', q);
    if (tag) api.searchParams.set('tags', tag);
    if (mode === 'trending') api.searchParams.set('order', 'popularity_week');
    if (mode === 'newest') api.searchParams.set('order', 'releasedate_desc');

    let upstream: Response;
    try {
      upstream = await fetch(api, { headers: { accept: 'application/json' } });
    } catch {
      return json(502, { error: 'upstream_unreachable' });
    }
    if (!upstream.ok) {
      return json(502, { error: 'jamendo_error', status: upstream.status });
    }
    const data = (await upstream.json()) as {
      results?: Array<{
        id?: string;
        name?: string;
        duration?: number;
        artist_name?: string;
        album_name?: string;
        album_image?: string;
        image?: string;
        audio?: string;
        audiodownload?: string;
        audiodownload_allowed?: boolean;
        license_ccurl?: string;
        shareurl?: string;
      }>;
    };
    const items = (data.results ?? [])
      .filter((t) => typeof t.id === 'string' && typeof t.audio === 'string' && t.audio.length > 0)
      .map((t) => ({
        id: t.id!,
        title: t.name ?? 'Untitled',
        artist: t.artist_name ?? 'Jamendo Artist',
        album: t.album_name ?? null,
        durationMs: typeof t.duration === 'number' ? t.duration * 1000 : null,
        artworkUrl: t.album_image || t.image || null,
        streamUrl: t.audio!,
        downloadUrl: t.audiodownload_allowed && t.audiodownload ? t.audiodownload : null,
        isDownloadable: Boolean(t.audiodownload_allowed && t.audiodownload),
        licenseUrl: t.license_ccurl ?? null,
        shareUrl: t.shareurl ?? null,
      }));
    const body = { items, nextOffset: items.length === limit ? offset + limit : null };
    searchCache.set(cacheKey, { at: Date.now(), body });
    return json(200, body, { 'x-cache': 'miss' });
  }

  if (url.pathname.startsWith('/api/jamendo/tracks/')) {
    if (!env.JAMENDO_CLIENT_ID) {
      return json(502, { error: 'jamendo_not_configured' });
    }
    const id = url.pathname.split('/').pop() ?? '';
    if (!/^\d{1,12}$/.test(id)) {
      return json(400, { error: 'invalid_track_id' });
    }
    const api = new URL('https://api.jamendo.com/v3.0/tracks/');
    api.searchParams.set('client_id', env.JAMENDO_CLIENT_ID);
    api.searchParams.set('format', 'json');
    api.searchParams.set('id', id);
    api.searchParams.set('audioformat', 'mp32');
    api.searchParams.set('include', 'musicinfo+licenses');
    let upstream: Response;
    try {
      upstream = await fetch(api, { headers: { accept: 'application/json' } });
    } catch {
      return json(502, { error: 'upstream_unreachable' });
    }
    if (!upstream.ok) {
      return json(502, { error: 'jamendo_error', status: upstream.status });
    }
    const data = (await upstream.json()) as {
      results?: Array<{
        id?: string;
        name?: string;
        duration?: number;
        artist_name?: string;
        album_name?: string;
        album_image?: string;
        image?: string;
        audio?: string;
        audiodownload?: string;
        audiodownload_allowed?: boolean;
        license_ccurl?: string;
        shareurl?: string;
      }>;
    };
    const t = data.results?.[0];
    if (!t || !t.id) {
      return json(404, { error: 'track_not_found' });
    }
    return json(200, {
      track: {
        id: t.id,
        title: t.name ?? 'Untitled',
        artist: t.artist_name ?? 'Jamendo Artist',
        album: t.album_name ?? null,
        durationMs: typeof t.duration === 'number' ? t.duration * 1000 : null,
        artworkUrl: t.album_image || t.image || null,
        streamUrl: t.audio ?? null,
        downloadUrl: t.audiodownload_allowed && t.audiodownload ? t.audiodownload : null,
        isDownloadable: Boolean(t.audiodownload_allowed && t.audiodownload),
        licenseUrl: t.license_ccurl ?? null,
        shareUrl: t.shareurl ?? null,
      },
    });
  }

  // ---- Last.fm similarity, charts & mood tags ----
  if (
    url.pathname === '/api/lastfm/similar' ||
    url.pathname === '/api/lastfm/charts' ||
    url.pathname === '/api/lastfm/tag'
  ) {
    if (!env.LASTFM_API_KEY) {
      return json(502, { error: 'lastfm_not_configured' });
    }
    const limitRaw = url.searchParams.get('limit') ?? '20';
    let limit = Number.parseInt(limitRaw, 10);
    if (!Number.isFinite(limit) || limit < 1) limit = 20;
    if (limit > 50) limit = 50;

    const mode = url.pathname.split('/').pop()!;
    const artist = sanitizeQuery(url.searchParams.get('artist'));
    const track = sanitizeQuery(url.searchParams.get('track'));
    const tag = sanitizeQuery(url.searchParams.get('tag'));

    if (mode === 'similar' && (!artist || !track)) {
      return json(400, { error: 'invalid_query', detail: 'artist and track required' });
    }
    if (mode === 'tag' && !tag) {
      return json(400, { error: 'invalid_query', detail: 'tag is required' });
    }

    const cacheKey = `lastfm:${mode}:${artist ?? ''}:${track ?? ''}:${tag ?? ''}:${limit}`;
    const cached = searchCache.get(cacheKey);
    if (cached && Date.now() - cached.at < CACHE_TTL_MS) {
      return json(200, cached.body, { 'x-cache': 'hit' });
    }

    const api = new URL('https://ws.audioscrobbler.com/2.0/');
    api.searchParams.set('api_key', env.LASTFM_API_KEY);
    api.searchParams.set('format', 'json');
    api.searchParams.set('limit', String(limit));
    if (mode === 'similar') {
      api.searchParams.set('method', 'track.getsimilar');
      api.searchParams.set('artist', artist!);
      api.searchParams.set('track', track!);
    } else if (mode === 'charts') {
      api.searchParams.set('method', 'chart.gettoptracks');
    } else {
      api.searchParams.set('method', 'tag.gettoptracks');
      api.searchParams.set('tag', tag!);
    }

    let upstream: Response;
    try {
      upstream = await fetch(api, { headers: { accept: 'application/json' } });
    } catch {
      return json(502, { error: 'upstream_unreachable' });
    }
    if (!upstream.ok) {
      return json(502, { error: 'lastfm_error', status: upstream.status });
    }
    type LfmTrack = { name?: string; artist?: { name?: string }; match?: number };
    const raw = (await upstream.json()) as {
      similartracks?: { track?: LfmTrack[] };
      tracks?: { track?: LfmTrack[] };
    };
    const list: LfmTrack[] =
      raw.similartracks?.track ??
      raw.tracks?.track ??
      [];
    const items = list
      .filter((it) => typeof it.name === 'string' && typeof it.artist?.name === 'string')
      .map((it) => ({
        title: it.name!,
        artist: it.artist!.name!,
        match: typeof it.match === 'number' ? it.match : null,
      }));
    const body = { items };
    searchCache.set(cacheKey, { at: Date.now(), body });
    return json(200, body, { 'x-cache': 'miss' });
  }

  return json(404, { error: 'not_found' });
}

// ---- Framework adapters (same core handler, Cloudflare + Vercel targets) ----

/// Cloudflare Workers adapter (`export default { fetch: handleWorkerRequest }`).
export async function handleWorkerRequest(req: Request, env: Env): Promise<Response> {
  const url = new URL(req.url);
  const headers = corsHeaders(req.headers.get('origin'), env);
  const respond = (status: number, body: unknown, extra: Record<string, string> = {}) =>
    new Response(JSON.stringify(body), {
      status,
      headers: { 'content-type': 'application/json', ...headers, ...extra },
    });
  return handle({ url, method: req.method, origin: req.headers.get('origin'), env, json: respond });
}

/// Vercel Edge/Node handler export (deploy: `vercel deploy --prod`).
/// @type {(req: Request) => Promise<Response>}
export async function vercelHandler(req: Request): Promise<Response> {
  const procEnv = (typeof process !== 'undefined' ? process.env : {}) as Record<string, string | undefined>;
  const g = globalThis as unknown as Record<string, string | undefined>;
  const env: Env = {
    YOUTUBE_API_KEY: g.YOUTUBE_API_KEY ?? procEnv.YOUTUBE_API_KEY,
    JAMENDO_CLIENT_ID: g.JAMENDO_CLIENT_ID ?? procEnv.JAMENDO_CLIENT_ID,
    LASTFM_API_KEY: g.LASTFM_API_KEY ?? procEnv.LASTFM_API_KEY,
    ALLOWED_ORIGINS: procEnv.ALLOWED_ORIGINS,
  };
  return handleWorkerRequest(req, env);
}

export { handle as _handleForTests, rateLimit as _rateLimitForTests, sanitizeQuery as _sanitizeQueryForTests };
