# Supabase-sammanfattning – 2025-10-01

Detta dokument sammanfattar senaste snapshotten (`out/db_snapshot_20251001_115116`).

## Huvudpunkter
- **Postgres**: 17.4; scheman: `app`, `auth`, `public`, `storage`, m.fl.
- **Tables (app-schemat)**: `courses`, `lessons`, `lesson_media`, `enrollments`, `orders`, `purchases`, `guest_claim_tokens`, `memberships`, `bookings`, `events`, etc. `lesson_media` saknar ännu kolumnen `storage_bucket`.
- **Storage buckets**: `media`, `course-media`, `public-media`, `private-media`, `avatars`, `public-assets`.
  * `course-media` är fortfarande `is_public = t` → alla kan läsa.
  * RLS på `storage.objects` följer legacy‑modellen (public read för course-media). Inga `course_id_from_path`-/`user_has_course_access`-villkor.
- **Funktioner**: `public.user_is_teacher()` finns men bygger på `public.teacher_permissions` och har `SECURITY INVOKER`. Saknas: `public.course_id_from_path()`, `public.user_has_course_access()`.
- **Access helpers**: `app.can_access_course(user, course)` (och varianten utan user-id) finns och kollar `is_free_intro`, `app.enrollments`, `app.purchases`, `app.orders`, `app.memberships`.
- **RLS (app.lesson_media)**: Läser om man är lärare eller kursen är publicerad och lektionen är intro/åtkomsten finns; skriv kräver `app.is_teacher()` och ägarskap/admin. Storage‑lagret speglar dock inte detta.
- **Data-volym**: `rowcounts.csv` visar mycket lite data; bra för idempotenta migreringar/tester.

## Återstående gap inför feature "teacher-controls"
1. Skapa nya migrations:
   - Buckets `public-media` (public) & `course-media` (privat) + RLS enligt blueprint.
   - Funktioner `public.user_is_teacher`, `public.course_id_from_path`, `public.user_has_course_access`.
   - Kolumn `storage_bucket` i `app.lesson_media` med backfill.
2. Uppdatera repositories och UI enligt uppdraget (se `tasks2025-10-01.md`).

## Övriga snapshotfiler
- `schema.sql`: fullständig DDL.
- `predata.sql` / `postdata.sql`: pg_dump‑sektioner.
- `functions.csv`, `grants.csv`, `rls_policies.csv`, `storage_policies.csv`, `rowcounts.csv`: strukturerad metadata.
- Äldre körningar (`out/db_snapshot_2025-10-01_114957` m.fl.) innehåller bara `introspect.md` eller är tomma.

