\set ON_ERROR_STOP on
\if :{?email}
\else
\set email 'teacher.local@example.com'
\endif

begin;

-- Resolve target user (case-insensitive)
with target as (
  select u.id as user_id, u.email
  from auth.users u
  where lower(u.email) = lower(:'email')
)
insert into app.profiles (user_id, email, display_name, role_v2, is_admin, created_at, updated_at)
select t.user_id,
       t.email,
       coalesce(p.display_name, split_part(t.email, '@', 1)),
       'teacher',
       false,
       coalesce(p.created_at, now()),
       now()
from target t
left join app.profiles p on p.user_id = t.user_id
on conflict (user_id) do update
set role_v2   = excluded.role_v2,
    is_admin  = excluded.is_admin,
    updated_at= excluded.updated_at,
    display_name = coalesce(app.profiles.display_name, excluded.display_name);

-- Ensure canonical role fields are synced
update app.profiles
set role_v2 = 'teacher',
    is_admin = false,
    updated_at = now()
where lower(email) = lower(:'email');

-- Teacher permissions (edit + publish)
with target as (
  select p.user_id
  from app.profiles p
  where lower(p.email) = lower(:'email')
), granter as (
  select user_id
  from app.profiles
  where is_admin = true
  order by created_at
  limit 1
)
insert into app.teacher_permissions (profile_id, can_edit_courses, can_publish, granted_by, granted_at)
select t.user_id,
       true,
       true,
       coalesce((select user_id from granter), t.user_id),
       now()
from target t
on conflict (profile_id) do update
set can_edit_courses = excluded.can_edit_courses,
    can_publish     = excluded.can_publish,
    granted_by      = excluded.granted_by,
    granted_at      = excluded.granted_at;

-- Approvals (upsert)
insert into app.teacher_approvals (user_id, approved_by, approved_at)
select p.user_id,
       coalesce((select user_id from app.profiles where is_admin = true order by created_at limit 1), p.user_id),
       now()
from app.profiles p
where lower(p.email) = lower(:'email')
on conflict (user_id) do update
set approved_by = excluded.approved_by,
    approved_at = excluded.approved_at;

-- Certificate (Läraransökan) verified
update app.certificates
set status = 'verified',
    notes = 'Granted via grant_teacher_access.sql',
    updated_at = now()
where user_id in (
        select user_id from app.profiles where lower(email) = lower(:'email')
      )
  and title = 'Läraransökan';

insert into app.certificates (user_id, title, status, notes, created_at, updated_at)
select p.user_id,
       'Läraransökan',
       'verified',
       'Granted via grant_teacher_access.sql',
       now(),
       now()
from app.profiles p
where lower(p.email) = lower(:'email')
  and not exists (
        select 1 from app.certificates c
        where c.user_id = p.user_id
          and c.title = 'Läraransökan'
      );

commit;

-- Verification query
select p.user_id,
       p.email,
       p.role_v2,
       p.is_admin,
       ta.approved_at,
       c.status as certificate_status
from app.profiles p
left join app.teacher_approvals ta on ta.user_id = p.user_id
left join app.certificates c on c.user_id = p.user_id and c.title = 'Läraransökan'
where lower(p.email) = lower(:'email');
