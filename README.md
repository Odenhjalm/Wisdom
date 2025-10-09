# Wisdom – Flutter + FastAPI

Den här kodenbasen består av två delar som tillsammans ersätter den tidigare Supabase-lösningen:

- **Flutter-klienten** (`lib/`) bygger hela mobilupplevelsen med Riverpod, GoRouter, Dio och `flutter_stripe`.
- **FastAPI-backenden** (`backend/`) erbjuder REST-endpoints för auth, profiler, community, studio, kurser och betalningar samt snackar direkt med Postgres.
- **Postgres-schemat** (`database/`) innehåller idempotenta SQL-filer för att bootstrap:a tabeller, RLS, roller och seed-data.

All utveckling sker mot en lokal Postgres-instans (`~/wisdom_db`) och en lokalt körd FastAPI-server. Inga Supabase-beroenden finns kvar i appen eller backenden.

## Förutsättningar

- Flutter SDK (3.24+ rekommenderas) med ett konfigurerat mål (Android, iOS eller web). Linux-demos fungerar, men Stripe saknar plugin där.
- Python 3.11+ och Poetry (eller möjlighet att använda `backend/.venv`).
- Docker (används för att köra lokal Postgres-container).
- Node/Stripe CLI om du vill testa betalningsflöden.

## Snabbstart

1. **Starta databasen** (från repo-roten):
   ```bash
   make db.up
   ```
   > Skapar eller startar containern `wisdom-postgres` (Postgres 15) på port `5432`.

2. **Provisionera schema + seed**:
   ```bash
   make db.migrate
   make db.seed
   ```
   SQL-filerna ligger under `backend/migrations/sql/` och är idempotenta.

3. **Kör FastAPI-backenden**:
   ```bash
   cd backend
   cp .env.example .env            # sätt JWT-secret och ev. Stripe-nycklar
   poetry install                  # eller pip install -r requirements
   poetry run uvicorn app.main:app --reload
   ```
   API:t exponerar swagger på <http://localhost:8000/docs> och använder databasen ovan.
> Snabbvariant: kör `make backend.dev` från repo-roten för att starta Postgres (vid behov) och backend med auto-reload.

4. **Kör landningssidan (Next.js)**:
   ```bash
   cd web
   npm install
   npm run dev
   ```
   > Öppna <http://localhost:3000> för att se hero, butiks-knappar och juridiksidor. Produktionen byggs med `npm run build`.

5. **Konfigurera Flutter-appen**:
   - Uppdatera `.env` i repo-roten:
     ```env
     API_BASE_URL=http://localhost:8000
     STRIPE_PUBLISHABLE_KEY=pk_test_replace_me
     STRIPE_MERCHANT_DISPLAY_NAME=Wisdom Dev
     ```
   - Kör appen:
     ```bash
     flutter pub get
     flutter run
     ```
      > Tips: på Linux saknas inbyggt stöd för `flutter_stripe`. Kör på Android, iOS eller web – alternativt gardera initialiseringen i `main.dart` vid dekstopstest.

> **Obs:** kopiera alla `.env.example`-filer till `.env` (eller `.env.local`), fyll i egna värden och håll hemligheter utanför git. Använd gärna `direnv`, `dotenv` eller CI-hemligheter för att injicera känsliga nycklar.

## Verifiera funktionalitet

- **Autentisering**: logga in med `teacher@example.com` / `teacher123`, `student@example.com` / `student123` eller kontot du skapar via `scripts/create_teacher_local.sql` (t.ex. `teacher.local@example.com` / `ChangeMe123!`).
- **Studioflöden**: skapa kurser, moduler och lektioner via `/studio`. Media hamnar i `backend/media/` och skyddas via RLS-checkar i databasen.
- **Community**: sociala funktioner (inlägg, följen, recensioner) styrs av `community`-endpoints i backenden.
- **Betalningar**: aktivera Stripe enligt `docs/local_backend_setup.md` för att testa checkout och webhookar.

## REST API – Snabbtest

```bash
# Registrera och logga in
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@example.com","password":"change-me","display_name":"Demo"}'

TOKEN=$(curl -s -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@example.com","password":"change-me"}' | jq -r '.access_token')

# Lista tjänster och skapa en order
curl http://localhost:8000/services?status=active
curl -X POST http://localhost:8000/orders \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"service_id":"66666666-6666-4666-8666-666666666666"}'

# Hämta aktivitetsflödet och SFU-token (kräver seedad användare)
curl http://localhost:8000/feed -H "Authorization: Bearer $TOKEN"
curl -X POST http://localhost:8000/sfu/token \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"seminar_id":"99999999-9999-4999-8999-999999999999"}'
```

## Automatiserade tester

- **Backend**: `cd backend && pytest` kör end-to-end-scenarier för kurser, media och behörigheter.
- **Flutter**: `flutter test` kör enhets- och widgettester.
- **Röktest**: `python scripts/qa_teacher_smoke.py --base-url http://localhost:8000 ...` kör ett komplett studioflöde och städar efter sig.

### Schema-synk

- Håll `database/schema.sql` i fas med migreringarna genom `make schema.check` (wrappar `scripts/check_schema_sync.py --diff`).
- Lämpligt att köra i CI före deploy för att fånga om någon glömt regenerera schemat.

## Pre-commit hooks

- Installera verktyget en gång: `pip install pre-commit`.
- Aktivera hooks i repot: `pre-commit install`.
- Kör manuellt vid behov: `pre-commit run --all-files` (kontrollerar bl.a. `ruff`, `dart format` och `dotenv-linter` på `.env`-filer).

## Projektstruktur

- `backend/` – FastAPI-app, konfiguration och pytest-tester.
- `database/` – SQL-filer för bootstrap, schema och seed.
- `web/` – Next.js landningssida med hero, butiksknappar samt juridiska sidor.
- `lib/` – Flutter-applikationen organiserad efter features (`auth`, `community`, `courses`, `payments`, `studio`).
- `scripts/` – hjälpskript för att sätta upp backend, skapa lokala konton och köra QA.
- `docs/` – uppdaterad dokumentation för lokal backend, QA-flöden och miljöinstruktioner.

Övriga nyttiga skript:
- `scripts/create_teacher_local.sql` – skapa fler lärare (behörigheter + profiler) mot lokala databasen.
- `scripts/qa_teacher_smoke.py` – automatiskt rök-test för lärarflödet.
- `Makefile` – `make db.up | db.down | db.migrate | db.seed` hanterar lokal Postgres och migreringar. `make web.dev|web.build|web.lint` orkestrerar Next.js-landningssidan.

Titta i `docs/local_backend_setup.md` för mer detaljer om infrastrukturen och hur Flutter-klienten kopplas mot den lokala backenden. Ett snabbblad med `curl`-exempel finns i `docs/api_v2_reference.md` och LiveKit-demot dokumenteras i `docs/frontend_livekit_demo.md`.

## Hantera Postgres-containern

Stoppa och ta bort den lokala databasen när du är klar:

```bash
make db.down
```

Vill du bara pausa utan att ta bort volymen kan du köra:

```bash
docker stop wisdom-postgres
```

> Nästa gång du utvecklar kör du `make db.up` igen så startas samma container med bevarad data.
