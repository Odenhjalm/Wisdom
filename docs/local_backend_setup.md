# Lokal backend för Visdom

Det här dokumentet beskriver hur du kör databasschemat lokalt och kopplar Flutter-appen till FastAPI-backenden.

## Förutsättningar
- Docker-kontainern `pg_visdom` startad via `docker-compose` i `~/wisdom_db` (Port 5432).
- PostgreSQL-klient (`psql`) installerad lokalt.

## Snabbstart
1. Kör scriptet som provisionerar allt och fyller på testdata:
   ```bash
   scripts/setup_local_backend.sh
   ```
   Scriptet använder per default `postgresql://oden:1124vattnaRn@localhost:5432/wisdom`. Ange annan URL via `LOCAL_DATABASE_URL` eller ett första argument.

2. Skapa eller återställ databasen från scratch:
   ```bash
   PGPASSWORD=1124vattnaRn psql postgresql://oden@localhost:5432/wisdom \
     -c "drop schema if exists app cascade; drop schema if exists auth cascade; drop schema if exists storage cascade;"
   PGPASSWORD=1124vattnaRn psql postgresql://oden@localhost:5432/wisdom -f database/bootstrap.sql
   PGPASSWORD=1124vattnaRn psql postgresql://oden@localhost:5432/wisdom -f database/schema.sql
   ```
   Efter dessa steg är databasen helt nyskapad utan seedade användare.

3. Skapa en lärare (eller annan användare) med `scripts/create_teacher_local.sql`:
   ```bash
   PGPASSWORD=1124vattnaRn psql postgresql://oden@localhost:5432/wisdom \
     -v email="odenhjalm@outlook.com" \
     -v password="1124vattnaRn" \
     -v display_name="Oden Hjalm" \
     -f scripts/create_teacher_local.sql
   ```
   Scriptet kan återanvändas för fler konton genom att ändra variablerna. Konton skapas i `auth.users`, får bcrypt-hashat lösenord, får profil med `role_v2 = 'teacher'`, registreras i `app.teacher_permissions`, `app.teacher_approvals` och läggs i `app.teacher_directory`. Därmed kan de ladda upp media enligt RLS-policys.

4. Starta FastAPI-backenden:
   ```bash
   cd backend
   cp .env.example .env  # justera JWT-secret vid behov
   poetry install        # eller pip install -r <exporterat requirements>
   poetry run uvicorn app.main:app --reload
   ```
   API:t exponerar `http://localhost:8000/docs` och pratar direkt med Postgres. Standardlösenord från seed-scriptet:
   - admin@example.com / `admin123`
   - teacher@example.com / `teacher123`
   - student@example.com / `student123`

   > **Tokener:** Access-token lever nu i 15 minuter (styrt av `JWT_EXPIRES_MINUTES`, default 15). Backend utfärdar också refresh-token (`JWT_REFRESH_EXPIRES_MINUTES`, default 1440 = 24 h) och endpointen `POST /auth/refresh` roterar bägge token automatiskt.

### Studio-endpoints & tester
- Backendens studio-API (`/studio/*`) ersätter Supabase-beroendena för kurs-/modul-/leksions-CRUD, quiz och mediauppladdningar. Endpointsen kräver att användaren är lärare eller admin (`is_teacher_user` checken).
- Profilbilder laddas upp via `POST /profiles/me/avatar` som skapar en rad i `app.media_objects` och uppdaterar `app.profiles.avatar_media_id`. Avataren exponeras via `GET /profiles/avatar/{media_id}` och ingår i smoke-testet.
- Ett integrerat pytest-scenario verifierar hela flödet (skapande → uppdateringar → mediahantering → åtkomstskydd). Kör det så här:
  ```bash
  cd backend
  source .venv/bin/activate  # eller använd poetry shell
  pytest tests/test_courses_studio.py
  ```
  Testet använder ett temporärt mediarot (`tmp_path`) så riktiga filer påverkas inte.

5. Verifiera att databasen svarar:
   ```bash
   PGPASSWORD=1124vattnaRn psql postgresql://oden@localhost:5432/wisdom -c "select count(*) from app.courses;"
   ```

6. Behöver du agera som en specifik användare i SQL-sessionen kan du sätta mockad auth-kontekst:
   ```sql
   select app.set_local_auth('22222222-2222-2222-2222-222222222222', 'teacher@example.com', 'teacher');
   -- efter det returnerar auth.uid() den givna användaren
   select auth.uid();
   ```

## Koppla Flutter-appen
Flutter-klienten läser `API_BASE_URL`, `STRIPE_PUBLISHABLE_KEY` och `STRIPE_MERCHANT_DISPLAY_NAME` från `.env`. För lokal utveckling räcker det att sätta:

```env
API_BASE_URL=http://localhost:8000
STRIPE_PUBLISHABLE_KEY=pk_test_replace_me
STRIPE_MERCHANT_DISPLAY_NAME=Wisdom Dev
```

När backenden (steg 4) körs kan du starta Flutter-appen via `flutter run` och den pratar mot samma lokala API.

## Stripe CLI & betalningsflöde

För att testa kurs- och tjänsteköp lokalt använder vi Stripe CLI som fångar webhooks och vidarebefordrar dem till FastAPI-backenden.

1. Installera Stripe CLI (Linux x86_64) via hjälpscriptet:
   ```bash
   ./scripts/install_stripe_cli.sh
   export PATH="$HOME/.local/bin:$PATH"  # om katalogen inte redan ligger i PATH
   stripe version
   ```
   På andra plattformar följ den officiella guiden: <https://stripe.com/docs/stripe-cli>.

2. Lägg till Stripe-konfiguration i `backend/.env`:
   ```env
   STRIPE_SECRET_KEY=sk_test_xxx
   STRIPE_WEBHOOK_SECRET=whsec_xxx
   ```
   `STRIPE_WEBHOOK_SECRET` får du efter att du startat `stripe listen` (nästa steg). Utan nycklar svarar API:t med 503 på betalningsendpoints.

3. Lägg till publishable key i Flutter-appen (`.env` i rotkatalogen eller via `--dart-define`):
   ```env
   STRIPE_PUBLISHABLE_KEY=pk_test_xxx
   STRIPE_MERCHANT_DISPLAY_NAME=Wisdom Dev
   ```
   Dessa används av `flutter_stripe` för PaymentSheet och måste alltid vara publika (använd test-nyckel lokalt).

4. Logga in och starta webhook-forwarding i ett separat terminalfönster:
   ```bash
   stripe login
   stripe listen --forward-to http://localhost:8000/payments/webhook
   ```
   Stripe CLI skriver ut det hemliga värdet (`whsec_...`). Kopiera det till `STRIPE_WEBHOOK_SECRET` i `.env`.

5. API-endpoints för betalningar:
   - `POST /payments/orders/course` respektive `/payments/orders/service` – skapar en order i Postgres.
   - `POST /payments/create-checkout-session` – skapar en Stripe Checkout-session för ordern och returnerar `url` + `id`.
   - `POST /payments/webhook` – tar emot Stripe-webhooks (`checkout.session.completed`) och markerar ordern som betald (`app.orders.status = 'paid'` + lägger till kursen i `app.enrollments`).

6. I Flutter-appen initieras `flutter_stripe` automatiskt via `.env`. Prenumerationsflödet använder `/payments/create-subscription` och PaymentSheet (kräver publishable key).

## Filer som provisioneras
- `database/bootstrap.sql` – stubs för `auth.*`, `storage.*`, och hjälpfunktioner (`auth.uid()`, `auth.jwt()`, `app.set_local_auth`).
- `database/schema.sql` – monolitiskt schema med tabeller, funktioner och RLS.
- `database/seed.sql` – tre användare (admin/teacher/student), exempel-kurs, modul, lektion och inskrivning.

Alla SQL-filer är idempotenta, så du kan köra scriptet flera gånger.

## Exportera schema till andra miljöer
Behöver du applicera schemat på en annan Postgres-instans kan du använda `pg_dump` eller `psql` direkt mot `database/schema.sql` och `database/seed.sql`. Exempel:

```bash
pg_dump --schema-only postgresql://oden:1124vattnaRn@localhost:5432/wisdom > schema_dump.sql
PGPASSWORD=$DB_PASS psql "$REMOTE_DATABASE_URL" -v ON_ERROR_STOP=1 -f database/schema.sql
```

Seed-filen är avsedd för lokal utveckling; i en extern miljö bör riktiga konton och roller skapas manuellt eller via separata skript.

## Städning av mediafiler
Direkt-uppladdade media ligger både på disk (`backend/media/`) och i tabellen `app.media_objects`.
Så här rensar du lokalt:

1. Ta bort oanvända rader i databasen (behåll gärna senaste testkörningen):
   ```sql
   delete from app.media_objects
   where created_at < now() - interval '7 days'
     and id not in (select media_id from app.lesson_media where media_id is not null);
   ```
2. Rensa filsystemet:
   ```bash
   rm -rf backend/media/*
   ```
   Lektioners filer ligger i `backend/media/<course_id>/<lesson_id>/` medan profilbilder sparas under `backend/media/avatars/<user_id>/`.
3. Flutter-klienten cache: uppladdade/visade filer sparas lokalt under operativsystemets tempkatalog i mappen `wisdom_media/`. Den kan rensas helt utan att påverka backenden.

Behov av att starta om backend efter rensning: nej, men eventuella öppnade filer bör laddas om i UI.

## Felavhjälpning
- **`psql: FATAL: password authentication failed`** – kontrollera lösenord i `LOCAL_DATABASE_URL` eller sätt `PGPASSWORD` innan du kör scriptet.
- **`function auth.uid() does not exist`** – se till att `database/bootstrap.sql` kördes först.
- **Behov av rent startläge** – töm volymen `~/wisdom_db/data` eller kör `docker compose down -v` i den katalogen och starta om innan `setup_local_backend.sh`.

Happy hacking!
