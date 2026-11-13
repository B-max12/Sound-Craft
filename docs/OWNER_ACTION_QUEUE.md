# SoundCraft — Owner Action Queue

Single consolidated queue of owner-only inputs. **No secrets are requested or accepted in chat.**
Fill each item in the named secure location (local ignored env file, OS keychain, or provider dashboard).

| # | Required owner action | Why needed | Exact dashboard/path/command | Secret? | Feature blocked until provided | Ready-to-verify test |
|---|---|---|---|---|---|---|
| 1 | Confirm approved cricket brand artwork (provenance + right to use) and provide final `assets/brand/soundcraft-approved-concept.png` | §2.1 brand composition; current repo contains **draft** original placeholder art pending owner file | Copy file into `apps/soundcraft/assets/brand/` | No | Final splash/onboarding art | `scripts/validate_assets.sh` |
| 2 | Create Google Cloud project + enable **YouTube Data API v3**; create an API key restricted to the YouTube Data API; set `YOUTUBE_API_KEY` on the gateway host | YouTube discovery is quota/secret-bearing (§6.3, §9) | Google Cloud Console → APIs & Services → Credentials; then deploy gateway and set env var | Yes (server-side only) | Live YouTube discovery | Gateway `GET /api/youtube/search?q=test` returns 200; app YouTube tab shows results |
| 3 | Deploy `services/discovery-gateway` (Vercel/CF Worker) with `YOUTUBE_API_KEY`, CORS allowlist, rate limits | Keeps YouTube key server-side (R04) | `cd services/discovery-gateway && vercel deploy --prod` (or CF) | Yes | Live YouTube discovery | Gateway health `/api/health` returns `{ok:true}` |
| 4 | Set app-side gateway base URL in `apps/soundcraft/.env` (copy of `.env.example`) as `SOUNDCRAFT_GATEWAY_URL` | App must know gateway endpoint; key never ships in client | `cp apps/soundcraft/.env.example apps/soundcraft/.env` | No | Live YouTube tab (app shows honest "not configured" state until set) | YouTube tab switches from "Setup required" to live results |
| 5 | Audius app registration IF current Audius policy at launch requires an app name/developer id for higher rate limits | Audius public API currently keyless for read endpoints (re-verify at launch) | https://docs.audius.co → developer section | Maybe | Higher-rate discovery only; basic discovery works keyless today | `GET https://api.audius.co` returns host list; in-app Trending loads |
| 6 | Android signing keystore + Play Console account; store keystore locally (`android/keystore.jks` + `android/key.properties`, git-ignored) | Release AAB signing (§29.5) | Android Studio → Build → Generate Signed Bundle | Yes | Play release | `flutter build appbundle --release` |
| 7 | Apple Developer account/team; iOS/macOS signing + entitlements; TestFlight | iOS/macOS release (§29.5) | Xcode → Signing & Capabilities | Yes | App Store/TestFlight release | `flutter build ipa` on macOS runner |
| 8 | Windows code-signing cert; macOS notarization creds | Signed desktop installers | per-platform vendor dashboards | Yes | Signed desktop releases | `flutter build windows` + sign step |
| 9 | Publishing identifiers: Android `applicationId`, iOS bundle ID, desktop IDs, support email, web domain | Store identity (§29.4) | Provided values go into `apps/soundcraft` platform configs | No | Store submission | build passes with final IDs |
| 10 | Legal review: final Privacy Policy, Terms, OSS license choice, trademark check of "SoundCraft"/logo | §26, §29.6; draft legal copy in app is flagged DRAFT | owner counsel review of `apps/soundcraft/assets/legal/` | No | Public launch | About screen legal docs marked final |
| 11 | Final live verification run after 1–5: owner runs `scripts/quality_gate.sh` + provider smoke tests and signs off | §29.7 | repo root | No | Release verdict upgrade | `docs/RELEASE_READINESS.md` upgraded from CONDITIONAL |

**No credentials were provided to the coding agent. All provider integrations are implemented but live-unverified where marked.**
