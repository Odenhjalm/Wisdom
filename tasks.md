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
