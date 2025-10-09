# Wisdom Local Backend

FastAPI-baserad backend som ersätter Supabase för den lokala utvecklingsmiljön. Den pratar direkt med Postgres-instansen i `~/wisdom_db` och exponerar REST-endpoints för auth, profiler och kurser.

## Struktur
```
backend/
├── app/
│   ├── config.py        # Laddar miljövariabler och appinställningar
│   ├── db.py            # Psycopg connection pool och hjälpfunktioner
│   ├── auth.py          # Hashning, JWT-hantering och Depends-helpers
│   ├── models.py        # SQL-frågor (enkel Query-layer utan ORM)
│   ├── schemas.py       # Pydantic-modeller
│   ├── routes/
│   │   ├── auth.py      # /auth/register, /auth/login
│   │   ├── profiles.py  # /profiles/me
│   │   └── courses.py   # /courses, /courses/{id}
│   └── main.py          # FastAPI-app, inkluderar routers
├── pyproject.toml
└── README.md
```

## Kom igång
1. Skapa virtuell miljö (Poetry eller `python -m venv`).
2. Installera beroenden: `poetry install` eller `pip install -r requirements.txt` (kan genereras via `poetry export`).
3. Kopiera `.env.example` till `.env` och sätt:
   ```env
   DATABASE_URL=postgresql://oden:1124vattnaRn@localhost:5432/wisdom
   JWT_SECRET=change-me
   JWT_EXPIRES_MINUTES=15
   JWT_REFRESH_EXPIRES_MINUTES=1440
   # Stripe (valfritt men krävs för betalningsflödet)
   STRIPE_SECRET_KEY=sk_test_xxx
   STRIPE_WEBHOOK_SECRET=whsec_xxx
   ```
   > Tips: håll hemligheter utanför git och injicera dem via miljövariabler, `direnv` eller CI-secret stores.
4. Starta servern:
   ```bash
   poetry run uvicorn app.main:app --reload
   ```
5. Swagger finns på `http://localhost:8000/docs`.

## Autentisering
- Passwords lagras i `auth.users.encrypted_password` (bcrypt via `pgcrypto`).
- `POST /auth/login` och `POST /auth/register` returnerar både access- och refresh-token (JWT, HS256). Access-token lever 15 minuter, refresh-token kan roteras via `POST /auth/refresh`.
- Skyddade endpoints använder `Authorization: Bearer <token>`; klienten refreschar automatiskt när access-token har gått ut.

## Tests
Kör `poetry run pytest` (exempeltests kan läggas i `backend/tests/`).

## Kursendpoints (urval)
- `GET /courses` – lista publicerade kurser med filter för `free_intro`, `search` och `limit`.
- `GET /courses/intro-first` – returnerar första publicerade gratis introduktionskursen (eller `null`).
- `GET /config/free-course-limit` – hämtar nuvarande tak för gratisintrokurser per användare.
- `GET /courses/{id}/access` – sammanfattar åtkomststatus (enrolled, gratis-kvot, senaste order, aktiv prenumeration).
- `POST /courses/{id}/enroll` – anmäler inloggad användare till gratisintrokurs, `GET /courses/{id}/enrollment` visar status.

## Vidare arbete
- Lägg till fler endpoints (bookings, meddelanden, mm) enligt behov.
- Lägg till rollkontroller (admin/teacher) innan skrivoperationer.
- Integrera med Flutter genom att ersätta `SupabaseClient`-anrop med HTTP mot denna backend.
