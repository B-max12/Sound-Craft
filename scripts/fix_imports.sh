#!/usr/bin/env bash
# Normalizes intra-project imports to the soundcraft package namespace.
set -euo pipefail
cd "$(dirname "$0")/../apps/soundcraft"
rg -l "package:(core|domain|data|design_system|player|features|app|downloads)/" lib test 2>/dev/null | while read -r f; do
  sed -i -E "s/package:core\//package:soundcraft\/core\//g; s/package:domain\//package:soundcraft\/domain\//g; s/package:data\//package:soundcraft\/data\//g; s/package:design_system\//package:soundcraft\/design_system\//g; s/package:player\//package:soundcraft\/player\//g; s/package:features\//package:soundcraft\/features\//g; s/package:app\//package:soundcraft\/app\//g; s/package:downloads\//package:soundcraft\/downloads\//g" "$f"
done
echo "imports normalized"
