#!/usr/bin/env bash
set -euo pipefail

HOST="${DB_HOST:-localhost}"
PORT="${DB_PORT:-5432}"
USER="${DB_USER:-postgres}"
TIMEOUT="${DB_WAIT_TIMEOUT:-30}"

echo "==> Waiting for Postgres at ${HOST}:${PORT} (user=${USER})"
for ((i = 0; i < TIMEOUT; i++)); do
  if pg_isready -h "${HOST}" -p "${PORT}" -U "${USER}" >/dev/null 2>&1; then
    echo "✅ Postgres is ready"
    exit 0
  fi
  sleep 1
done

echo "❌ Postgres did not become ready within ${TIMEOUT}s" >&2
exit 1
