# SoundCraft — Implementation Status

> Continuity file (contract R12). If context is lost, recover from this file first.
> Statuses are evidence-based: `PREPARED != BUILT != TESTED != RELEASED`.

- **Host:** Linux x86_64 sandbox, 2 CPUs, ~4 GB RAM. Debian-based.
- **Flutter SDK:** 3.47.9 stable (Dart 3.13.x) — installed at `/home/z/flutter-sdk` by `scripts/bootstrap.sh`.
- **Git:** initialized at repo root `soundcraft/`.
- **Last updated:** 2026-11-03 (P00 in progress)

## Phase status

| Phase | Package | Status | Evidence |
|---|---|---|---|
| P00 | Audit & bootstrapping | IN PROGRESS | This file; `scripts/bootstrap.sh`; flutter doctor log in `docs/evidence/` |
| P01 | Visual shell | NOT STARTED | — |
| P02 | Local library | NOT STARTED | — |
| P03 | Player | NOT STARTED | — |
| P04 | User library | NOT STARTED | — |
| P05 | Audius | NOT STARTED | — |
| P06 | YouTube | NOT STARTED | — |
| P07 | Authorized download | NOT STARTED | — |
| P08 | Recommendations & polish | NOT STARTED | — |
| P09 | Multi-platform QA | NOT STARTED | — |
| P10 | Owner handoff | NOT STARTED | — |

## Environment constraints (measured, not guessed)

- Linux host only. **No Android SDK, no Xcode/macOS, no Windows.** Android/iOS/macOS/Windows builds are configured + covered by CI workflows on correct runners; they are NOT verified here (see `docs/VERIFICATION_MATRIX.csv`, `docs/KNOWN_LIMITATIONS.md`).
- `sudo apt-get` worked: `cmake ninja-build clang libgtk-3-dev` installable → Linux desktop build target is feasible.
- Network to `storage.googleapis.com`, `pub.dev`, `github.com` verified via HTTP checks.
- `ffmpeg` available on host → used only to generate **original test fixture audio** (never distributed content).

## Verified commands log

| Date | Command | Exit | Notes |
|---|---|---|---|
| 2026-11-03 | `curl -sI https://storage.googleapis.com/...` | 0 | Flutter CDN reachable |
| 2026-11-03 | `curl -sI https://pub.dev/api/packages/go_router` | 0 | pub.dev reachable |
| 2026-11-03 | `sudo apt-get install cmake ninja-build clang libgtk-3-dev` | pending | background install |

## Next executable tasks

1. Finish P00: extract Flutter, `flutter doctor`, `flutter create apps/soundcraft`, pin dependencies.
2. P01 design system + shell + router + responsive/golden tests.
