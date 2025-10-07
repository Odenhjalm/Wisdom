#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Allow override via LOCAL_DATABASE_URL or first CLI argument
DB_URL="${LOCAL_DATABASE_URL:-${1:-}}"
if [[ -z "$DB_URL" ]]; then
  DB_URL="postgresql://oden:1124vattnaRn@localhost:5432/wisdom"
fi

if ! command -v psql >/dev/null 2>&1; then
  echo "Missing dependency: psql (PostgreSQL client). Install via your package manager." >&2
  exit 1
fi

run_sql() {
  local file="$1"
  echo "==> Running ${file}" >&2
  PGPASSWORD="${PGPASSWORD:-1124vattnaRn}" psql "$DB_URL" -v ON_ERROR_STOP=1 -f "$file"
}

run_sql "database/bootstrap.sql"
run_sql "database/schema.sql"

if compgen -G "database/migrations/*.sql" >/dev/null; then
  while IFS= read -r migration; do
    run_sql "$migration"
  done < <(find database/migrations -maxdepth 1 -type f -name '*.sql' | sort)
fi

run_sql "database/seed.sql"

echo "✅ Local backend ready at ${DB_URL}" >&2
