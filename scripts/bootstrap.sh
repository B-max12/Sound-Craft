#!/usr/bin/env bash
# SoundCraft bootstrap — installs Flutter SDK if missing and verifies toolchain.
# Idempotent; safe to re-run. Host: Linux (CI runners use GitHub Actions instead).
set -euo pipefail

FLUTTER_VERSION="3.47.9"
FLUTTER_HOME="${FLUTTER_HOME:-/home/z/flutter-sdk}"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_${FLUTTER_VERSION}-stable.tar.xz"

if [ ! -x "$FLUTTER_HOME/bin/flutter" ]; then
  echo "[bootstrap] Downloading Flutter $FLUTTER_VERSION..."
  curl -sSL --retry 3 -o /tmp/flutter.tar.xz "$FLUTTER_URL"
  echo "[bootstrap] Extracting to $FLUTTER_HOME ..."
  mkdir -p "$FLUTTER_HOME"
  tar -xJf /tmp/flutter.tar.xz -C "$(dirname "$FLUTTER_HOME")" --strip-components=1
  rm -f /tmp/flutter.tar.xz
else
  echo "[bootstrap] Flutter already present at $FLUTTER_HOME"
fi

export PATH="$FLUTTER_HOME/bin:$PATH"
echo "[bootstrap] flutter --version"
flutter --version
echo "[bootstrap] flutter config --no-analytics"
flutter config --no-analytics >/dev/null
echo "[bootstrap] flutter doctor"
flutter doctor -v || true
echo "[bootstrap] DONE"
