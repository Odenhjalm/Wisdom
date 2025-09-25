## A) Projekt-info (maskad)

- Projektref & domän: https://xljbwvmk…glyhkt.supabase.co
  Project ref/ID: (xljbwvmk…glyhkt) 

Base URL (https://xljbwvmk…glyhkt.supabase.co)
Site URL i Supabase satt till http://localhost:5500 
Redirect URLs: 
http://localhost:5500/auth-callback
http://127.0.0.1:5500/auth-callback
visdom://auth-callback


- Auth providers (påslagna):
  - Confirm signup: aktiv JA (språk: engelska just nu, går att anpassa till svenska)
  - Password reset: aktiv JA (standardmall)
  - Magic Link: aktiv JA (mall med {{ .ConfirmationURL }})
  - Invite user: aktiv JA (standardmall)
  - Reauthentication: aktiv JA (standardmall)
  - Avsändare (From): Supabase default (ej egen SMTP än)

  - OAuth: 
  Google: 
    * Client ID: [REDACTED – hanteras i säker variabel]
    * Secret: [REDACTED – hanteras i säker variabel]
    Facebook:
    * Client ID: [REDACTED – hanteras i säker variabel]
    * Secret: [REDACTED – hanteras i säker variabel]
    * Scopes: openid, email, profile (ev. tillägg: …)

- Redirect/Site URL (EXAKTA, en per rad):
  - Site URL (prod): https://app.visdom.example/        # ***ingen token här***
  - Redirect URL (prod): https://app.visdom.example/auth-callback
  - Site URL (dev web): http://localhost:XXXXX/          # din Flutter dev-port
  - Redirect URL (dev web): http://localhost:XXXXX/auth-callback
  - Mobil (Android/iOS, app-scheme):
    visdom://auth-callback

- E-postmallar:
  - Confirm signup: ja (språk: en)
  - Password reset: ja (subject: “Återställ lösenord”)
  - Magic Link: ja
  - Avsändare (From): noreply@mail.app.supabase.io
  - via egen SMTP: nej , inte än

- Säkerhet/Auth-policy:
  - Email confirmation required: ja
  - Allow signups: ja 
  - JWT expiry: 3600 
  - Refresh rotation: PÅ 
  - MFA/Passkeys: på

- Nycklar (maskat i delning):
  - SUPABASE_URL: https://<project-ref>.supabase.co
  
  - SUPABASE_ANON_KEY: [REDACTED – se .env eller säkert valv]

  - (Server) SERVICE_ROLE_KEY: [REDACTED – lagras inte i repo]

## B) RLS-policy-check (skriv/uppdaterade tabeller)

- `profiles` – insättning/uppdatering kräver `auth.uid() = user_id`; klienten använder endast vyer via `profiles`.
- `courses` – lärare (verified) uppdaterar via RPC (`app.update_course`), RLS säkerställer att endast ägare/administratör kan skriva.
- `teacher_slots` – insert/select skyddat av `auth.uid() = teacher_id` eller adminroll.
- `bookings` – endast ägaren (`user_id`) kan skapa/läsa sina bokningar; lärare kan läsa slots de äger.
- `messages` – kanalbaserad RLS (`channel participants`), klienten filtrerar via `channel`-fälten.
- `tarot_requests` – `requester_id = auth.uid()` krävs vid insättning/läsning.
- RPC-funktioner (`app.*`) kontrollerar `auth.uid()` före skrivning; ingen Service Role används i appen.
