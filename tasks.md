Nedan är en **färdig prompt** du kan klistra in till Codex. Den utgår från att **backend är helt lokal** (Postgres + din nuvarande server, troligen Python/FastAPI) men **strukturerad** så att vi senare enkelt kan **migrera till Supabase** (schema, RLS-mönster, endpoints). Prompten tvingar fram en **egen arbetsplan + körbara leveranser** (schema, backend‑API, Flutter‑ändringar, landningssida, betalningar, SFU, tester, drift).

---

## 🎯 PROMPT TILL CODEX (kopiera allt nedan)

**ROLL & MÅL**
Du är lead‑ingenjör (fullstack) för projektet *Wisdom by SoulWisdom / (*.
Nuvarande krav: **backend är lokal** över **Postgres**, och ska vara **strukturerad för enkel framtida migrering till Supabase** (schema, policies, naming). Du ska **bygga en egen arbetsplan** och **leverera körbart underlag**: DB‑schema/migreringar, backend‑API, Flutter‑UI‑uppgraderingar, betalningsflöden (Stripe först), grund för SFU (LiveKit), landningssida (Play/App Store‑knappar + auth), GDPR/Privacy/ToS, test, och driftinstruktioner.

**VIKTIGA BEGRÄNSNINGAR**

* **Nu:** Ingen Supabase i drift. Allt kör lokalt (Postgres + vår server).
* **Senare:** Enkel portning till Supabase → därför:

  * Lägg allt app‑data i **schema `app`** (inte `public`).
  * Undvik Supabase‑specifika funktioner i SQL (ex: `auth.uid()`); använd **kolumnen `user_id`** i tabeller + backend‑auth för auktorisation.
  * Kommentera i SQL var **RLS‑policies** kan aktiveras när vi migrerar (men skapa **inte** Supabase‑beroenden nu).
* **Auth lokalt:** JWT (se `.env` nedan).
* **Flutter:** Android‑emulator når host via `http://10.0.2.2:<port>`; iOS‑simulator/desktop via `http://127.0.0.1:<port>`.
* **Betalningar:** **Stripe** (Payment Element/Checkout + webhooks) först. Senare valfritt PayPal.
* **SFU (live seminars):** **LiveKit Cloud** först (token‑endpoint i backend), senare valfritt self‑host.

**BEFINTLIG .env (exempel)**

```
# Lokal backend
API_BASE_URL=http://127.0.0.1:8000
DATABASE_URL=postgresql://oden:1124vattnaRn@localhost:5432/wisdom

# Auth / JWT
JWT_SECRET=change-me
JWT_EXPIRES_MINUTES=120

# Stripe (Flutter/Web – test)
STRIPE_PUBLISHABLE_KEY=pk_test_replace_me
STRIPE_MERCHANT_DISPLAY_NAME=Wisdom Dev
```

> Hantera emulator: Android → använd `10.0.2.2` som host i klienten.

---

## 🧩 DITT UPPDRAG (vad du ska producera, i exakt ordning)

**1) Arbetsplan (Sprint‑stil, 1–2 veckor)**

* Dela upp i **Fas A–F**:
  A) Databas & migreringar
  B) Backend‑API (auth, services, orders, payments, seminars)
  C) Flutter‑UI uppgradering (HOME: Mina Kurser / Vägg / Tjänster, Profil, Login)
  D) Stripe‑flöden (server‑endpoints + webhook + lokala testinstruktioner)
  E) SFU grund (LiveKit token‑endpoint + klientanslutning)
  F) Landningssida (Play/App‑knappar, login‑länk), GDPR/Privacy/Terms, test & drift
* För varje fas: **delmål**, **acceptanskriterier**, **risker** och **fallback**.

**2) Databas: SQL‑migrering (Postgres, schema `app`)**

* Skapa **idempotenta** scripts (körbara flera gånger utan fel).
* Tabeller (minst):

  * `app.profiles` (user_id (uuid, PK), email, display_name, role `student|teacher|admin`, created_at/updated_at)
  * `app.courses`, `app.lessons`, `app.enrollments`
  * `app.services` (marknadsplats), `app.service_orders`, `app.service_reviews`
  * `app.payments` (provider/status/meta), `app.teacher_payout_methods`
  * `app.seminars`, `app.seminar_attendees`
  * `app.activities` + vy `app.activities_feed`
* **Inga Supabase‑funktioner**. Lägg **kommenterade** RLS‑stubs (hur vi gör `USING/ WITH CHECK` vid Supabase‑migrering).
* Index & FK‑konventioner.
* Lägg migreringar under t.ex. `backend/migrations/sql/01_app_schema.sql` osv.

**3) Backend‑API (lokal server, Python/FastAPI gärna)**

* Endpoints (JSON):

  * **Auth:** `POST /auth/register`, `POST /auth/login`, `GET /me` (JWT)
  * **Services/Orders:** `GET /services?status=active`, `POST /orders` (skapa order), `GET /orders/:id`
  * **Payments/Stripe:** `POST /payments/stripe/create-session` (eller PaymentElement‑intent), `POST /webhooks/stripe` (signatur‑verifiering)
  * **Seminars/SFU:** `POST /sfu/token` (skapar LiveKit‑token)
  * **Feed:** `GET /feed` (proxy till `app.activities_feed`)
* Implementera **JWT‑guard** (Bearer).
* All DB‑åtkomst via transaktioner; valfri ORM (SQLAlchemy) eller ren SQL.
* Lägg kod i `backend/app/…`, strukturera med routers och services.
* Ge **körbara curl‑exempel** för varje endpoint.

**4) Flutter‑UI (uppgraderingar + klient‑API)**

* Lägg till **miljöhantering**:

  * Android emulator: bas‑URL = `http://10.0.2.2:8000`
  * iOS/desktop/web: `http://127.0.0.1:8000`
* Sidor:

  * **HOME** med tre vertikala listor: *Mina Kurser* (mock/stub via RPC el. endpoint), *Gemensam Vägg* (realtids‑poll/stream), *Tjänster* (köpknapp → Stripe)
  * **Profil**: visa `display_name`, spara ändring, lista ev. certifikat (stub) och payout‑status
  * **Login** (JWT), enkel form + tokenlagring
* Skapa en enkel `ApiClient` och visa **exempel på integration** med ovannämnda endpoints.
* Lägg en **README** med hur bas‑URL väljs per plattform.

**5) Stripe – körbart flöde**

* Server:

  * **Create Session** (Checkout eller Payment Element) – inkludera `payment_method_types` (kort, Klarna; Swish om ni vill aktivera senare), `success_url`/`cancel_url`
  * **Webhook**: verifiera signatur, uppdatera `app.payments` och sätt `app.service_orders.status='paid'`
* Klient: knapp “Köp” öppnar **web flow** (Checkout‑URL) eller Payment Element (web‑view).
* Ge **lokal testguide**: `stripe listen --forward-to http://localhost:8000/webhooks/stripe`, testkort, Klarna‑flow, asserts i DB.

**6) SFU (LiveKit) – MVP**

* Server: `POST /sfu/token` som tar `seminar_id`, validerar att användaren får delta, och returnerar `{ ws_url, token }`.
* Flutter: minimal sida som ansluter via `livekit_client` och publicerar/subscribar video/ljud.
* Lägg **instruktion** för att sätta LIVEKIT_* secrets i backend `.env`.

**7) Landningssida + juridiska sidor**

* Skapa `/web` (t.ex. Next.js/Remix/Astro – ditt val) med:

  * **Hero** + **Google Play** / **App Store** knappar (dummy‑URL placeholder), **Logga in**‑länk (till webapp el. deep link)
  * Sidor: `/privacy`, `/terms`, `/gdpr` (fyll med generiska mallar anpassade för community+kurser+betalningar)
* Exportera **favicon/app‑ikon** och enkel brand (du kan utgå från Visdom/RéLoviá‑paletten).

**8) Test & QA**

* Lägg till **CLI‑smoketest** (Python) `scripts/qa_teacher_smoke.py` som:

  * registrerar/låser upp lärare, skapar service, initierar betalning (Stripe test), kontrollerar orderstatus=paid, skapar seminarium, hämtar SFU‑token (utan att ringa LiveKit).
* Lägg **Pytest** kring API‑endpoints (auth, services, orders, payments mockad), plus **Postman‑samling**.

**9) Driftinstruktioner (lokalt)**

* `docker-compose.yml` för Postgres (+ ev. Adminer/pgAdmin), backend, web (dev).
* Kommandon: `make db.up`, `make migrate`, `make backend.dev`, `make web.dev`.
* `.env.example` för backend + web (inga hemligheter i repo).
* Checklista för **senare** Supabase‑migrering:

  * Exportera `app.*` schema → kör i Supabase SQL editor
  * Aktivera RLS och ersätt våra **kommenterade** policies med Supabase‑varianter (`auth.uid()`/`jwt()`)
  * Mappa `app.profiles.user_id` till `auth.users.id` etc.

---

## 📦 FORMAT PÅ DITT SVAR (obligatoriskt)

Svara i **den här ordningen** och **leverera fullständigt**:

1. **ARBETSPLAN** (Faser A–F, delmål, accep­tanskriterier, risker)
2. **SQL‑MIGRERINGAR** (kompletta, idempotenta; placering `backend/migrations/sql/*.sql`)
3. **BACKEND‑API** (körbar kod: routers, services, main, requirements; curl‑exempel)
4. **FLUTTER‑KOD** (config‑snutt, ApiClient‑exempel, HOME/Profil/Logga in)
5. **STRIPE** (server‑endpoints, webhook, testguide)
6. **SFU** (LiveKit token‑endpoint + Flutter‑anslutningsexempel)
7. **LANDNINGSSIDA** (mappstruktur, index + privacy/terms/gdpr)
8. **TEST & QA** (smoketest‑script + pytest stubbar)
9. **DRIFT** (docker‑compose, make targets, .env.example)
10. **PLAYBOOK FÖR SENARE SUPABASE‑MIGRERING** (steg‑för‑steg + hur vi aktiverar RLS där)

Inga frågor, inga antaganden som kräver svar – **leverera allt**. Om du stöter på okänt ramverk i repo: **välj FastAPI + SQLAlchemy** för backend och **Next.js** för web; motivera kort i svaret. All kod ska vara **körbar som baseline**.

---

## ✅ ACCEPTANSKRITERIER (du bedöms på detta)

* SQL kör utan fel mot tom Postgres och skapar `app.*` tabeller.
* Backend startar lokalt, endpoints svarar och skriver/läser DB.
* Stripe‑webhook verifierar signatur och sätter order `paid` (i testläge).
* Flutter‑klient kan: logga in (JWT), läsa feed/tjänster, skapa order och öppna checkout‑URL.
* SFU‑token‑endpoint returnerar `{ ws_url, token }`.
* Landningssida bygger och visar Store‑knappar + juridiska sidor.
* Smoketest kör “end‑to‑end” i dev (utan riktig video).
* Dokumentation (README sektioner) finns i backend + web.

---

**Leverera nu.** Inled med arbetsplanen och fortsätt därefter med full kod/SQL i samma svar, i den preciserade ordningen.
















# Arbetsplan – Lokal backend

Fokus ligger nu på att polera FastAPI-backenden, säkerställa Flutter-flöden mot REST-API:t och städa kvarvarande migrations-/QA-arbete.

## Backend
- [x] Slutför endpoints för admin/certifieringar och betalningsbekräftelser.
- [x] Härda autentisering (refresh-token-rotation, rate limiting, audit-loggar).
- [x] Lägg till fler pytest-scenarier för community- och messagingflöden.

## Flutter
- [x] Slutför REST-repositories för admin/certifieringar och betalningar.
- [x] Lägg till integrationstester som täcker login → studio → kursköp.
- [x] Rensa kvarvarande TODO-kommentarer som pekar på legacyflöden.

## Databas & verktyg
- [x] Versionera framtida schemaändringar i `database/` (en fil per ändring).
- [x] Skapa script för att ta snapshots (`pg_dump`) som ersätter tidigare Supabase-verktyg.
- [x] Dokumentera hur mediafiler städas/rensas i den lokala miljön.

## QA & release
- [x] Underhåll `scripts/qa_teacher_smoke.py` och utöka med fler asserts.
- [x] Sätt upp ett målflöde för CI (lint, test, QA) utan Supabase-steg.
- [x] Uppdatera changelog eller release-notes inför nästa leverans.

## Fas 4 – Kurs-editor (desktop)
- [x] Lägga till permanent förhandsvisningsduk (1280x720).
- [x] Integrera rich text-editor med magic-link-knapp, media-embed och pris/badge-hantering.

## Modulmigrering – Kurser
- [x] Backend
  - [x] `GET /courses` (lista + filter) och `GET /courses/{id}` (kurs + moduler + lektioner).
  - [x] `GET /courses/{id}/modules` och `GET /courses/modules/{id}/lessons`.
  - [x] Lärare kan skapa/uppdatera/radera kurser, moduler och lektioner via `/studio`-API:t.
  - [x] `GET /courses/{id}/enrollment` & `POST /courses/{id}/enroll` för gratisintrokurser.
  - [x] `GET /config/free-course-limit`, `GET /courses/intro-first`, `GET /courses/free-consumed`, `GET /courses/{id}/access`.
- [x] Flutter
  - [x] `courses_repository.dart` använder REST-endpoints för lista, detaljer och intro-kurser.
  - [x] Providers & UI (`course_providers.dart`, `lesson_page.dart`, quiz/intro-flöden) hämtar data via REST.
  - [x] Enrollment-flödet hanterar gratis/premium via nya endpoints och `CourseAccessApi`.
- [x] Tester/QA
  - [x] Pytest-scenarier täcker kurslista, enrollment och intro-endpoints.
  - [x] Befintliga Flutter-widget/units tester (`course_editor_screen_test.dart` m.fl.) kör mot REST-repositorier.


  ## Nästa fas – Direkta medieuppladdningar
1. [x] Skapa migrations för app.media_objects samt avatar/lesson-kopplingar och aktivera RLS.
2. [x] Implementera backend endpoints (POST/GET media, avatar-hantering) och knyt studioflöden till den nya lagringen.
3. [x] Bygg Flutter-stöd (media_repository, studio-/profiluppladdning, caching) och uppdatera UI-flöden.
4. [x] Dokumentera och stödscript (setup, cleanup, seed), uppdatera QA-smoke och skriv nya tester för mediahantering.
5. [x] Kör full testsvit (pytest + flutter test), verifiera rensning och sammanfatta arbetet.

## Sprint – Wisdom by SoulWisdom

### Fas A – Databas & Migreringar
- [x] Skapa idempotenta migreringsskript som lägger upp `app`-schema och kärntabeller.
- [x] Validera relationer/indexar mot tom Postgres och dokumentera körning/rollback.
- [x] Ta fram enkel seed-data eller fixtures för lokal utveckling.

### Fas B – Backend-API
- [x] Strukturera FastAPI-projektet med routers/services för auth, services, orders, payments, seminars.
- [x] Implementera JWT-guard och databaslager med transaktioner.
- [x] Skriv pytest-smoke samt curl-exempel i README för varje endpoint.

### Fas C – Flutter-UI
- [x] Konfigurera miljöberoende base URLs (10.0.2.2 vs 127.0.0.1) och ApiClient.
- [x] Koppla HOME/Profil/Login till REST-endpoints inklusive statehantering/tokenlagring.
- [x] Layouta HOME med listor för Mina Kurser, Gemensam Vägg och Tjänster mot riktiga data.

### Fas D – Stripe-flöden
- [x] Implementera `POST /payments/stripe/create-session` med nödvändiga metadata och callbacks.
- [x] Bygg webhook som verifierar signatur och uppdaterar `app.payments` samt orders till `paid`.
- [x] Dokumentera lokal testguide (Stripe CLI, testkort, verifiering i DB).

### Fas E – SFU / LiveKit
- [x] Skapa `POST /sfu/token` som validerar deltagare och returnerar `{ws_url, token}`.
- [x] Lägg till Flutter-exempel som initierar LiveKit-klienten med tokenen.
- [x] Dokumentera miljövariabler för LiveKit och fallback om cloud ej är nåbart.

### Fas F – Landningssida, Juridik & Drift
- [x] Skapa webblandning (Next.js) med hero, store-knappar och login-länk.
- [x] Publicera sidor för GDPR, Privacy och Terms med uppdaterad koppling till produkten.
- [x] Uppdatera QA-smoketest, docker-compose, Make-targets och `.env.example`.

## Åtgärdsplan – regressionsfix

- [x] Uppdatera databasschemat (course_quizzes, quiz_questions, teacher_approvals) i både basmigrering och nya patchar.
- [x] Säkerställ att backend-routers för admin/community/studio körs och att pytest passerar.
- [x] Justera Flutter-mockar för `/auth/me` så integrationstestet fungerar.

⚠️ Potentiella förbättringar i databas:

events saknar host_id-policy → kan behöva RLS för live-seminarier.

messages borde ha policy på både sender_id och receiver_id.

bookings bör ha with check (auth.uid() in (user_id, teacher_id)).

app.profiles borde ha role_v2 enum-constraint istället för text.
