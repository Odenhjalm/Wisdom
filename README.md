# Wisdom – Flutter + FastAPI

Den här kodenbasen består av två delar som tillsammans ersätter den tidigare Supabase-lösningen:

- **Flutter-klienten** (`lib/`) bygger hela mobilupplevelsen med Riverpod, GoRouter, Dio och `flutter_stripe`.
- **FastAPI-backenden** (`backend/`) erbjuder REST-endpoints för auth, profiler, community, studio, kurser och betalningar samt snackar direkt med Postgres.
- **Postgres-schemat** (`database/`) innehåller idempotenta SQL-filer för att bootstrap:a tabeller, RLS, roller och seed-data.

All utveckling sker mot en lokal Postgres-instans (`~/wisdom_db`) och en lokalt körd FastAPI-server. Inga Supabase-beroenden finns kvar i appen eller backenden.

## Förutsättningar

- Flutter SDK (3.24+ rekommenderas) med ett konfigurerat mål (Android, iOS eller web). Linux-demos fungerar, men Stripe saknar plugin där.
- Python 3.11+ och Poetry (eller möjlighet att använda `backend/.venv`).
- Docker + docker-compose för den lokala Postgres-instansen i `~/wisdom_db`.
- Node/Stripe CLI om du vill testa betalningsflöden.

## Snabbstart

1. **Starta databasen** (från `~/wisdom_db`):
   ```bash
   docker compose up -d
   ```

2. **Provisionera schema + seed** (från repo-roten):
   ```bash
   scripts/setup_local_backend.sh
   ```
   Scriptet använder `database/bootstrap.sql`, `database/schema.sql` och `database/seed.sql` och antar en lokal databas på `postgresql://oden:1124vattnaRn@localhost:5432/wisdom`.

3. **Kör FastAPI-backenden**:
   ```bash
   cd backend
   cp .env.example .env            # sätt JWT-secret och ev. Stripe-nycklar
   poetry install                  # eller pip install -r requirements
   poetry run uvicorn app.main:app --reload
   ```
   API:t exponerar swagger på <http://localhost:8000/docs> och använder databasen ovan.

4. **Konfigurera Flutter-appen**:
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

## Verifiera funktionalitet

- **Autentisering**: logga in med `teacher@example.com` / `teacher123`, `student@example.com` / `student123` eller kontot du skapar via `scripts/create_teacher_local.sql` (t.ex. `odenhjalm@outlook.com` / `1124816`).
- **Studioflöden**: skapa kurser, moduler och lektioner via `/studio`. Media hamnar i `backend/media/` och skyddas via RLS-checkar i databasen.
- **Community**: sociala funktioner (inlägg, följen, recensioner) styrs av `community`-endpoints i backenden.
- **Betalningar**: aktivera Stripe enligt `docs/local_backend_setup.md` för att testa checkout och webhookar.

## Automatiserade tester

- **Backend**: `cd backend && pytest` kör end-to-end-scenarier för kurser, media och behörigheter.
- **Flutter**: `flutter test` kör enhets- och widgettester.
- **Röktest**: `python scripts/qa_teacher_smoke.py --base-url http://localhost:8000 ...` kör ett komplett studioflöde och städar efter sig.

## Projektstruktur

- `backend/` – FastAPI-app, konfiguration och pytest-tester.
- `database/` – SQL-filer för bootstrap, schema och seed.
- `lib/` – Flutter-applikationen organiserad efter features (`auth`, `community`, `courses`, `payments`, `studio`).
- `scripts/` – hjälpskript för att sätta upp backend, skapa lokala konton och köra QA.
- `docs/` – uppdaterad dokumentation för lokal backend, QA-flöden och miljöinstruktioner.

Övriga nyttiga skript:
- `scripts/create_teacher_local.sql` – skapa fler lärare (behörigheter + profiler) mot lokala databasen.
- `scripts/qa_teacher_smoke.py` – automatiskt rök-test för lärarflödet.

Titta i `docs/local_backend_setup.md` för mer detaljer om infrastrukturen och hur Flutter-klienten kopplas mot den lokala backenden.
