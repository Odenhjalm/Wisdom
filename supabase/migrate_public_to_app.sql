-- Sync legacy public.* content into app.* schema (idempotent)
-- Run after deploying init_projectapp.sql and visdom_subscriptions_coupons.sql

begin;

-- 1) Profiles
with profile_src as (
  select
    p.id as user_id,
    coalesce(u.email, ap.email) as email,
    coalesce(nullif(p.full_name, ''), nullif(p.username, ''), u.email, ap.display_name) as display_name,
    coalesce(p.bio, ap.bio) as bio,
    coalesce(p.avatar_url, ap.photo_url) as photo_url,
    coalesce(ap.is_admin, (ap.role = 'admin')) as existing_admin,
    coalesce(
      ap.role_v2::text,
      case
        when coalesce(ap.is_admin, (ap.role = 'admin')) then 'teacher'
        when tp.can_edit_courses then 'teacher'
        when ap.role = 'teacher' then 'teacher'
        when ap.role = 'member' then 'professional'
        else 'user'
      end
    ) as role_v2_text,
    coalesce(p.created_at, ap.created_at, now()) as created_at
  from public.profiles p
  left join auth.users u on u.id = p.id
  left join public.teacher_permissions_compat tp on tp.profile_id = p.id and tp.can_edit_courses = true
  left join app.profiles ap on ap.user_id = p.id
)
insert into app.profiles (user_id, email, display_name, bio, photo_url, role, role_v2, is_admin, created_at, updated_at)
select
  src.user_id,
  src.email,
  src.display_name,
  src.bio,
  src.photo_url,
  case
    when src.existing_admin then 'admin'::app.role_type
    when src.role_v2_text = 'teacher' then 'teacher'::app.role_type
    when src.role_v2_text = 'professional' then 'member'::app.role_type
    else 'user'::app.role_type
  end,
  src.role_v2_text::app.user_role,
  src.existing_admin,
  src.created_at,
  now()
from profile_src src
on conflict (user_id) do update
set
  email = excluded.email,
  display_name = excluded.display_name,
  bio = excluded.bio,
  photo_url = excluded.photo_url,
  role = excluded.role,
  role_v2 = excluded.role_v2,
  is_admin = excluded.is_admin,
  updated_at = excluded.updated_at;

-- 2) Courses
with src as (
  select
    c.id,
    c.title,
    c.description,
    c.hero_image_url,
    c.is_intro,
    c.is_published,
    c.created_by,
    c.created_at,
    regexp_replace(lower(coalesce(c.title, '')), '[^a-z0-9]+', '-', 'g') as slug_candidate
  from public.courses c
)
insert into app.courses (id, slug, title, description, cover_url, is_free_intro, price_cents, is_published, created_by, created_at, updated_at)
select
  src.id,
  case
    when coalesce(src.slug_candidate, '') <> '' then
      src.slug_candidate || '-' || substring(src.id::text, 1, 6)
    else 'kurs-' || substring(src.id::text, 1, 8)
  end,
  coalesce(nullif(src.title, ''), 'Namnlös kurs'),
  src.description,
  src.hero_image_url,
  src.is_intro,
  0,
  src.is_published,
  src.created_by,
  coalesce(src.created_at, now()),
  now()
from src
on conflict (id) do update
set
  slug = excluded.slug,
  title = excluded.title,
  description = excluded.description,
  cover_url = excluded.cover_url,
  is_free_intro = excluded.is_free_intro,
  is_published = excluded.is_published,
  updated_at = excluded.updated_at;

-- 3) Modules & Lessons
create temporary table tmp_ranked_modules as
select
  cm.id,
  cm.course_id,
  cm.title,
  cm.body,
  cm.media_url,
  cm.type,
  cm.created_at,
  coalesce(cm.position, row_number() over (partition by cm.course_id order by cm.position nulls last, cm.created_at) - 1) as pos
from public.course_modules cm;

insert into app.modules (id, course_id, title, position, created_at)
select
  rm.id,
  rm.course_id,
  coalesce(nullif(rm.title, ''), 'Modul'),
  rm.pos,
  coalesce(rm.created_at, now())
from tmp_ranked_modules rm
on conflict (id) do update
set
  title = excluded.title,
  position = excluded.position;

with lesson_insert as (
  insert into app.lessons (module_id, title, content_markdown, is_intro, position, created_at)
  select
    rm.id,
    coalesce(nullif(rm.title, ''), 'Lektion'),
    case when rm.type = 'text' then rm.body else null end,
    (rm.pos = 0),
    0,
    coalesce(rm.created_at, now())
  from tmp_ranked_modules rm
  where not exists (
    select 1 from app.lessons l where l.module_id = rm.id and l.position = 0
  )
  returning id, module_id
)
insert into app.lesson_media (lesson_id, kind, storage_path, position, created_at)
select
  li.id,
  rm.type,
  coalesce(rm.media_url, rm.body),
  0,
  coalesce(rm.created_at, now())
from lesson_insert li
join tmp_ranked_modules rm on rm.id = li.module_id
where rm.type in ('video', 'audio', 'image')
  and coalesce(rm.media_url, '') <> ''
on conflict (lesson_id, position) do update
set
  kind = excluded.kind,
  storage_path = excluded.storage_path;

drop table if exists tmp_ranked_modules;

-- 4) Teacher directory seed from permissions
insert into app.teacher_directory (user_id, display_name, specialties, price_cents, avatar_url, is_accepting, updated_at)
select
  tp.profile_id,
  coalesce(nullif(p.full_name, ''), nullif(p.username, ''), 'Lärare'),
  case when nullif(p.subjects, '') is not null then string_to_array(p.subjects, ',') else null end,
  0,
  p.avatar_url,
  true,
  now()
from public.teacher_permissions_compat tp
join public.profiles p on p.id = tp.profile_id
where tp.can_edit_courses = true
on conflict (user_id) do update
set
  display_name = excluded.display_name,
  specialties = excluded.specialties,
  avatar_url = excluded.avatar_url,
  is_accepting = excluded.is_accepting,
  updated_at = excluded.updated_at;

-- 5) Services
insert into app.services (id, provider_user_id, title, description, price_cents, duration_min, requires_cert, active, created_at)
select
  s.id,
  s.owner_id,
  s.title,
  s.description,
  coalesce(s.price_cents, 0),
  60,
  false,
  true,
  coalesce(s.created_at, now())
from public.services s
on conflict (id) do update
set
  title = excluded.title,
  description = excluded.description,
  price_cents = excluded.price_cents,
  duration_min = excluded.duration_min,
  active = excluded.active;

commit;
