# SoundCraft — Architectural Decision Log

| Date | Context | Decision | Alternatives considered |
|---|---|---|---|
| 2026-11-03 | Host is Linux-only sandbox; Flutter not preinstalled | Install Flutter 3.47.9 stable via CDN tarball at `/home/z/flutter-sdk`; `scripts/bootstrap.sh` re-installs idempotently | apt/other package managers (no flutter pkg), FVM (extra layer) |
| 2026-11-03 | State management | Plain Riverpod (flutter_riverpod, no codegen) | Provider (weaker typing), BLoC (heavier), riverpod_generator (codegen cost) |
| 2026-11-03 | Navigation | go_router StatefulShellRoute for 4 root tabs with independent branch navigators | Navigator 2 hand-rolled (error-prone), auto_route (codegen) |
| 2026-11-03 | Persistence | Drift over SQLite (native) + Drift WasmDatabase on web | Isar/Hive (weaker relational integrity), sqflite (no web) |
| 2026-11-03 | Audio | just_audio + audio_service + audio_session; just_audio_media_kit on Windows/Linux | media_kit directly (heavier), audioplayers (weaker service integration) |
| 2026-11-03 | Metadata reading | audio_metadata_reader (pure Dart) — works in VM tests and all platforms | audiotags (FFI builds), on_audio_query (Android-centric) |
| 2026-11-03 | YouTube playback | Official surface only: web → youtube-nocookie iframe embed; mobile → youtube_player_iframe; always labeled "Watch on YouTube"; never enters audio queue | just_audio (PROHIBITED extraction), hidden webview (policy violation) |
| 2026-11-03 | Secrets | YouTube key lives only in serverless gateway; client gets gateway URL via `--dart-define-from-file` env; no keys in binary | Embedding restricted key in app (rejected: quota/abuse risk) |
| 2026-11-03 | Brand art | Owner-approved concept image was NOT attached to the task → per §2.1 implement asset slots + clearly-labeled DRAFT original cricket mark (CustomPainter/PIL), flag in Owner Action Queue item 1 | Inventing a "final" mascot (forbidden), shipping no brand identity |
