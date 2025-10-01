#!/usr/bin/env bash
set -euo pipefail

# === Fyll i detta med ditt Supabase-projekt och lösen ===
PROJECT_REF="xjjbqwmkotuqclgykhit"   # byt till ditt <project-ref>
DB_PASS="1124vattnaRn"            # fyll i ditt lösenord

# === Bygg korrekt connection string ===
export DATABASE_URL="postgresql://postgres:${DB_PASS}@db.${PROJECT_REF}.supabase.co:5432/postgres?sslmode=require"

echo "==> Använder DATABASE_URL = $DATABASE_URL"

# Testa att koppla upp
if ! psql "$DATABASE_URL" -c "select now();" >/dev/null 2>&1; then
  echo "Fel: kunde inte koppla upp till Supabase. Kolla PROJECT_REF och DB_PASS."
  exit 1
fi

# Kör snapshot-scriptet
bash scripts/dump_db_snapshot.sh
