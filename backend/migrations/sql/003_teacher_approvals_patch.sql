-- Ensure teacher_approvals has approval metadata columns expected by application code.
-- Idempotent migration.

begin;

alter table app.teacher_approvals
  add column if not exists approved_by uuid references app.profiles(user_id),
  add column if not exists approved_at timestamptz;

commit;
