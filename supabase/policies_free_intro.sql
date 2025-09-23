-- Free intro access policies (idempotent)

begin;

drop policy if exists courses_free_intro_read on app.courses;
drop policy if exists modules_free_intro_read on app.modules;
drop policy if exists lessons_free_intro_read on app.lessons;

alter table if exists app.courses enable row level security;
alter table if exists app.modules enable row level security;
alter table if exists app.lessons enable row level security;

create policy courses_free_intro_read
  on app.courses
  for select
  to anon, authenticated
  using (is_free_intro = true);

create policy modules_free_intro_read
  on app.modules
  for select
  to anon, authenticated
  using (exists (
    select 1
    from app.courses c
    where c.id = app.modules.course_id
      and c.is_free_intro = true
  ));

create policy lessons_free_intro_read
  on app.lessons
  for select
  to anon, authenticated
  using (exists (
    select 1
    from app.modules m
    join app.courses c on c.id = m.course_id
    where m.id = app.lessons.module_id
      and c.is_free_intro = true
  ));

commit;
