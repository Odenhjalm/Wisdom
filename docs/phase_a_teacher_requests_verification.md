# Phase A — Teacher Requests Migrering (verifiering)

## Efterkörningschecklista
- [ ] Bekräfta antal rader
  - `select count(*) from app.teacher_requests;`
  - `select count(*) from app.certificates where title = 'Läraransökan';`
  - `select count(*) from app.teacher_approvals;`
  - förväntan: certificates ≥ teacher_requests, approvals = approved requests.
- [ ] Stickprov: `select tr.user_id, tr.status, c.status, ta.approved_at from app.teacher_requests tr left join app.certificates c on c.user_id = tr.user_id and c.title = 'Läraransökan' left join app.teacher_approvals ta on ta.user_id = tr.user_id limit 20;`
- [ ] Säkerställ att dubbla körningar är idempotenta (ON CONFLICT).
- [ ] Besluta status för `app.teacher_requests`: behåll som legacy vy, fortsätt skriva ansökningar eller avveckla.
- [ ] Uppdatera klienter att läsa `certificates`/`teacher_approvals` (se `docs/phase_a_flutter_updates.md`).

## Åtgärdslogg
- 2025-09-25: Migration körd i produktion (SQL Editor). Ingen rollback behövdes.
- _TODO_: Efter kundverifiering, besluta om `teacher_requests` ska tömmas/arkiveras.

Uppdateras när validering är klar.
