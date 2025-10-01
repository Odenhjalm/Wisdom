# Teacher Controls v1 — Leverabler

## 1. Databas & Storage (migreringar)
- `supabase/migrations/2025-09-30_storage_paid_media.sql` — skapar buckets `public-media`/`course-media`, definierar helper-funktionerna `public.user_is_teacher`, `public.course_id_from_path`, `public.user_has_course_access` och inför nya RLS-policys.
- `supabase/migrations/2025-09-30_lesson_media_bucket.sql` — lägger till kolumnen `storage_bucket` i `app.lesson_media` och backfillar befintliga rader.

### Körordning
1. `supabase/migrations/2025-09-30_storage_paid_media.sql`
2. `supabase/migrations/2025-09-30_lesson_media_bucket.sql`

> Kör migreringarna via Supabase SQL Editor i ovan ordning. Båda skripten är idempotenta och kan köras flera gånger utan bieffekter.

## 2. Repositories & domänlager
- `lib/features/studio/data/studio_repository.dart` — hanterar uppladdning/sortering/borttagning av media via nya buckets och sparar `storage_bucket`.
- `lib/features/studio/data/lesson_media_path.dart` — genererar paths, bucket-val och detekterar mediatyp.
- `lib/features/courses/data/course_access_api.dart` & `lib/features/courses/data/courses_repository.dart` — inkapslar accesskontroll via RPC `user_has_course_access` och fallback till `app.can_access_course`.

## 3. UI & router-hookar
- `lib/features/studio/presentation/course_editor_page.dart` — metadata-panel (titel/slug/pris/publicering), modul-/lektionshantering, intro-flagg, mediaflöde med uppladdning/sortering/borttagning samt förhandsgranskning för lärare/elev.
- `lib/features/courses/presentation/course_access_gate.dart` — gate-komponent som visar `PaywallPrompt` vid saknad åtkomst.
- `lib/features/payments/presentation/paywall_prompt.dart` — paywallkort med CTA till kursöversikt och login.

## 4. Dokumentation & README
- README uppdaterad med Teacher Controls-notis (se "Teacher Controls v1"-avsnittet).
- Denna fil (`docs/teacher_controls_v1_deliverables.md`) samlar leverabler och manual.

## 5. Tester & kvalitetsstöd
### Automatiska tester
- Widgettest: `test/widgets/course_editor_screen_test.dart` — renderar kurseditor med mockade repos.
- Enhetstester: `test/unit/courses_repository_access_test.dart`, `test/unit/lesson_media_path_builder_test.dart`.

### Kommando
```
flutter test test/widgets/course_editor_screen_test.dart \
  test/unit/courses_repository_access_test.dart \
  test/unit/lesson_media_path_builder_test.dart
```

### Manuella flöden
1. Logga in som lärare och gå till `/teacher/editor`.
2. Välj kurs → uppdatera metadata (titel/slug/pris/publicering) och spara.
3. Lägg till modul & lektion, markera lektion som intro, ladda upp media.
4. Förhandsgranska i lärare/elev (köpt/ej köpt) och säkerställ paywall.
5. Testa elevvy utan åtkomst (`/course/:slug`) och bekräfta `CourseAccessGate` + `PaywallPrompt`.

## 6. Release-checklista
- [ ] Migreringar körda i Supabase (prod och staging).
- [ ] Flutter-testsuiten ovan körd lokalt (`flutter test …`).
- [ ] Studio-editor manuellt verifierad enl. flödet ovan.
- [ ] README + doc pushade till `main`.
