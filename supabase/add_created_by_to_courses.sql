-- Add created_by column to app.courses and set FK (idempotent)

begin;

alter table if exists app.courses
  add column if not exists created_by uuid;

-- Add foreign key if missing
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.table_constraints tc
    WHERE tc.table_schema = 'app'
      AND tc.table_name = 'courses'
      AND tc.constraint_type = 'FOREIGN KEY'
      AND tc.constraint_name = 'courses_created_by_fkey'
  ) THEN
    ALTER TABLE app.courses
      ADD CONSTRAINT courses_created_by_fkey
      FOREIGN KEY (created_by) REFERENCES app.profiles(user_id) ON DELETE SET NULL;
  END IF;
END$$;

commit;
