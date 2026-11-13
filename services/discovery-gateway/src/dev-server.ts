/**
 * SoundCraft Discovery Gateway — local dev/production server.
 * -----------------------------------------------------------
 * Runs the shared core handler (src/gateway.ts) on a plain Node 20+ process
 * (via tsx) or Bun. The YouTube Data API key never leaves this process.
 *
 * Environment:
 *   YOUTUBE_API_KEY   (required for /api/youtube/* endpoints)
 *   ALLOWED_ORIGINS   (optional, comma-separated; default '*')
 *   PORT              (optional, default 8787)
 *
 * Run:
 *   bun run src/dev-server.ts
 *   # or
 *   npx tsx src/dev-server.ts
 *
 * Smoke test:
 *   curl http://localhost:8787/api/health
 *   curl "http://localhost:8787/api/youtube/search?q=lofi&limit=5"
 */

import { vercelHandler } from './gateway.ts';

const PORT = Number.parseInt(process.env.PORT ?? '8787', 10);

function jsonError(status: number, message: string): Response {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { 'content-type': 'application/json' },
  });
}

async function toWebRequest(req: import('node:http').IncomingMessage, body: string): Promise<Request> {
  const host = req.headers.host ?? `localhost:${PORT}`;
  const proto = (req.headers['x-forwarded-proto'] as string | undefined) ?? 'http';
  const url = `${proto}://${host}${req.url ?? '/'}`;
  const headers = new Headers();
  for (const [key, value] of Object.entries(req.headers)) {
    if (typeof value === 'string') headers.set(key, value);
    else if (Array.isArray(value)) headers.set(key, value.join(', '));
  }
  const method = req.method ?? 'GET';
  const hasBody = method !== 'GET' && method !== 'HEAD' && body.length > 0;
  return new Request(url, {
    method,
    headers,
    body: hasBody ? body : undefined,
  });
}

async function fromWebResponse(res: Response, reply: import('node:http').ServerResponse): Promise<void> {
  const headers: Record<string, string> = {};
  res.headers.forEach((value, key) => {
    headers[key] = value;
  });
  const text = await res.text();
  reply.writeHead(res.status, headers);
  reply.end(text);
}

async function main(): Promise<void> {
  const nodeHttp = await import('node:http');
  const server = nodeHttp.createServer(async (req, reply) => {
    const chunks: Buffer[] = [];
    for await (const chunk of req) chunks.push(chunk as Buffer);
    const body = Buffer.concat(chunks).toString('utf8');
    try {
      const webReq = await toWebRequest(req, body);
      const webRes = await vercelHandler(webReq);
      await fromWebResponse(webRes, reply);
    } catch (err) {
      console.error('[gateway] unhandled error:', err);
      const res = jsonError(500, 'internal_error');
      await fromWebResponse(res, reply);
    }
  });

  server.listen(PORT, () => {
    console.log(`[soundcraft-discovery-gateway] listening on http://localhost:${PORT}`);
    console.log(`  YOUTUBE_API_KEY: ${process.env.YOUTUBE_API_KEY ? 'SET ✓' : 'NOT SET — /api/youtube/* will return 502'}`);
    console.log(`  ALLOWED_ORIGINS: ${process.env.ALLOWED_ORIGINS ?? '*'}`);
    console.log('  Endpoints:');
    console.log('    GET /api/health');
    console.log('    GET /api/youtube/search?q=&limit=');
    console.log('    GET /api/youtube/videos/:id');
  });
}

void main();
