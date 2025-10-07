-- ============================================================================
-- seed.sql
-- Opinionated seed data for local development. Aligns with schema.sql
-- schema (role_v2 enum: user/professional/teacher + is_admin flag).
-- ============================================================================

begin;

with sample_users(id, email, role_v2, is_admin) as (
  values
    ('11111111-1111-1111-1111-111111111111'::uuid, 'admin@example.com',   'teacher', true),
    ('22222222-2222-2222-2222-222222222222'::uuid, 'teacher@example.com', 'teacher', false),
    ('33333333-3333-3333-3333-333333333333'::uuid, 'student@example.com', 'user',    false)
)
insert into auth.users (id, email, aud, role, raw_app_meta_data, raw_user_meta_data, email_confirmed_at, last_sign_in_at, created_at, updated_at)
select
  id,
  email,
  'authenticated',
  'authenticated',
  jsonb_build_object('role', case when is_admin then 'admin' else role_v2 end),
  jsonb_build_object('seed', true),
  now(),
  now(),
  now(),
  now()
from sample_users
on conflict (id) do update
  set email = excluded.email,
      raw_app_meta_data = excluded.raw_app_meta_data,
      raw_user_meta_data = excluded.raw_user_meta_data,
      email_confirmed_at = coalesce(auth.users.email_confirmed_at, excluded.email_confirmed_at),
      last_sign_in_at = coalesce(auth.users.last_sign_in_at, excluded.last_sign_in_at),
      updated_at = now();

with sample_users(id, email) as (
  values
    ('11111111-1111-1111-1111-111111111111'::uuid, 'admin@example.com'),
    ('22222222-2222-2222-2222-222222222222'::uuid, 'teacher@example.com'),
    ('33333333-3333-3333-3333-333333333333'::uuid, 'student@example.com')
)
insert into auth.identities (user_id, provider, provider_id, identity_data, last_sign_in_at, created_at, updated_at, email)
select
  id,
  'email',
  email,
  jsonb_build_object('sub', id::text, 'email', email, 'email_verified', true),
  now(),
  now(),
  now(),
  email
from sample_users
on conflict (provider_id, provider) do update
  set identity_data = excluded.identity_data,
      last_sign_in_at = excluded.last_sign_in_at,
      updated_at = excluded.updated_at;

-- Seed passwords for local auth (bcrypt via pgcrypto crypt)
select set_config('app.seed_pwd_admin', crypt('admin123', gen_salt('bf', 10)), true);
select set_config('app.seed_pwd_teacher', crypt('teacher123', gen_salt('bf', 10)), true);
select set_config('app.seed_pwd_student', crypt('student123', gen_salt('bf', 10)), true);

update auth.users
set encrypted_password = current_setting('app.seed_pwd_admin', true)
where id = '11111111-1111-1111-1111-111111111111'::uuid;

update auth.users
set encrypted_password = current_setting('app.seed_pwd_teacher', true)
where id = '22222222-2222-2222-2222-222222222222'::uuid;

update auth.users
set encrypted_password = current_setting('app.seed_pwd_student', true)
where id = '33333333-3333-3333-3333-333333333333'::uuid;

with sample_users(id, email, role_v2, is_admin) as (
  values
    ('11111111-1111-1111-1111-111111111111'::uuid, 'admin@example.com',   'teacher', true),
    ('22222222-2222-2222-2222-222222222222'::uuid, 'teacher@example.com', 'teacher', false),
    ('33333333-3333-3333-3333-333333333333'::uuid, 'student@example.com', 'user',    false)
)
insert into app.profiles (user_id, email, display_name, role_v2, is_admin)
select
  id,
  email,
  initcap(split_part(email, '@', 1)) || ' User',
  role_v2::app.user_role,
  is_admin
from sample_users
on conflict (user_id) do update
  set email = excluded.email,
      display_name = excluded.display_name,
      role_v2 = excluded.role_v2,
      is_admin = excluded.is_admin,
      updated_at = now();

with teacher_users(user_id) as (
  values
    ('11111111-1111-1111-1111-111111111111'::uuid),
    ('22222222-2222-2222-2222-222222222222'::uuid)
)
insert into app.teacher_directory (user_id, headline, created_at)
select
  user_id,
  'Seeded teacher profile for local development.',
  now()
from teacher_users
on conflict (user_id) do update
  set headline = excluded.headline,
      created_at = app.teacher_directory.created_at;

insert into app.courses (id, slug, title, description, is_free_intro, price_cents, is_published, created_by)
values (
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  'mindful-breathing',
  'Mindful Breathing',
  'Introductory course on mindful breathing techniques.',
  true,
  0,
  true,
  '22222222-2222-2222-2222-222222222222'
)
on conflict (id) do update set
  slug = excluded.slug,
  title = excluded.title,
  description = excluded.description,
  is_free_intro = excluded.is_free_intro,
  price_cents = excluded.price_cents,
  is_published = excluded.is_published,
  created_by = excluded.created_by,
  updated_at = now();

insert into app.modules (id, course_id, title, position)
values (
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  'Getting Started',
  1
)
on conflict (id) do update set
  title = excluded.title,
  course_id = excluded.course_id,
  position = excluded.position;

insert into app.lessons (id, module_id, title, content_markdown, is_intro, position)
values (
  'cccccccc-cccc-cccc-cccc-cccccccccccc',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  'Breathing Basics',
  '# Welcome\nDet här är en introduktion till mindful breathing.',
  true,
  1
)
on conflict (id) do update set
  module_id = excluded.module_id,
  title = excluded.title,
  content_markdown = excluded.content_markdown,
  is_intro = excluded.is_intro,
  position = excluded.position;

insert into app.enrollments (id, user_id, course_id, source)
values (
  'dddddddd-dddd-dddd-dddd-dddddddddddd',
  '33333333-3333-3333-3333-333333333333',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  'purchase'
)
on conflict (id) do update set
  user_id = excluded.user_id,
  course_id = excluded.course_id,
  source = excluded.source;

commit;
