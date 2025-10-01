#!/usr/bin/env bash
set -euo pipefail

# === Konfig ===
: "${DATABASE_URL:?Sätt DATABASE_URL till din Postgres/Supabase-URL (sslmode=require)}"
SNAP="db_snapshot_$(date +%Y%m%d_%H%M%S)"
OUT_DIR="out/${SNAP}"
mkdir -p "${OUT_DIR}"

echo "==> Dumpa schema (DDL) med pg_dump"
pg_dump "${DATABASE_URL}" \
  --schema-only \
  --no-owner \
  --no-privileges \
  --quote-all-identifiers \
  --file "${OUT_DIR}/schema.sql"

echo "==> Dumpa pre/post-data-sektioner (för tydlig diff)"
pg_dump "${DATABASE_URL}" --schema-only --section=pre-data  \
  --no-owner --no-privileges --quote-all-identifiers \
  --file "${OUT_DIR}/predata.sql"
pg_dump "${DATABASE_URL}" --schema-only --section=post-data \
  --no-owner --no-privileges --quote-all-identifiers \
  --file "${OUT_DIR}/postdata.sql"

echo "==> Introspektion: generera markdown-översikt"
psql "${DATABASE_URL}" -v "ON_ERROR_STOP=1" -f "scripts/queries/introspect.sql" -o "${OUT_DIR}/introspect.md"

echo "==> Lista RLS-policys (csv)"
psql "${DATABASE_URL}" -v "ON_ERROR_STOP=1" -f "scripts/queries/rls.sql" -A -F"," -P footer=off -o "${OUT_DIR}/rls_policies.csv"

echo "==> Lista storage-buckets och policys (csv)"
psql "${DATABASE_URL}" -v "ON_ERROR_STOP=1" -f "scripts/queries/storage.sql" -A -F"," -P footer=off -o "${OUT_DIR}/storage_policies.csv"

echo "==> Lista funktioner (csv)"
psql "${DATABASE_URL}" -v "ON_ERROR_STOP=1" -f "scripts/queries/functions.sql" -A -F"," -P footer=off -o "${OUT_DIR}/functions.csv"

echo "==> Lista grants (csv)"
psql "${DATABASE_URL}" -v "ON_ERROR_STOP=1" -f "scripts/queries/grants.sql" -A -F"," -P footer=off -o "${OUT_DIR}/grants.csv"

echo "==> Snabba radvolymer per tabell (approx, från pg_class)"
psql "${DATABASE_URL}" -v "ON_ERROR_STOP=1" -f "scripts/queries/rowcounts.sql" -A -F"," -P footer=off -o "${OUT_DIR}/rowcounts.csv"

# Liten indexfil
cat > "${OUT_DIR}/README.md" <<EOF
# DB Snapshot — ${SNAP}

Filer:
- schema.sql (komplett DDL)
- predata.sql / postdata.sql (pg_dump-sektioner)
- introspect.md (översikt)
- rls_policies.csv (RLS för alla tabeller, inkl. storage.objects)
- storage_policies.csv (buckets + storage.objects-polices)
- functions.csv (alla funktioner med schema, signature, volatility, security)
- grants.csv (tabell-privilegier per roll)
- rowcounts.csv (approx antal rader per tabell)

Källa: ${DATABASE_URL}
EOF

echo "==> KLART: ${OUT_DIR}"
