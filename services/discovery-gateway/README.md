# SoundCraft Discovery Gateway

Server-side proxy that keeps the **YouTube Data API v3 key off the client**
(SoundCraft security contract R04). The Flutter app only ever knows this
service's URL; the key lives solely in this service's environment.

## Endpoints

| Route | Description |
| --- | --- |
| `GET /api/health` | Liveness + `youtubeConfigured` flag |
| `GET /api/youtube/search?q=&limit=` | YouTube search (1–50 results, 5-min cache) |
| `GET /api/youtube/videos/:id` | Single video metadata |

Security: strict input validation, CORS allowlist, per-client rate limit
(60 req/min), no key echo, SSRF-safe (fixed upstream hosts only).

## Run locally (Node 20+ or Bun)

```bash
npm install            # or: bun install
cp .env.example .env   # then paste your YOUTUBE_API_KEY into .env
# with a .env loader (or export the vars manually):
YOUTUBE_API_KEY=xxx npx tsx src/dev-server.ts
# or with Bun:
YOUTUBE_API_KEY=xxx bun run src/dev-server.ts
```

Smoke test:

```bash
curl http://localhost:8787/api/health
curl "http://localhost:8787/api/youtube/search?q=lofi&limit=5"
```

## Wire into the Android app

The app reads the gateway URL at **compile time** — rebuild the APK with:

```bash
cd apps/soundcraft
flutter build apk --release \
  --dart-define=SOUNDCRAFT_GATEWAY_URL=http://<your-laptop-LAN-IP>:8787
```

Phone and laptop must share the same Wi-Fi for a LAN URL. For an
always-on URL, deploy to Vercel (free tier) and pass that URL instead.

## Deploy to Vercel (always-on URL)

```bash
npm i -g vercel
cd services/discovery-gateway
vercel                    # first run: link project
vercel env add YOUTUBE_API_KEY production   # paste the key when prompted
vercel --prod             # → https://<project>.vercel.app
```

`src/gateway.ts` exports `vercelHandler` (Web-standard Request → Response);
add `api/index.ts` re-exporting it if you use the Vercel function layout.

## YouTube API key — checklist

1. Google Cloud Console → APIs & Services → enable **YouTube Data API v3**.
2. Create an API key; restrict it to the YouTube Data API.
3. Put the key **only** in this gateway's environment (Vercel env var or
   local `.env`) — never in the Flutter app, never in git.
