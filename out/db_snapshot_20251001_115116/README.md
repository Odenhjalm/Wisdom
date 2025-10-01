# DB Snapshot — db_snapshot_20251001_115116

Filer:
- schema.sql (komplett DDL)
- predata.sql / postdata.sql (pg_dump-sektioner)
- introspect.md (översikt)
- rls_policies.csv (RLS för alla tabeller, inkl. storage.objects)
- storage_policies.csv (buckets + storage.objects-polices)
- functions.csv (alla funktioner med schema, signature, volatility, security)
- grants.csv (tabell-privilegier per roll)
- rowcounts.csv (approx antal rader per tabell)

Källa: postgresql://postgres:1124vattnaRn@db.xjjbqwmkotuqclgykhit.supabase.co:5432/postgres?sslmode=require
