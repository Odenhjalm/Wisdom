# Phase A — Funktioner beroende av gamla roller

## Identifierat (2025-09-25)
- `supabase/fix_app_is_teacher_recursion.sql`
  - Funktioner `app.is_admin()`, `app.is_teacher()` och `app.current_role()` läste tidigare `p.role` men är nu uppdaterade till `is_admin`/`role_v2`; `app.current_role()` mappar tills vidare till legacy `app.role_type`.
- `supabase/migrate_public_to_app.sql`
  - Uppdaterad 2025-09-25: backfill sätter både `role_v2`/`is_admin` och mappar legacy `role`-enum tills vidare.

## Åtgärdsidéer
1. Skapa nya funktioner `app.current_user_role()` som returnerar `app.user_role` (inkluderar `professional`).
2. (KLAR 2025-09-25) `app.is_admin()`/`app.is_teacher()` läser `is_admin` och `role_v2` i stället för `role`.
3. `app.current_role()` mappar från `role_v2` → legacy enum tills `app.role_type` kan tas bort.
4. Uppdatera migrationsskript (`migrate_public_to_app.sql`) så att de använder nya `::text` mapping eller ersätts av ny rutin.

## Nästa steg
- Kartlägg var i Flutter-koden `profile.role` används (t.ex. `Profile.role`, `AuthService.isTeacher`). Planera uppdatering till `userRole` + `isAdmin`.
- Efter koduppdateringar → skapa SQL som byter kolumn `role_v2` → `role` och droppar `app.role_type`.

Uppdateras efter varje funktion rework.
