Codex update 2025-09-18

Vi har lagt till och kört nytt migrerings-skript för teacher-permissions.

Ny tabell:
app.teacher_permissions

profile_id uuid primary key references app.profiles(user_id)

can_edit_courses bool, can_publish bool

granted_by uuid, granted_at timestamptz

Backfill:

Från public.teacher_permissions.user_id (alla får edit/publish=true).

Från app.profiles med role='teacher'.

Ny vy:
public.teacher_permissions_compat

Exponerar profile_id, can_edit_courses, can_publish, granted_by, granted_at.

👉 Alla framtida JOINs ska ske via app.teacher_permissions (eller vyn) på profile_id i stället för gamla public.teacher_permissions.user_id.

### Codex update 2025-09-18
**Compat fix:** La till `app.courses.hero_image_url` (text) och initierade från `cover_url`. Trigger synkar `cover_url -> hero_image_url`. Orsak: legacy Flutter-kod läser `hero_image_url`. Plan: migrera UI till `cover_url` och ta bort compat-kolumnen.

### Codex update 2025-09-18

**Gjort**
- Bytte kursflödet till `cover_url` och tog bort alla beroenden av `hero_image_url`.
  - `lib/data/providers.dart:6–131` läser nu från `app`-schemat, normaliserar `cover_url`/`is_free_intro` för landing/teachers/services.
  - `lib/screens/landing/landing_page.dart:348–363` (+ `.new:232`) renderar kurskort med `cover_url` och `is_free_intro`.
  - `lib/screens/home/home_shell.dart:195–228` läser profiler från `app.profiles` och mappar om fältnamn.
  - `lib/screens/teacher/teacher_editor.dart:84–200` sparar i `app.courses`, stöd för gratis-intro + sluggar.
- Byggde ut auth med 3 vägar (ingen desktop-redirect krävs):
  - `lib/screens/auth/login.dart:15–260` → lösenord, OTP-kod (OtpType.email), magic-link (för mobil).
  - `lib/supabase_client.dart:51–73` → `Supabase.initialize` med `FlutterAuthClientOptions`, log level `warn`, default redirect `andligapp://login-callback`.

**Att göra (Codex)**
1) **Databas städning (SQL körs separat, men kod ska inte re-introducera fältet):**
   - Vi tar bort compat-kolumnen `app.courses.hero_image_url` och ev. trigger som speglade `cover_url`.  
   - Kodbasen ska fortsätta använda **endast** `cover_url`.

2) **Auth konfiguration:**
   - Säkerställ att `andligapp://login-callback` används konsekvent där redirect behövs.
   - Desktop kör lösenord/OTP; magic-link hålls för mobil (inga web-redirects till `localhost`).

3) **Schema-konsekvens:**
   - Håll alla queries/services på **`app.*`** (inte `public.*`).
   - För behörigheter använd `app.teacher_permissions.profile_id` (FK → `app.profiles.user_id`) eller vyn `public.teacher_permissions_compat`.

**Verifiering (kör lokalt)**
- `flutter run` → logga in med lösenord **eller** OTP → öppna landing → se kurser med `cover_url` och “Gratis intro”.
- Skapa gratis-intro i Teacher Editor → dyker upp på landing.

**Viktigt**
- Introducera **inte** tillbaka `hero_image_url` i Dart eller SQL.
- Nya fält i kursflödet: `cover_url`, `is_free_intro` ska vara källsanning.

