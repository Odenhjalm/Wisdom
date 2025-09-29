# Phase A — Rollsystem (plan)

## Mål
Migrera från `app.role_type` (user/member/teacher/admin) till blueprintens `app.user_role` (user/professional/teacher) och etablera stödtabeller för progression utan att störa befintlig data eller funktionalitet.

## Mappning föreslagen
| Legacy `role_type` | Ny `user_role` | Kommentar |
| --- | --- | --- |
| `user` | `user` | Basnivå. |
| `member` | `professional` | Medlemmar får professionals rättigheter (events, uppgraderingsväg). |
| `teacher` | `teacher` | Oförändrat. |
| `admin` | `teacher` (`admin` flaggas separat) | Admins behåller lärarbehörigheter; administrativt ansvar flyttas till egen flagg (`app.profiles.is_admin`). |

## Steg
1. **Förbered schema**
   - Skapa enum `app.user_role` (idempotent) och tabeller `app.pro_requirements`, `app.pro_progress`, `app.certificates`, `app.teacher_approvals`.
   - Lägg till kolonner `is_admin boolean default false` i `app.profiles` för att särskilja tidigare admins.
   - Lägg till temporär kolumn `role_v2 app.user_role` i `app.profiles` (default `user`).

2. **Datamigrering**
   - Uppdatera `role_v2` enligt mappning ovan.
   - Sätt `is_admin=true` för tidigare `role_type='admin'`.
   - Flytta data från `app.teacher_requests` till `app.certificates` om möjligt (markera status pending/approved).

3. **Kod- & funktion-uppdateringar**
   - Uppdatera functions (`app.is_teacher`, `app.require_teacher`) att läsa `role_v2`.
   - Uppdatera RLS-policys som refererar till `role` eller `role_type`.

4. **Byta kolumn**
   - Efter verifiering: `alter table app.profiles drop column role;`
   - `alter table app.profiles rename column role_v2 to role;`
   - Droppa type `app.role_type` när inga beroenden kvarstår.

5. **Backfill progressionstabeller**
   - Prepopulera `app.pro_requirements` (STEP1–STEP3).
   - Om admin/lärare har certifikatdata → insert i `app.certificates` med status `verified`.

6. **Verifiering**
   - Kör SELECT-checkar för att jämföra counts per roll före/efter.
   - Säkerställ att RLS-policys fortsätter att fungera genom test med Supabase CLI (anon/authenticated tokens).

## TODO-lista inför implementation
- [ ] Bekräfta att `app.teacher_requests` dataformat kan mappar till Certificates (fält `message`, `status`).
- [ ] Identifiera funktioner/stored procedures beroende av `app.role_type` (`rg "role_type" supabase`).
- [ ] Avgjör var admin-rättigheter används i appen; definiera `is_admin` flöde.
- [x] Förbereda SQL-migration `supabase/2025-09-PhaseA_roles.sql` enligt stegen ovan.
- [x] Uppdatera `tasks2025-09-25.md` med status när migreringsskriptet finns.

## Efter körning i Supabase (2025-09-25)
- `supabase/2025-09-PhaseA_roles.sql` har körts i Supabase SQL Editor.
- Nya kolumner/tables skapade: `app.pro_requirements`, `app.pro_progress`, `app.certificates`, `app.teacher_approvals`, `app.profiles.is_admin`, `app.profiles.role_v2`.
- Legacy `role`-värden mappade till `role_v2`; `admin` markeras även med `is_admin=true`.
- Funktionen `app.grant_professional_if_ready` tillagd – behöver kopplas in när progressionstabellen börjar användas.

### Nästa analyser/åtgärder
- `app.teacher_requests` kolumner (`message`, `status`, `reviewed_by`, tidsstämplar) ska mappas mot `app.certificates` (t.ex. `title`, `notes`, `status`). Dokumentera transformationsreglerna innan data flyttas.
- `supabase/migrate_public_to_app.sql` uppdaterad 2025-09-25 (skriver `role_v2`, `is_admin` och mappar legacy `role`).
- `supabase/fix_app_is_teacher_recursion.sql` uppdaterad 2025-09-25 (läser `role_v2`/`is_admin`, kvarstår legacy return-värden).
- Kartlägg var `is_admin` behöver användas i Flutter-koden (ex. admin-dashboard) och skapa migrationsplan innan gamla `admin`-rollen tas bort.
- Migreringen i `supabase/2025-09-PhaseA_teacher_requests.sql` är körd; besluta om/ när `teacher_requests` avvecklas eller ersätts av vy.

Uppdatera dokumentet när beslut ändras eller kompletterande data hittas.
