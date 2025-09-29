# Phase A — Teacher Requests till Certificates

## Nuvarande struktur (`app.teacher_requests`)
- `id uuid`
- `user_id uuid`
- `message text`
- `status text` (`pending|approved|rejected`)
- `reviewed_by uuid`
- `created_at timestamptz`
- `updated_at timestamptz`

## Målstruktur (`app.certificates` + `app.teacher_approvals`)
- `certificates`
  - `user_id`
  - `title` (kräver värde — föreslås "Läraransökan")
  - `status` (`pending|verified|rejected`)
  - `notes` (fri text, t.ex. message)
  - `evidence_url` (kan lämnas null)
  - `updated_at`
- `teacher_approvals`
  - `user_id`
  - `approved_by`
  - `approved_at`

## Föreslagen migrering
1. Säkerställ unikt index `idx_certificates_user_title` på `(user_id, title)` (ersätter constraint och fungerar med `ON CONFLICT`).
2. För varje rad i `app.teacher_requests`:
   - Skapa/uppdatera rad i `app.certificates` med:
     - `title = 'Läraransökan'`
     - `status = CASE WHEN status='approved' THEN 'verified' WHEN status='rejected' THEN 'rejected' ELSE 'pending' END`
     - `notes = message`
     - `created_at`/`updated_at` från befintliga tidsstämplar.
   - Om status = 'approved': skapa/uppdatera `app.teacher_approvals` med `approved_by`, `approved_at = updated_at`.
3. Efter migrering, besluta om `app.teacher_requests` ska avvecklas eller lämnas som legacy vy.
4. Uppdatera Flutterkoden att använda `certificates`/`teacher_approvals` i stället för `teacher_requests`.

## Öppna frågor
- Ska användaren kunna lämna flera ansökningar? (`teacher_requests` hade unique constraint). Om ja, behöver `certificates` tillåta fler poster per user för olika titlar.
- Behöver vi behålla historik av meddelanden/kommentarer utöver `notes`? Ev. skapa logg-tabell.

Uppdatera dokumentet när migreringsskript tas fram.

## Status 2025-09-25
- `supabase/2025-09-PhaseA_teacher_requests.sql` körd i Supabase; data nu speglad till `certificates`/`teacher_approvals`.
- Flutter-koden skriver/läser nu mot `certificates` och nytt admin-flöde använder `teacher_approvals`-synk.
- Skriptet använder temporär tabell `_tr_src` för att återanvända data mellan inserts.
- Nästa steg: verifiera migrerad data, besluta om legacy `teacher_requests` ska behållas som inkommande kö eller fasas ut.
