-- Migration: introduce media_objects table with avatar and lesson links
-- Idempotent to allow repeated executions in local environments.

begin;

create table if not exists app.media_objects (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references app.profiles(user_id) on delete set null,
  storage_path text not null,
  storage_bucket text not null default 'lesson-media',
  content_type text,
  byte_size bigint not null default 0 check (byte_size >= 0),
  checksum text,
  original_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_media_objects_owner on app.media_objects(owner_id);
create unique index if not exists idx_media_objects_path_bucket on app.media_objects(storage_path, storage_bucket);

alter table app.media_objects alter column storage_bucket set default 'lesson-media';
update app.media_objects set storage_bucket = 'lesson-media' where storage_bucket is null;
update app.media_objects set byte_size = coalesce(byte_size, 0);
alter table app.media_objects alter column byte_size set default 0;
alter table app.media_objects alter column byte_size set not null;
do $$
begin
  alter table app.media_objects
    add constraint media_objects_byte_size_check check (byte_size >= 0);
exception
  when duplicate_object then null;
end$$;

alter table app.lesson_media
  add column if not exists storage_bucket text,
  add column if not exists media_id uuid references app.media_objects(id);

alter table app.lesson_media alter column storage_bucket set default 'lesson-media';
alter table app.lesson_media alter column storage_path drop not null;
create index if not exists idx_media_media_object on app.lesson_media(media_id);

alter table app.profiles
  add column if not exists avatar_media_id uuid references app.media_objects(id);
create index if not exists idx_profiles_avatar_media on app.profiles(avatar_media_id);

-- Backfill media objects for existing lesson files so we retain references.
with source_rows as (
  select
    lm.id as lesson_media_id,
    lm.storage_path,
    coalesce(lm.storage_bucket, 'lesson-media') as storage_bucket,
    lm.created_at,
    coalesce(c.created_by, admin_profiles.user_id) as owner_id
  from app.lesson_media lm
  join app.lessons l on l.id = lm.lesson_id
  join app.modules m on m.id = l.module_id
  join app.courses c on c.id = m.course_id
  left join lateral (
    select p.user_id
    from app.profiles p
    where p.is_admin = true
    order by p.user_id
    limit 1
  ) as admin_profiles on true
  where lm.media_id is null
    and lm.storage_path is not null
), inserted as (
  insert into app.media_objects (owner_id, storage_path, storage_bucket, created_at, updated_at)
  select
    owner_id,
    storage_path,
    storage_bucket,
    created_at,
    created_at
  from source_rows sr
  where not exists (
    select 1
    from app.media_objects mo
    where mo.storage_path = sr.storage_path
      and coalesce(mo.storage_bucket, 'lesson-media') = sr.storage_bucket
  )
  returning id, storage_path, storage_bucket
)
update app.lesson_media lm
set media_id = mo.id,
    storage_bucket = coalesce(lm.storage_bucket, mo.storage_bucket)
from app.media_objects mo
where lm.media_id is null
  and lm.storage_path = mo.storage_path
  and coalesce(lm.storage_bucket, 'lesson-media') = mo.storage_bucket;

-- Ensure lesson_media rows without media references use default bucket.
update app.lesson_media
set storage_bucket = 'lesson-media'
where storage_bucket is null;

do $$
begin
  alter table app.lesson_media
    add constraint lesson_media_path_or_object
      check (media_id is not null or storage_path is not null);
exception
  when duplicate_object then null;
end$$;

alter table app.media_objects enable row level security;

-- Allow media owners (and admins) to manage their uploads directly.
drop policy if exists "media_owner_manage" on app.media_objects;
create policy "media_owner_manage" on app.media_objects for all
using (owner_id = auth.uid() or app.is_admin())
with check (owner_id = auth.uid() or app.is_admin());

-- Allow reading media that is exposed via lessons or profile avatars.
drop policy if exists "media_linked_read" on app.media_objects;
create policy "media_linked_read" on app.media_objects for select
using (
  app.is_teacher()
  or exists (
    select 1
    from app.lesson_media lm
    join app.lessons l on l.id = lm.lesson_id
    join app.modules m on m.id = l.module_id
    join app.courses c on c.id = m.course_id
    where lm.media_id = media_objects.id
      and c.is_published = true
      and (l.is_intro = true or app.can_access_course(auth.uid(), c.id))
  )
  or exists (
    select 1
    from app.profiles p
    where p.avatar_media_id = media_objects.id
  )
);

commit;
