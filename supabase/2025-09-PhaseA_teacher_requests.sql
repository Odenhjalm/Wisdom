-- Phase A: migrate teacher_requests into certificates/approvals (draft)

begin;

-- Ensure unique pair via index (usable by ON CONFLICT)
CREATE UNIQUE INDEX IF NOT EXISTS idx_certificates_user_title
  ON app.certificates (user_id, title);

-- Cache teacher_requests rows for reuse
DROP TABLE IF EXISTS _tr_src;
CREATE TEMP TABLE _tr_src AS
SELECT
  tr.user_id,
  coalesce(tr.message, '') AS message,
  tr.status,
  tr.reviewed_by,
  tr.created_at,
  tr.updated_at
FROM app.teacher_requests tr;

INSERT INTO app.certificates (id, user_id, title, status, notes, created_at, updated_at)
SELECT
  COALESCE(existing.id, gen_random_uuid()),
  src.user_id,
  'Läraransökan' AS title,
  CASE src.status
    WHEN 'approved' THEN 'verified'
    WHEN 'rejected' THEN 'rejected'
    ELSE 'pending'
  END AS status,
  NULLIF(src.message, '') AS notes,
  COALESCE(existing.created_at, src.created_at),
  COALESCE(src.updated_at, src.created_at)
FROM _tr_src src
LEFT JOIN app.certificates existing
  ON existing.user_id = src.user_id
 AND existing.title = 'Läraransökan'
ON CONFLICT (user_id, title) DO UPDATE SET
  status = EXCLUDED.status,
  notes = EXCLUDED.notes,
  updated_at = EXCLUDED.updated_at;

-- Sync teacher approvals for approved requests
INSERT INTO app.teacher_approvals (user_id, approved_by, approved_at)
SELECT
  src.user_id,
  src.reviewed_by,
  COALESCE(src.updated_at, now())
FROM _tr_src src
WHERE src.status = 'approved'
ON CONFLICT (user_id) DO UPDATE SET
  approved_by = EXCLUDED.approved_by,
  approved_at = EXCLUDED.approved_at;

DROP TABLE IF EXISTS _tr_src;

commit;
