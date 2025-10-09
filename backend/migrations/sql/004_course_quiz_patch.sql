-- Align course_quizzes schema with application expectations.
-- Idempotent patch.

begin;

alter table app.course_quizzes
  add column if not exists title text,
  add column if not exists pass_score integer default 80,
  add column if not exists created_by uuid references app.profiles(user_id);

commit;
