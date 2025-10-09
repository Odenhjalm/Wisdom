-- Allow quiz_questions.course_id to be nullable (quiz-scoped data stored via quiz_id).

begin;

alter table app.quiz_questions
  alter column course_id drop not null;

commit;
