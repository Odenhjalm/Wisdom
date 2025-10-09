-- 001_app_schema.sql
-- 001_app_schema.sql
-- Baseline schema for the Wisdom by SoulWisdom backend.
-- Idempotent so it can be executed multiple times safely.

begin;

-- Core extensions that power UUID helpers and cryptographic hashing.
create extension if not exists pgcrypto;
create extension if not exists "uuid-ossp";

-- Schemas -------------------------------------------------------------------
create schema if not exists auth;
create schema if not exists app;

-- ---------------------------------------------------------------------------
-- Enumerated types (checked before creation to avoid duplicate errors)
-- ---------------------------------------------------------------------------
do $$
begin
  if not exists (
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where t.typname = 'profile_role'
      and n.nspname = 'app'
  ) then
    create type app.profile_role as enum ('student', 'teacher', 'admin');
  end if;
end$$;

do $$
begin
  if not exists (
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where t.typname = 'user_role'
      and n.nspname = 'app'
  ) then
    create type app.user_role as enum ('user', 'professional', 'teacher');
  end if;
end$$;

do $$
begin
  if not exists (
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where t.typname = 'order_status'
      and n.nspname = 'app'
  ) then
    create type app.order_status as enum (
      'pending',
      'requires_action',
      'processing',
      'paid',
      'canceled',
      'failed',
      'refunded'
    );
  end if;
end$$;

do $$
begin
  if not exists (
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where t.typname = 'payment_status'
      and n.nspname = 'app'
  ) then
    create type app.payment_status as enum (
      'pending',
      'processing',
      'paid',
      'failed',
      'refunded'
    );
  end if;
end$$;

do $$
begin
  if not exists (
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where t.typname = 'enrollment_source'
      and n.nspname = 'app'
  ) then
    create type app.enrollment_source as enum (
      'free_intro',
      'purchase',
      'membership',
      'grant'
    );
  end if;
end$$;

do $$
begin
  if not exists (
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where t.typname = 'service_status'
      and n.nspname = 'app'
  ) then
    create type app.service_status as enum (
      'draft',
      'active',
      'paused',
      'archived'
    );
  end if;
end$$;

do $$
begin
  if not exists (
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where t.typname = 'seminar_status'
      and n.nspname = 'app'
  ) then
    create type app.seminar_status as enum (
      'draft',
      'scheduled',
      'live',
      'ended',
      'canceled'
    );
  end if;
end$$;

do $$
begin
  if not exists (
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where t.typname = 'activity_kind'
      and n.nspname = 'app'
  ) then
    create type app.activity_kind as enum (
      'profile_updated',
      'course_published',
      'lesson_published',
      'service_created',
      'order_paid',
      'seminar_scheduled'
    );
  end if;
end$$;

do $$
begin
  if not exists (
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where t.typname = 'review_visibility'
      and n.nspname = 'app'
  ) then
    create type app.review_visibility as enum ('public', 'private');
  end if;
end$$;

-- ---------------------------------------------------------------------------
-- auth.users — minimal local auth table compatible with FastAPI backend.
-- ---------------------------------------------------------------------------
create table if not exists auth.users (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  encrypted_password text not null,
  full_name text,
  is_verified boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_auth_users_email_lower on auth.users (lower(email));

-- ---------------------------------------------------------------------------
-- Utility function for keeping updated_at in sync.
-- ---------------------------------------------------------------------------
create or replace function app.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- Profiles & People
-- ---------------------------------------------------------------------------
create table if not exists app.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text not null unique,
  display_name text,
  role app.profile_role not null default 'student',
  role_v2 app.user_role not null default 'user',
  bio text,
  photo_url text,
  is_admin boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
-- RLS placeholder: enable row level security and add self-access + admin policies.

-- ---------------------------------------------------------------------------
-- Courses, modules, lessons, media
-- ---------------------------------------------------------------------------
create table if not exists app.courses (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  description text,
  cover_url text,
  video_url text,
  branch text,
  is_free_intro boolean not null default false,
  price_cents integer not null default 0,
  currency text not null default 'sek',
  is_published boolean not null default false,
  created_by uuid references app.profiles(user_id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_courses_created_by on app.courses(created_by);

create table if not exists app.modules (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references app.courses(id) on delete cascade,
  title text not null,
  summary text,
  position integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(course_id, position)
);
create index if not exists idx_modules_course on app.modules(course_id);

create table if not exists app.lessons (
  id uuid primary key default gen_random_uuid(),
  module_id uuid not null references app.modules(id) on delete cascade,
  title text not null,
  content_markdown text,
  video_url text,
  duration_seconds integer,
  is_intro boolean not null default false,
  position integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(module_id, position)
);
create index if not exists idx_lessons_module on app.lessons(module_id);

create table if not exists app.media_objects (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references app.profiles(user_id) on delete set null,
  storage_path text not null,
  storage_bucket text not null default 'lesson-media',
  content_type text,
  byte_size bigint not null default 0,
  checksum text,
  original_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(storage_path, storage_bucket)
);
create index if not exists idx_media_owner on app.media_objects(owner_id);

create table if not exists app.lesson_media (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid not null references app.lessons(id) on delete cascade,
  kind text not null check (kind in ('video','audio','image','pdf','other')),
  media_id uuid references app.media_objects(id) on delete set null,
  storage_path text,
  storage_bucket text not null default 'lesson-media',
  duration_seconds integer,
  position integer not null default 0,
  created_at timestamptz not null default now(),
  unique(lesson_id, position),
  constraint lesson_media_path_or_object check (
    media_id is not null or storage_path is not null
  )
);
create index if not exists idx_lesson_media_lesson on app.lesson_media(lesson_id);
create index if not exists idx_lesson_media_media on app.lesson_media(media_id);

alter table app.profiles
  add column if not exists avatar_media_id uuid references app.media_objects(id);

-- ---------------------------------------------------------------------------
-- Enrollments & progress
-- ---------------------------------------------------------------------------
create table if not exists app.enrollments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references app.profiles(user_id) on delete cascade,
  course_id uuid not null references app.courses(id) on delete cascade,
  status text not null default 'active',
  source app.enrollment_source not null default 'purchase',
  created_at timestamptz not null default now(),
  unique(user_id, course_id)
);
create index if not exists idx_enrollments_user on app.enrollments(user_id);
create index if not exists idx_enrollments_course on app.enrollments(course_id);

-- ---------------------------------------------------------------------------
-- Services marketplace
-- ---------------------------------------------------------------------------
create table if not exists app.services (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references app.profiles(user_id) on delete cascade,
  title text not null,
  description text,
  status app.service_status not null default 'draft',
  price_cents integer not null default 0,
  currency text not null default 'sek',
  duration_min integer,
  requires_certification boolean not null default false,
  certified_area text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_services_provider on app.services(provider_id);
create index if not exists idx_services_status on app.services(status);

-- ---------------------------------------------------------------------------
-- Orders & payments (Stripe first)
-- ---------------------------------------------------------------------------
create table if not exists app.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references app.profiles(user_id) on delete cascade,
  course_id uuid references app.courses(id) on delete set null,
  service_id uuid references app.services(id) on delete set null,
  amount_cents integer not null,
  currency text not null default 'sek',
  status app.order_status not null default 'pending',
  stripe_checkout_id text,
  stripe_payment_intent text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_orders_user on app.orders(user_id);
create index if not exists idx_orders_status on app.orders(status);
create index if not exists idx_orders_service on app.orders(service_id);
create index if not exists idx_orders_course on app.orders(course_id);

create or replace view app.service_orders as
select *
from app.orders
where service_id is not null;

create table if not exists app.payments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references app.orders(id) on delete cascade,
  provider text not null,
  provider_reference text,
  status app.payment_status not null default 'pending',
  amount_cents integer not null,
  currency text not null default 'sek',
  metadata jsonb not null default '{}'::jsonb,
  raw_payload jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_payments_order on app.payments(order_id);
create index if not exists idx_payments_status on app.payments(status);

create table if not exists app.service_reviews (
  id uuid primary key default gen_random_uuid(),
  service_id uuid not null references app.services(id) on delete cascade,
  order_id uuid references app.orders(id) on delete set null,
  reviewer_id uuid references app.profiles(user_id) on delete set null,
  rating integer not null check (rating between 1 and 5),
  comment text,
  visibility app.review_visibility not null default 'public',
  created_at timestamptz not null default now()
);
create index if not exists idx_service_reviews_service on app.service_reviews(service_id);
create index if not exists idx_service_reviews_reviewer on app.service_reviews(reviewer_id);

create table if not exists app.teacher_payout_methods (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references app.profiles(user_id) on delete cascade,
  provider text not null,
  reference text not null,
  details jsonb not null default '{}'::jsonb,
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(teacher_id, provider, reference)
);
create index if not exists idx_payout_methods_teacher on app.teacher_payout_methods(teacher_id);

-- ---------------------------------------------------------------------------
-- Seminars / SFU foundation (LiveKit)
-- ---------------------------------------------------------------------------
create table if not exists app.seminars (
  id uuid primary key default gen_random_uuid(),
  host_id uuid not null references app.profiles(user_id) on delete cascade,
  title text not null,
  description text,
  status app.seminar_status not null default 'draft',
  scheduled_at timestamptz,
  duration_minutes integer,
  livekit_room text,
  livekit_metadata jsonb,
  recording_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_seminars_host on app.seminars(host_id);
create index if not exists idx_seminars_status on app.seminars(status);
create index if not exists idx_seminars_scheduled_at on app.seminars(scheduled_at);

create table if not exists app.seminar_attendees (
  seminar_id uuid not null references app.seminars(id) on delete cascade,
  user_id uuid not null references app.profiles(user_id) on delete cascade,
  role text not null default 'participant',
  joined_at timestamptz,
  created_at timestamptz not null default now(),
  primary key (seminar_id, user_id)
);

-- ---------------------------------------------------------------------------
-- Activities feed
-- ---------------------------------------------------------------------------
create table if not exists app.activities (
  id uuid primary key default gen_random_uuid(),
  activity_type app.activity_kind not null,
  actor_id uuid references app.profiles(user_id) on delete set null,
  subject_table text not null,
  subject_id uuid,
  summary text,
  metadata jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
create index if not exists idx_activities_type on app.activities(activity_type);
create index if not exists idx_activities_subject on app.activities(subject_table, subject_id);
create index if not exists idx_activities_occurred on app.activities(occurred_at desc);

create or replace view app.activities_feed as
select
  a.id,
  a.activity_type,
  a.actor_id,
  a.subject_table,
  a.subject_id,
  a.summary,
  a.metadata,
  a.occurred_at
from app.activities a;
-- RLS placeholder: convert to security barrier view with RLS-backed source tables.

-- ---------------------------------------------------------------------------
-- Authentication helpers (refresh tokens & audit)
-- ---------------------------------------------------------------------------
create table if not exists app.refresh_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references app.profiles(user_id) on delete cascade,
  jti uuid not null unique,
  token_hash text not null,
  issued_at timestamptz not null default now(),
  expires_at timestamptz not null,
  rotated_at timestamptz,
  revoked_at timestamptz,
  last_used_at timestamptz
);
create index if not exists idx_refresh_tokens_user on app.refresh_tokens(user_id);

create table if not exists app.auth_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references app.profiles(user_id) on delete cascade,
  email text,
  event text not null,
  ip_address inet,
  user_agent text,
  metadata jsonb,
  created_at timestamptz not null default now()
);
create index if not exists idx_auth_events_user on app.auth_events(user_id);
create index if not exists idx_auth_events_created_at on app.auth_events(created_at desc);

-- ---------------------------------------------------------------------------
-- Misc legacy-support tables referenced by the existing backend
-- ---------------------------------------------------------------------------
create table if not exists app.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references app.profiles(user_id) on delete cascade,
  content text not null,
  media_paths jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);
create index if not exists idx_posts_author on app.posts(author_id);

create table if not exists app.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references app.profiles(user_id) on delete cascade,
  payload jsonb not null default '{}'::jsonb,
  read_at timestamptz,
  created_at timestamptz not null default now()
);
create index if not exists idx_notifications_user on app.notifications(user_id);
create index if not exists idx_notifications_read on app.notifications(user_id, read_at);

create table if not exists app.follows (
  follower_id uuid not null references app.profiles(user_id) on delete cascade,
  followee_id uuid not null references app.profiles(user_id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_id, followee_id)
);

create table if not exists app.app_config (
  id integer primary key default 1,
  free_course_limit integer not null default 5,
  platform_fee_pct numeric not null default 10
);

insert into app.app_config(id)
select 1
where not exists (select 1 from app.app_config where id = 1);

create table if not exists app.messages (
  id uuid primary key default gen_random_uuid(),
  channel text,
  sender_id uuid references app.profiles(user_id) on delete set null,
  recipient_id uuid references app.profiles(user_id) on delete set null,
  content text,
  created_at timestamptz not null default now()
);
create index if not exists idx_messages_recipient on app.messages(recipient_id);
create index if not exists idx_messages_channel on app.messages(channel);

create table if not exists app.stripe_customers (
  user_id uuid primary key references app.profiles(user_id) on delete cascade,
  customer_id text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists app.teacher_permissions (
  profile_id uuid primary key references app.profiles(user_id) on delete cascade,
  can_edit_courses boolean not null default false,
  can_publish boolean not null default false,
  granted_by uuid references app.profiles(user_id),
  granted_at timestamptz not null default now()
);

create table if not exists app.teacher_directory (
  user_id uuid primary key references app.profiles(user_id) on delete cascade,
  headline text,
  specialties text[],
  rating numeric(3,2),
  created_at timestamptz not null default now()
);

create table if not exists app.teacher_approvals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references app.profiles(user_id) on delete cascade,
  reviewer_id uuid references app.profiles(user_id),
  status text not null default 'pending',
  notes text,
  approved_by uuid references app.profiles(user_id),
  approved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id)
);
create index if not exists idx_teacher_approvals_user on app.teacher_approvals(user_id);

create table if not exists app.certificates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references app.profiles(user_id) on delete cascade,
  course_id uuid references app.courses(id) on delete set null,
  title text,
  status text not null default 'pending',
  notes text,
  evidence_url text,
  issued_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_certificates_user on app.certificates(user_id);

create table if not exists app.course_quizzes (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references app.courses(id) on delete cascade,
  title text,
  pass_score integer not null default 80,
  created_by uuid references app.profiles(user_id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists app.quiz_questions (
  id uuid primary key default gen_random_uuid(),
  course_id uuid references app.courses(id) on delete cascade,
  quiz_id uuid references app.course_quizzes(id) on delete cascade,
  position integer not null default 0,
  kind text not null default 'single',
  prompt text not null,
  options jsonb not null default '{}'::jsonb,
  correct text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_quiz_questions_course on app.quiz_questions(course_id);
create index if not exists idx_quiz_questions_quiz on app.quiz_questions(quiz_id);

create table if not exists app.meditations (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  teacher_id uuid references app.profiles(user_id) on delete cascade,
  media_id uuid references app.media_objects(id) on delete set null,
  audio_path text,
  duration_seconds integer,
  is_public boolean not null default false,
  created_by uuid references app.profiles(user_id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists app.tarot_requests (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references app.profiles(user_id) on delete cascade,
  question text not null,
  status text not null default 'open',
  created_at timestamptz not null default now()
);

create table if not exists app.reviews (
  id uuid primary key default gen_random_uuid(),
  course_id uuid references app.courses(id) on delete cascade,
  service_id uuid references app.services(id) on delete cascade,
  reviewer_id uuid not null references app.profiles(user_id) on delete cascade,
  rating integer not null check (rating between 1 and 5),
  comment text,
  visibility app.review_visibility not null default 'public',
  created_at timestamptz not null default now()
);
create index if not exists idx_reviews_course on app.reviews(course_id);
create index if not exists idx_reviews_service on app.reviews(service_id);
create index if not exists idx_reviews_reviewer on app.reviews(reviewer_id);

-- ---------------------------------------------------------------------------
-- Touch triggers (ensure updated_at auto-refreshes)
-- ---------------------------------------------------------------------------
drop trigger if exists trg_courses_touch on app.courses;
create trigger trg_courses_touch
before update on app.courses
for each row
execute function app.set_updated_at();

drop trigger if exists trg_modules_touch on app.modules;
create trigger trg_modules_touch
before update on app.modules
for each row
execute function app.set_updated_at();

drop trigger if exists trg_lessons_touch on app.lessons;
create trigger trg_lessons_touch
before update on app.lessons
for each row
execute function app.set_updated_at();

drop trigger if exists trg_services_touch on app.services;
create trigger trg_services_touch
before update on app.services
for each row
execute function app.set_updated_at();

drop trigger if exists trg_orders_touch on app.orders;
create trigger trg_orders_touch
before update on app.orders
for each row
execute function app.set_updated_at();

drop trigger if exists trg_payments_touch on app.payments;
create trigger trg_payments_touch
before update on app.payments
for each row
execute function app.set_updated_at();

drop trigger if exists trg_seminars_touch on app.seminars;
create trigger trg_seminars_touch
before update on app.seminars
for each row
execute function app.set_updated_at();

drop trigger if exists trg_teacher_payout_methods_touch on app.teacher_payout_methods;
create trigger trg_teacher_payout_methods_touch
before update on app.teacher_payout_methods
for each row
execute function app.set_updated_at();

commit;

-- 002_seed_dev.sql
-- 002_seed_dev.sql
-- Deterministic seed data to make local development convenient.
-- Idempotent: all inserts use stable UUIDs and ON CONFLICT guards.

begin;

-- ---------------------------------------------------------------------------
-- Seed users (teacher + student)
-- ---------------------------------------------------------------------------
insert into auth.users (id, email, encrypted_password, full_name, is_verified, created_at, updated_at)
values
  (
    '11111111-1111-4111-8111-111111111111',
    'teacher@wisdom.local',
    crypt('password123', gen_salt('bf')),
    'Teacher Wisdom',
    true,
    now(),
    now()
  ),
  (
    '22222222-2222-4222-8222-222222222222',
    'student@wisdom.local',
    crypt('password123', gen_salt('bf')),
    'Student Soul',
    true,
    now(),
    now()
  )
on conflict (id) do update
set
  email = excluded.email,
  encrypted_password = excluded.encrypted_password,
  full_name = excluded.full_name,
  is_verified = excluded.is_verified,
  updated_at = now();

-- ---------------------------------------------------------------------------
-- Profiles
-- ---------------------------------------------------------------------------
insert into app.profiles (user_id, email, display_name, role, role_v2, bio, photo_url, is_admin)
values
  (
    '11111111-1111-4111-8111-111111111111',
    'teacher@wisdom.local',
    'Coach Aurora',
    'teacher',
    'teacher',
    'Certified mindfulness coach focusing on everyday wisdom.',
    null,
    true
  ),
  (
    '22222222-2222-4222-8222-222222222222',
    'student@wisdom.local',
    'Seeker Nova',
    'student',
    'user',
    'Curious student exploring SoulWisdom practices.',
    null,
    false
  )
on conflict (user_id) do update
set
  display_name = excluded.display_name,
  role = excluded.role,
  role_v2 = excluded.role_v2,
  bio = excluded.bio,
  photo_url = excluded.photo_url,
  is_admin = excluded.is_admin,
  updated_at = now();

-- ---------------------------------------------------------------------------
-- Courses, modules, lessons
-- ---------------------------------------------------------------------------
insert into app.courses (id, slug, title, description, cover_url, video_url, branch, is_free_intro, price_cents, currency, is_published, created_by)
values (
  '33333333-3333-4333-8333-333333333333',
  'foundations-of-soulwisdom',
  'Foundations of SoulWisdom',
  'Kickstart your practice with core breathing and journaling rituals.',
  'https://assets.wisdom.local/course-cover.png',
  null,
  'mindfulness',
  true,
  0,
  'sek',
  true,
  '11111111-1111-4111-8111-111111111111'
)
on conflict (id) do update
set
  slug = excluded.slug,
  title = excluded.title,
  description = excluded.description,
  cover_url = excluded.cover_url,
  branch = excluded.branch,
  is_free_intro = excluded.is_free_intro,
  price_cents = excluded.price_cents,
  currency = excluded.currency,
  is_published = excluded.is_published,
  created_by = excluded.created_by,
  updated_at = now();

insert into app.modules (id, course_id, title, summary, position)
values (
  '44444444-4444-4444-8444-444444444444',
  '33333333-3333-4333-8333-333333333333',
  'Grounding Practices',
  'Breathwork and morning check-ins to reset your nervous system.',
  0
)
on conflict (id) do update
set
  course_id = excluded.course_id,
  title = excluded.title,
  summary = excluded.summary,
  position = excluded.position,
  updated_at = now();

insert into app.lessons (id, module_id, title, content_markdown, video_url, duration_seconds, is_intro, position)
values (
  '55555555-5555-4555-8555-555555555555',
  '44444444-4444-4444-8444-444444444444',
  'Five-minute Centering Breath',
  '# Centering Breath\n\nFind a comfortable seat and follow the guided rhythm.',
  null,
  300,
  true,
  0
)
on conflict (id) do update
set
  module_id = excluded.module_id,
  title = excluded.title,
  content_markdown = excluded.content_markdown,
  video_url = excluded.video_url,
  duration_seconds = excluded.duration_seconds,
  is_intro = excluded.is_intro,
  position = excluded.position,
  updated_at = now();

-- ---------------------------------------------------------------------------
-- Services marketplace
-- ---------------------------------------------------------------------------
insert into app.services (id, provider_id, title, description, status, price_cents, currency, duration_min, requires_certification, certified_area)
values (
  '66666666-6666-4666-8666-666666666666',
  '11111111-1111-4111-8111-111111111111',
  '1:1 Integration Coaching',
  'Personalized session to integrate insights from your daily practice.',
  'active',
  12000,
  'sek',
  60,
  false,
  null
)
on conflict (id) do update
set
  provider_id = excluded.provider_id,
  title = excluded.title,
  description = excluded.description,
  status = excluded.status,
  price_cents = excluded.price_cents,
  currency = excluded.currency,
  duration_min = excluded.duration_min,
  requires_certification = excluded.requires_certification,
  certified_area = excluded.certified_area,
  updated_at = now();

-- ---------------------------------------------------------------------------
-- Orders and payments (Stripe simulation)
-- ---------------------------------------------------------------------------
insert into app.orders (id, user_id, service_id, amount_cents, currency, status, stripe_checkout_id, stripe_payment_intent, metadata, created_at, updated_at)
values (
  '77777777-7777-4777-8777-777777777777',
  '22222222-2222-4222-8222-222222222222',
  '66666666-6666-4666-8666-666666666666',
  12000,
  'sek',
  'paid',
  'cs_test_seed',
  'pi_test_seed',
  jsonb_build_object('seed', true),
  now(),
  now()
)
on conflict (id) do update
set
  user_id = excluded.user_id,
  service_id = excluded.service_id,
  amount_cents = excluded.amount_cents,
  currency = excluded.currency,
  status = excluded.status,
  stripe_checkout_id = excluded.stripe_checkout_id,
  stripe_payment_intent = excluded.stripe_payment_intent,
  metadata = excluded.metadata,
  updated_at = now();

insert into app.payments (id, order_id, provider, provider_reference, status, amount_cents, currency, metadata, raw_payload)
values (
  '88888888-8888-4888-8888-888888888888',
  '77777777-7777-4777-8777-777777777777',
  'stripe',
  'evt_test_seed',
  'paid',
  12000,
  'sek',
  jsonb_build_object('integration_test', true),
  jsonb_build_object('stripe_event', 'checkout.session.completed')
)
on conflict (id) do update
set
  order_id = excluded.order_id,
  provider = excluded.provider,
  provider_reference = excluded.provider_reference,
  status = excluded.status,
  amount_cents = excluded.amount_cents,
  currency = excluded.currency,
  metadata = excluded.metadata,
  raw_payload = excluded.raw_payload,
  updated_at = now();

insert into app.service_reviews (id, service_id, order_id, reviewer_id, rating, comment, visibility, created_at)
values (
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '66666666-6666-4666-8666-666666666666',
  '77777777-7777-4777-8777-777777777777',
  '22222222-2222-4222-8222-222222222222',
  5,
  'A grounding experience that left me energized and clear.',
  'public',
  now()
)
on conflict (id) do update
set
  service_id = excluded.service_id,
  order_id = excluded.order_id,
  reviewer_id = excluded.reviewer_id,
  rating = excluded.rating,
  comment = excluded.comment,
  visibility = excluded.visibility,
  created_at = excluded.created_at;

-- ---------------------------------------------------------------------------
-- Enrollment & activity feed
-- ---------------------------------------------------------------------------
insert into app.enrollments (id, user_id, course_id, status, source, created_at)
values (
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '22222222-2222-4222-8222-222222222222',
  '33333333-3333-4333-8333-333333333333',
  'active',
  'free_intro',
  now()
)
on conflict (id) do update
set
  user_id = excluded.user_id,
  course_id = excluded.course_id,
  status = excluded.status,
  source = excluded.source,
  created_at = excluded.created_at;

insert into app.activities (id, activity_type, actor_id, subject_table, subject_id, summary, metadata, occurred_at, created_at)
values (
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  'order_paid',
  '22222222-2222-4222-8222-222222222222',
  'orders',
  '77777777-7777-4777-8777-777777777777',
  'Seeker Nova booked "1:1 Integration Coaching".',
  jsonb_build_object('seed', true),
  now(),
  now()
)
on conflict (id) do update
set
  activity_type = excluded.activity_type,
  actor_id = excluded.actor_id,
  subject_table = excluded.subject_table,
  subject_id = excluded.subject_id,
  summary = excluded.summary,
  metadata = excluded.metadata,
  occurred_at = excluded.occurred_at,
  created_at = excluded.created_at;

-- ---------------------------------------------------------------------------
-- Seminars & attendees (LiveKit scaffolding)
-- ---------------------------------------------------------------------------
insert into app.seminars (id, host_id, title, description, status, scheduled_at, duration_minutes, livekit_room, livekit_metadata)
values (
  '99999999-9999-4999-8999-999999999999',
  '11111111-1111-4111-8111-111111111111',
  'Morning Presence Circle',
  'Live group practice to sync breath, intention and gratitude.',
  'scheduled',
  now() + interval '3 days',
  45,
  'wisdom-morning-presence',
  jsonb_build_object('seed', true)
)
on conflict (id) do update
set
  host_id = excluded.host_id,
  title = excluded.title,
  description = excluded.description,
  status = excluded.status,
  scheduled_at = excluded.scheduled_at,
  duration_minutes = excluded.duration_minutes,
  livekit_room = excluded.livekit_room,
  livekit_metadata = excluded.livekit_metadata,
  updated_at = now();

insert into app.seminar_attendees (seminar_id, user_id, role, joined_at, created_at)
values (
  '99999999-9999-4999-8999-999999999999',
  '22222222-2222-4222-8222-222222222222',
  'participant',
  null,
  now()
)
on conflict (seminar_id, user_id) do update
set
  role = excluded.role,
  joined_at = excluded.joined_at,
  created_at = excluded.created_at;

-- ---------------------------------------------------------------------------
-- Teacher payout method
-- ---------------------------------------------------------------------------
insert into app.teacher_payout_methods (id, teacher_id, provider, reference, details, is_default)
values (
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '11111111-1111-4111-8111-111111111111',
  'stripe_connect',
  'acct_seed_teacher',
  jsonb_build_object('account_id', 'acct_seed_teacher'),
  true
)
on conflict (id) do update
set
  teacher_id = excluded.teacher_id,
  provider = excluded.provider,
  reference = excluded.reference,
  details = excluded.details,
  is_default = excluded.is_default,
  updated_at = now();

commit;

-- 003_teacher_approvals_patch.sql
-- Ensure teacher_approvals has approval metadata columns expected by application code.
-- Idempotent migration.

begin;

alter table app.teacher_approvals
  add column if not exists approved_by uuid references app.profiles(user_id),
  add column if not exists approved_at timestamptz;

commit;

-- 004_course_quiz_patch.sql
-- Align course_quizzes schema with application expectations.
-- Idempotent patch.

begin;

alter table app.course_quizzes
  add column if not exists title text,
  add column if not exists pass_score integer default 80,
  add column if not exists created_by uuid references app.profiles(user_id);

commit;

-- 005_quiz_questions_patch.sql
-- Align quiz_questions schema with latest application expectations.
-- Idempotent patch.

begin;

alter table app.quiz_questions
  add column if not exists quiz_id uuid references app.course_quizzes(id) on delete cascade,
  add column if not exists position integer default 0,
  add column if not exists kind text default 'single',
  add column if not exists options jsonb default '{}'::jsonb,
  add column if not exists correct text,
  add column if not exists updated_at timestamptz not null default now();

-- Backfill quiz_id for legacy rows using course_id when available
update app.quiz_questions qq
set quiz_id = cq.id
from app.course_quizzes cq
where qq.quiz_id is null and cq.course_id = qq.course_id;

alter table app.quiz_questions
  drop column if exists correct_answer;

commit;

-- 006_quiz_questions_nullable.sql
-- Allow quiz_questions.course_id to be nullable (quiz-scoped data stored via quiz_id).

begin;

alter table app.quiz_questions
  alter column course_id drop not null;

commit;

-- 007_app_config.sql
-- Ensure app.app_config exists with default row.

begin;

create table if not exists app.app_config (
  id integer primary key default 1,
  free_course_limit integer not null default 5,
  platform_fee_pct numeric not null default 10
);

insert into app.app_config(id)
select 1
where not exists (select 1 from app.app_config where id = 1);

commit;

-- 008_posts_patch.sql
-- Align app.posts schema with JSON-based content storage.

begin;

alter table app.posts
  add column if not exists content text,
  add column if not exists media_paths jsonb not null default '[]'::jsonb;

update app.posts
set content = coalesce(content, body)
where content is null;

alter table app.posts
  drop column if exists title,
  drop column if exists body,
  drop column if exists visibility,
  drop column if exists updated_at;

commit;

-- 009_follows.sql
begin;

create table if not exists app.follows (
  follower_id uuid not null references app.profiles(user_id) on delete cascade,
  followee_id uuid not null references app.profiles(user_id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_id, followee_id)
);

commit;

-- 010_services_duration.sql
begin;

alter table app.services
  add column if not exists duration_min integer;

update app.services
set duration_min = duration_minutes
where duration_min is null;

alter table app.services
  drop column if exists duration_minutes;

commit;

-- 011_services_active.sql
begin;

alter table app.services
  add column if not exists active boolean not null default true;

commit;

-- 012_meditations_patch.sql
begin;

alter table app.meditations
  add column if not exists teacher_id uuid references app.profiles(user_id) on delete cascade,
  add column if not exists audio_path text,
  add column if not exists is_public boolean not null default false;

update app.meditations
set teacher_id = coalesce(teacher_id, created_by);

commit;

-- 013_messages_patch.sql
begin;

alter table app.messages
  add column if not exists channel text,
  add column if not exists content text;

update app.messages
set content = coalesce(content, body);

alter table app.messages
  drop column if exists body;

create index if not exists idx_messages_channel on app.messages(channel);

commit;

-- 014_teacher_approvals_unique.sql
begin;

alter table app.teacher_approvals
  add constraint teacher_approvals_user_key unique (user_id);

commit;

-- 015_certificates_patch.sql
begin;

alter table app.certificates
  add column if not exists title text,
  add column if not exists status text not null default 'pending',
  add column if not exists notes text,
  add column if not exists evidence_url text,
  add column if not exists metadata jsonb not null default '{}'::jsonb,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

commit;
