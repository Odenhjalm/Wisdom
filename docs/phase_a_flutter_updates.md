# Phase A — Flutter-uppdateringar för nya roller

## Mål
Appen ska använda nya fälten `role_v2` och `is_admin` och i nästa steg `user_role`-begrepp (`user`/`professional`/`teacher`) i stället för legacy `role`/`admin`-logik.

## Påverkade komponenter
- `lib/data/models/profile.dart`
  - Läser endast `role`; behöver utökas med `roleV2`, `isAdmin` och ev. `userRole` enum.
- `AuthService.isTeacher()` / `AuthService.isAdmin()` (om finns) samt guards i `app_router.dart`.
- UI-sidor som kontrollerar `profile.role` direkt (`StudioPage`, `community profile`, m.fl.).
- Stripe/teacher ansökningsflöden där admin/teacher-check sker på klienten.

## Föreslagna steg
1. Introducera `UserRole` enum i klienten (`user`, `professional`, `teacher`) och mappa från API-fälten.
2. Uppdatera `Profile`-modell med nya fält: `roleLegacy`, `userRole`, `isAdmin`.
3. Refaktorera AuthService (och ev. Riverpod providers) att använda `userRole` / `isAdmin`.
4. Justera UI-gates (Studio, Events) så `professional` får event-skapande, `teacher` full tillgång.
5. Lägg in fallback: om API ännu inte returnerar `role_v2`, defaulta till `user` men logga varning i debug.
6. Uppdatera tester/mocks (om skrivs) med nya fält.
7. Uppdatera admin-panelen att läsa `certificates`/`teacher_approvals` (klar 2025-09-25).

## TODO
- [x] Inventera alla `role == 'teacher'`/`role == 'admin'`-jämförelser i Dart-koden (`rg "role ==" lib`).
- [x] Uppdatera `AuthService`, `AppRouter`, `BookingPage`, `StudioPage` (träffar från sökning) att använda `userRole` + `isAdmin`.
- [ ] Bestäm format på API-svar (Supabase SELECT) så `role_v2` och `is_admin` alltid återkommer.
- [x] Implementera modell + service-uppdateringar.
- [ ] Verifiera navigation/guard-flöde efter refaktor.

Uppdateras när klientarbetet startar.
