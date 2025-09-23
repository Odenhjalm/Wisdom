-- Owner policies for app.courses/modules/lessons (idempotent)

begin;

drop policy if exists courses_owner_manage on app.courses;
drop policy if exists modules_owner_manage on app.modules;
drop policy if exists lessons_owner_manage on app.lessons;

create policy courses_owner_manage on app.courses
  for all
  to authenticated
  using (created_by = auth.uid() or app.is_admin())
  with check (created_by = auth.uid() or app.is_admin());

create policy modules_owner_manage on app.modules
  for all
  to authenticated
  using (exists (
    select 1 from app.courses c
    where c.id = app.modules.course_id
      and (c.created_by = auth.uid() or app.is_admin())
  ))
  with check (exists (
    select 1 from app.courses c
    where c.id = app.modules.course_id
      and (c.created_by = auth.uid() or app.is_admin())
  ));

create policy lessons_owner_manage on app.lessons
  for all
  to authenticated
  using (exists (
    select 1 from app.modules m
    join app.courses c on c.id = m.course_id
    where m.id = app.lessons.module_id
      and (c.created_by = auth.uid() or app.is_admin())
  ))
  with check (exists (
    select 1 from app.modules m
    join app.courses c on c.id = m.course_id
    where m.id = app.lessons.module_id
      and (c.created_by = auth.uid() or app.is_admin())
  ));

commit;
