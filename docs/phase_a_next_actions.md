# Phase A — Nästa steg efter körda migrationer

## Databas
1. Verifiera utfallet av `supabase/2025-09-PhaseA_teacher_requests.sql` (se checklistan `docs/phase_a_teacher_requests_verification.md`).
2. Uppdatera `app.get_my_profile()` så den returnerar `role_v2`, `is_admin` (nuvarande SELECT `select *` hämtar allt men dokumentera att UI kräver fälten).
3. Planera borttagning av gamla kolumnen `role` och enum `app.role_type` efter att klienten enbart använder `role_v2`.
4. Granska att RLS-policys för `app.certificates`/`teacher_approvals` matchar nya flödet.

## Klient
1. Fortsätt ersätta `teacher_requests`-anrop med `certificates`/`teacher_approvals` i admin UI.
2. Inför tydlig rollhantering i Riverpod providers (komplettera `userProfileProvider` med caching/error-hantering).
3. Lägg till integrationstest (widget) som går genom Studio/Booking-flöden med en användare vars roll flaggas via `role_v2`.

## Process
1. Uppdatera README/produktdokumentation med nya rollnamnen (user/professional/teacher) och ansökningsflödet.
2. Sätt upp rutin för att nollställa `guest_claim_tokens` efter claim (enligt blueprinten).
3. Förbered retro för Foundation-fasen: vad fungerade, vad behöver justeras innan nästa våg.

Uppdateras löpande efter varje valideringssteg.
