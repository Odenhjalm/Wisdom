-- create_teacher_local.sql
-- Idempotent helper för att skapa eller uppdatera en användare som lärare.
-- Användning:
-- PGPASSWORD=... psql postgresql://user@host/db \
--   -v email="user@example.com" \
--   -v password="hemligt" \
--   -v display_name="Namn" \
--   -f scripts/create_teacher_local.sql

\set ON_ERROR_STOP on
\if :{?email}
\else
\set email 'teacher.local@example.com'
\endif
\if :{?password}
\else
\set password 'ChangeMe123!'
\endif
\if :{?display_name}
\else
\set display_name 'Local Teacher'
\endif

begin;

with params as (
  select
    :'email'::text as email,
    :'password'::text as password,
    nullif(:'display_name', '')::text as display_name
),
hashed as (
  select
    email,
    password,
    display_name,
    crypt(password, gen_salt('bf', 10)) as hashed_pwd
  from params
),
upsert_user as (
  insert into auth.users (
    id,
    email,
    encrypted_password,
    aud,
    role,
    raw_app_meta_data,
    raw_user_meta_data,
    email_confirmed_at,
    last_sign_in_at,
    created_at,
    updated_at
  )
  select
    coalesce((select id from auth.users where lower(email) = lower(h.email)), gen_random_uuid()),
    h.email,
    h.hashed_pwd,
    'authenticated',
    'authenticated',
    jsonb_build_object('role', 'teacher'),
    jsonb_build_object('seed', false),
    now(),
    now(),
    now(),
    now()
  from hashed h
  on conflict (id) do update
    set email = excluded.email,
        encrypted_password = excluded.encrypted_password,
        raw_app_meta_data = excluded.raw_app_meta_data,
        raw_user_meta_data = excluded.raw_user_meta_data,
        email_confirmed_at = excluded.email_confirmed_at,
        last_sign_in_at = excluded.last_sign_in_at,
        updated_at = now()
  returning id, email
),
identity as (
  insert into auth.identities (
    user_id,
    provider,
    provider_id,
    identity_data,
    email,
    last_sign_in_at,
    created_at,
    updated_at
  )
  select
    uu.id,
    'email',
    uu.email,
    jsonb_build_object('email', uu.email, 'sub', uu.id::text, 'email_verified', true),
    uu.email,
    now(),
    now(),
    now()
  from upsert_user uu
  on conflict (provider_id, provider) do update
    set identity_data = excluded.identity_data,
        email = excluded.email,
        last_sign_in_at = excluded.last_sign_in_at,
        updated_at = excluded.updated_at
  returning user_id, email
),
profile as (
  insert into app.profiles (
    user_id,
    email,
    display_name,
    role_v2,
    is_admin,
    created_at,
    updated_at
  )
  select
    i.user_id,
    i.email,
    coalesce((select display_name from params), initcap(split_part(i.email, '@', 1)) || ' User'),
    'teacher',
    false,
    now(),
    now()
  from identity i
  on conflict (user_id) do update
    set email = excluded.email,
        display_name = excluded.display_name,
        role_v2 = excluded.role_v2,
        is_admin = excluded.is_admin,
        updated_at = now()
  returning user_id, email
),
permissions as (
  insert into app.teacher_permissions (
    profile_id,
    can_edit_courses,
    can_publish,
    granted_by,
    granted_at
  )
  select
    p.user_id,
    true,
    true,
    p.user_id,
    now()
  from profile p
  on conflict (profile_id) do update
    set can_edit_courses = true,
        can_publish = true,
        granted_by = excluded.granted_by,
        granted_at = now()
  returning profile_id
),
approval as (
  insert into app.teacher_approvals (user_id, approved_by, approved_at)
  select
    p.user_id,
    p.user_id,
    now()
  from profile p
  on conflict (user_id) do update
    set approved_by = excluded.approved_by,
        approved_at = excluded.approved_at
  returning user_id
)
insert into app.teacher_directory (user_id, headline, created_at)
select
  p.user_id,
  'Approved teacher (local setup)',
  now()
from profile p
on conflict (user_id) do update
  set headline = excluded.headline,
      created_at = app.teacher_directory.created_at;

commit;

select 'Teacher account ready: ' || :'email' as info;
