-- Align quiz_questions schema with latest application expectations.
-- Idempotent patch.

begin;

alter table app.quiz_questions
  add column if not exists quiz_id uuid references app.course_quizzes(id) on delete cascade,
  add column if not exists position integer default 0,
  add column if not exists kind text default 'single',
  add column if not exists options jsonb default '{}'::jsonb,
  add column if not exists correct text,
  add column if not exists updated_at timestamptz not null default now();

-- Backfill quiz_id for legacy rows using course_id when available
update app.quiz_questions qq
set quiz_id = cq.id
from app.course_quizzes cq
where qq.quiz_id is null and cq.course_id = qq.course_id;

alter table app.quiz_questions
  drop column if exists correct_answer;

commit;
