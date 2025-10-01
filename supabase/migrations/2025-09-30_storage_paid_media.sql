begin;

-- Buckets
insert into storage.buckets (id, name, public)
select 'public-media', 'public-media', true
where not exists (select 1 from storage.buckets where id = 'public-media');

insert into storage.buckets (id, name, public)
select 'course-media', 'course-media', false
where not exists (select 1 from storage.buckets where id = 'course-media');

update storage.buckets set public = true where id = 'public-media';
update storage.buckets set public = false where id = 'course-media';

do $$
begin
  begin
    execute 'alter table storage.objects enable row level security';
  exception when others then
    -- Ignorera om vi saknar ägarskap; tabellen är redan RLS-aktiverad i Supabase.
    null;
  end;
end;
$$;

-- Clean up legacy storage policies that conflict with the new model
-- (DROP is idempotent)
drop policy if exists "course-media read" on storage.objects;
drop policy if exists "course-media teacher write" on storage.objects;
drop policy if exists "course_media_public_read" on storage.objects;
drop policy if exists "course_media_read" on storage.objects;
drop policy if exists "course_media_teacher_write" on storage.objects;
drop policy if exists "course_media_teacher_write" on storage.objects;
drop policy if exists "course_media_write" on storage.objects;
drop policy if exists "course_media_read" on storage.objects;
drop policy if exists "course_media_public_read" on storage.objects;
drop policy if exists "public read media" on storage.objects;
drop policy if exists "media_teacher_write" on storage.objects;
drop policy if exists "media_teacher_update" on storage.objects;
drop policy if exists "public_media_read" on storage.objects;
drop policy if exists "public_media_write" on storage.objects;
drop policy if exists "public_media_update" on storage.objects;
drop policy if exists "public_media_delete" on storage.objects;
drop policy if exists "course_media_select" on storage.objects;
drop policy if exists "course_media_insert" on storage.objects;
drop policy if exists "course_media_update" on storage.objects;
drop policy if exists "course_media_delete" on storage.objects;

-- Functions ---------------------------------------------------------------

-- Teacher helper delegating to app.is_teacher()
create or replace function public.user_is_teacher()
returns boolean
language sql
stable
security definer
set search_path = public, app
as $$
  select app.is_teacher();
$$;

grant execute on function public.user_is_teacher() to public;

-- Extract first UUID from a storage path
create or replace function public.course_id_from_path(p text)
returns uuid
language sql
immutable
as $$
  select nullif((regexp_matches(coalesce(p, ''), '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})'))[1], '')::uuid;
$$;

grant execute on function public.course_id_from_path(text) to public;

-- Access helper bridging to app.can_access_course when available
create or replace function public.user_has_course_access(p_course uuid)
returns boolean
language plpgsql
stable
security definer
set search_path = public, app
as $$
declare
  v_uid uuid := auth.uid();
  v_proc regproc;
  old_rowsec text;
  has_access boolean := false;
begin
  if p_course is null or v_uid is null then
    return false;
  end if;

  select to_regproc('app.can_access_course(uuid,uuid)') into v_proc;
  if v_proc is not null then
    return app.can_access_course(v_uid, p_course);
  end if;

  old_rowsec := coalesce(current_setting('row_security', true), 'on');
  perform set_config('row_security', 'off', true);
  begin
    if exists(select 1 from app.courses where id = p_course and is_free_intro) then
      has_access := true;
    elsif exists(select 1 from app.enrollments where user_id = v_uid and course_id = p_course) then
      has_access := true;
    elsif exists(select 1 from app.purchases where user_id = v_uid and course_id = p_course and status = 'succeeded') then
      has_access := true;
    elsif exists(select 1 from app.orders where user_id = v_uid and course_id = p_course and status = 'paid') then
      has_access := true;
    elsif exists(select 1 from app.memberships where user_id = v_uid and status = 'active') then
      has_access := true;
    end if;
  exception
    when others then
      perform set_config('row_security', old_rowsec, true);
      raise;
  end;
  perform set_config('row_security', old_rowsec, true);
  return coalesce(has_access, false);
end;
$$;

grant execute on function public.user_has_course_access(uuid) to authenticated;

-- Storage policies -------------------------------------------------------

create policy public_media_read
on storage.objects for select
  to public
  using (bucket_id = 'public-media');

create policy public_media_insert
on storage.objects for insert
  to authenticated
  with check (bucket_id = 'public-media' and public.user_is_teacher());

create policy public_media_update
on storage.objects for update
  to authenticated
  using (bucket_id = 'public-media' and public.user_is_teacher())
  with check (bucket_id = 'public-media' and public.user_is_teacher());

create policy public_media_delete
on storage.objects for delete
  to authenticated
  using (bucket_id = 'public-media' and public.user_is_teacher());

create policy course_media_select
on storage.objects for select
  to authenticated
  using (
    bucket_id = 'course-media'
    and (
      public.user_is_teacher()
      or public.user_has_course_access(public.course_id_from_path(name))
    )
  );

create policy course_media_insert
on storage.objects for insert
  to authenticated
  with check (bucket_id = 'course-media' and public.user_is_teacher());

create policy course_media_update
on storage.objects for update
  to authenticated
  using (bucket_id = 'course-media' and public.user_is_teacher())
  with check (bucket_id = 'course-media' and public.user_is_teacher());

create policy course_media_delete
on storage.objects for delete
  to authenticated
  using (bucket_id = 'course-media' and public.user_is_teacher());

commit;
