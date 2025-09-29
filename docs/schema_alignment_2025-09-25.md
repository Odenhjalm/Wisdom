# Supabase schema alignment — 2025-09-25

## Inventerat nuläge
- Kärnschema från `init_projectapp.sql` definierar `app.role_type (user/member/teacher/admin)` och relaterade tabeller för kurser (`courses`, `modules`, `lessons`, `lesson_media`), samt stödtabeller för `enrollments`, `orders`, `memberships`, `events`, `services`, `teacher_requests`.
- Orders och stripe-flöde bygger på `app.orders` + RPC `app.complete_order` (kallas från `stripe_webhook`) och `stripe_checkout`-funktionen använder manuellt `price_data` samt `order_id`-metadata.
- Roller/progression för professionals saknas; certifieringsflöde ligger i `app.teacher_requests` snarare än `certificates`/`pro_progress` (ref. `init_projectapp.sql`).
- Gratis-intro-åtkomst hanteras via `app.courses.is_free_intro` och `app.lessons.is_intro`; det finns migrations som sätter policies (`policies_free_intro.sql`).
- Storage hanteras via migrations som skapar policies för bucketar (`policies_storage_media.sql`), men blueprint kräver ny struktur (`public_media`/`protected_media`).

## Blueprint (new _functions.md) highlights
- Nya enumen `app.user_role` med rollerna `user/professional/teacher` samt hjälp-tabeller `app.pro_requirements`, `app.pro_progress`, `app.certificates` och `app.teacher_approvals`.
- Kurser restruktureras till `app.courses` + `app.course_modules` + `app.course_prices`; lektioner och media i blueprinten konsolideras till modulnivå (ingen separat `lesson_media`).
- Access bygger på `app.purchases`, `app.guest_claim_tokens` och vyn `app.v_course_access` samt RPC `app.has_course_access`.
- Stripe checkout/webhook flyttas till gästanpassat flöde med email och claim tokens, ingen `orders`-tabell används.
- Events kräver pro/teacher roll via RLS-policies.

## Gap och åtgärdsförslag
1. **Rollsystem**
   - Migration krävs för att ersätta `app.role_type` med `app.user_role` och mappa befintliga `member/admin`-roller till nya motsvarigheter (t.ex. `professional`, `teacher`).
   - Introducera `app.pro_requirements`, `app.pro_progress`, `app.certificates`, `app.teacher_approvals` och flytta innehåll från `app.teacher_requests`.

2. **Kurser & moduler**
   - Nuvarande struktur har `modules`, `lessons`, `lesson_media`; blueprint föreslår `course_modules` med `content_md` och `media_url`. Kräver analys om vi migrerar data eller bygger ny modul-tabell parallellt.
   - `course_prices` saknas och behöver skapas. `price_cents` i `app.courses` bör fasas ut.

3. **Access & Stripe**
   - Ersätt `app.orders` + RPC med `app.purchases` + `guest_claim_tokens` och uppdatera edge functions (`stripe_checkout`, `stripe_webhook`) för metadata enligt blueprinten.
   - Inför `app.claim_purchase` och `app.v_course_access` + `app.has_course_access` och uppdatera RLS för moduler/kursinnehåll.

4. **Storage**
   - Blueprint använder `public_media`/`protected_media`; säkerställ att nuvarande policies mappas eller migreras. Dokumentera hur `lesson_media.storage_path` översätts till nya fält.

5. **Events**
   - Nuvarande tabell `app.events` saknar RLS-koppling till roll. Inför blueprint-policys och uppdatera insert-behörigheter.

## Rekommenderad migrationsstrategi (Foundation)
1. **Förberedande inventering**
   - Lista alla befintliga migreringsskript (`supabase/*.sql`) och avgör vilka som kan ersättas av ny struktur. Dokumentera beroenden (ex. `visdom_course_editor_quiz.sql`).
   - Ta ut schema-dump (via Supabase CLI) för att verifiera aktuell produktionsstruktur innan ändringar.

2. **Fasindelad migrering**
   - *Fas A*: Inför nya enumar och tabeller (`user_role`, `pro_requirements`, `pro_progress`, `certificates`, `teacher_approvals`) utan att ta bort gamla kolumner. Skriv script för att mappa befintliga roller.
   - *Fas B*: Skapa nya kursrelaterade tabeller (`course_modules`, `course_prices`, `purchases`, `guest_claim_tokens`) och `has_course_access`/`v_course_access`. Lägg till RLS och triggers.
   - *Fas C*: Migrera data från `orders` till `purchases` och uppdatera edge functions. Behåll `orders` tills appen använder det nya flödet, sedan avveckla.
   - *Fas D*: Uppdatera storage-policies och seeds.

3. **Test & validering**
   - Efter varje fas, kör Supabase migrationer mot en lokal/staging-instans. Skapa manuella testfall för course access och checkout/claim.

4. **Dokumentation**
   - Uppdatera `tasks2025-09-25.md` status per delmoment och logga i `workflow2025-09-25`.

## Öppna frågor
- Hur ska befintliga `member/admin` roller tolkas i nya modellen? Behövs separat admin-Hantering?
- Ska `lessons`/`lesson_media` sammanslås eller behållas och mappas till blueprintens `course_modules` (kräver UI-justeringar)?
- Vilken fallback behövs för historiska orders när vi växlar till `purchases`?

Uppdatera dokumentet när migrationsarbete påbörjas så att skillnader och beslut är spårbara.
