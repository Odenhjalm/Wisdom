# Andlig Väg – Social Plattform (Flutter + Supabase)

Det här repo:t innehåller en ljus, proffsig social plattform byggd på Flutter + Supabase (`supabase_flutter`).

## Vad som skapats/ändrats

- SQL‑migration: `lib/data/supabase/init/20250913_social.sql` – tabeller (posts, follows, reviews, notifications, meditations), RLS‑policies, RPC (`follow`/`unfollow`, `get_my_profile`, `ensure_profile`), grants.
- Certifikatflöde (tidigare steg): `lib/data/supabase/init/20250913_certificates.sql` + UI i profil/lärarprofil + adminverifiering.
- Router: offentliga profilvyer `/profile/:id`, servicedetalj `/service/:id`, guards för `/messages` och `/service`.
- Home: enkel feed + inläggs‑composer.
- Community: cert‑badges, specialiteter från certifikat som fallback.
- Admin: granska och verifiera certifikat.

## Hur du testar (snabbguide)

1) Miljö
- Skapa `.env` enligt `.env.example` med `SUPABASE_URL` och `SUPABASE_ANON`.

2) Initiera Supabase‑schema
- Kör SQL i Supabase SQL Editor i ordning:
  - `lib/data/supabase/init/20250913_community.sql` (om inte redan körd)
  - `lib/data/supabase/init/20250913_certificates.sql`
  - `lib/data/supabase/init/20250913_teacher_approval_gate.sql`
  - `lib/data/supabase/init/20250913_social.sql`

3) Kör appen
```
flutter clean && flutter pub get && flutter run
```

4) Flöden
- Utloggad: besök `/landing`.
- Logga in via Profil. Efter login → `/home`.
- Home: skriv ett inlägg i composer, se det i feeden.
- Community: se lärare, cert‑badge “N cert”. Öppna lärarprofil.
- Profil (egen): lägg till certifikat → be admin verifiera → ansök som lärare i Studio (låst tills cert verifierats).
- Profil (publik): `/profile/:id` – följknapp, tjänster, meditationer.
- Tjänst: `/service/:id` – läs mer, köp/boka (öppnar checkout via edge‑function om konfigurerad).
- Meddelanden: `/messages/dm/:id` eller `/messages/service/:id` – enkel chat (RLS redan på plats via tidigare migration).

## Notiser
- Alla databasanrop använder `Supa.client.app` (schema `app`) eller `schema('app').rpc(...)`.
- UI följer Material 3, med ljus bakgrund och diskreta skuggor. Landing/Home har hero‑bakgrund som täcker utan vita ramar.

## Nästa steg (förbättringar)
- Admin: krav i DB (redan) på verifierade cert för lärarstatus; bygg UI‑feedback vid avslag.
- Services: omdömen på service‑detalj och rating‑aggregering i listor.
- Messages: kanalöversikt (samlad DM + service), olästa badge via notifications.
- Meditations: Studio‑flik för CRUD + uppladdning till `media/meditations/<teacher_id>/...` (RLS finns).
