#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

DB_URL="${LOCAL_DATABASE_URL:-${1:-}}"
if [[ -z "$DB_URL" ]]; then
  DB_URL="postgresql://oden:1124vattnaRn@localhost:5432/wisdom"
fi

OUTPUT_DIR="${DB_SNAPSHOT_DIR:-snapshots}"
mkdir -p "$OUTPUT_DIR"

STAMP="$(date +%Y%m%d_%H%M%S)"
FILENAME="${OUTPUT_DIR}/wisdom_snapshot_${STAMP}.dump"

echo "==> Creating snapshot ${FILENAME}" >&2
pg_dump \
  --format=custom \
  --file="$FILENAME" \
  "$DB_URL"

echo "✅ Snapshot written to ${FILENAME}" >&2
