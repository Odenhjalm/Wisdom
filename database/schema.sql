-- =====================================================================
-- ProjectAPP • Supabase init (schema, tabeller, RLS, RPC, seed)
-- PostgreSQL 15 (Supabase). Idempotent.
-- =====================================================================

begin;

-- ---------- 0) Grundläggande schema, typer, extensioner ----------
create schema if not exists app;

create extension if not exists "uuid-ossp";
create extension if not exists pgcrypto;

do $$
begin
  if not exists (
    select 1 from pg_type t join pg_namespace n on n.oid=t.typnamespace
    where t.typname='user_role' and n.nspname='app'
  ) then
    create type app.user_role as enum ('user','professional','teacher');
  end if;
end$$;

-- Membership plan & status
do $$
begin
  if not exists (
    select 1 from pg_type t join pg_namespace n on n.oid=t.typnamespace
    where t.typname='membership_plan' and n.nspname='app'
  ) then
    create type app.membership_plan as enum ('none','basic','pro','lifetime');
  end if;
end$$;

do $$
begin
  if not exists (
    select 1 from pg_type t join pg_namespace n on n.oid=t.typnamespace
    where t.typname='membership_status' and n.nspname='app'
  ) then
    create type app.membership_status as enum ('inactive','active','past_due','canceled');
  end if;
end$$;

-- Orders
do $$
begin
  if not exists (
    select 1 from pg_type t join pg_namespace n on n.oid=t.typnamespace
    where t.typname='order_status' and n.nspname='app'
  ) then
    create type app.order_status as enum ('pending','requires_action','paid','canceled','failed','refunded');
  end if;
end$$;

-- Enrollment source
do $$
begin
  if not exists (
    select 1 from pg_type t join pg_namespace n on n.oid=t.typnamespace
    where t.typname='enrollment_source' and n.nspname='app'
  ) then
    create type app.enrollment_source as enum ('free_intro','purchase','membership','grant');
  end if;
end$$;

-- ---------- 1) Kärn-tabeller ----------
create table if not exists app.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text unique,
  display_name text,
  bio text,
  photo_url text,
  role_v2 app.user_role not null default 'user',
  is_admin boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists app.courses (
  id uuid primary key default uuid_generate_v4(),
  slug text unique not null,
  title text not null,
  description text,
  cover_url text,
  is_free_intro boolean not null default false,
  price_cents integer not null default 0,
  is_published boolean not null default false,
  created_by uuid references app.profiles(user_id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists app.modules (
  id uuid primary key default uuid_generate_v4(),
  course_id uuid not null references app.courses(id) on delete cascade,
  title text not null,
  position integer not null default 0,
  created_at timestamptz not null default now(),
  unique(course_id, position)
);
create index if not exists idx_modules_course on app.modules(course_id);

create table if not exists app.lessons (
  id uuid primary key default uuid_generate_v4(),
  module_id uuid not null references app.modules(id) on delete cascade,
  title text not null,
  content_markdown text,
  is_intro boolean not null default false,
  position integer not null default 0,
  created_at timestamptz not null default now(),
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
  updated_at timestamptz not null default now()
);
create index if not exists idx_media_objects_owner on app.media_objects(owner_id);
create unique index if not exists idx_media_objects_path_bucket on app.media_objects(storage_path, storage_bucket);

create table if not exists app.lesson_media (
  id uuid primary key default uuid_generate_v4(),
  lesson_id uuid not null references app.lessons(id) on delete cascade,
  kind text not null check (kind in ('video','audio','image','pdf','other')),
  storage_path text,
  storage_bucket text not null default 'lesson-media',
  media_id uuid references app.media_objects(id),
  duration_seconds integer,
  position integer not null default 0,
  created_at timestamptz not null default now(),
  unique(lesson_id, position)
);
create index if not exists idx_media_lesson on app.lesson_media(lesson_id);
create index if not exists idx_media_media_object on app.lesson_media(media_id);

alter table app.media_objects
  add column if not exists owner_id uuid references app.profiles(user_id) on delete set null,
  add column if not exists storage_bucket text,
  add column if not exists content_type text,
  add column if not exists byte_size bigint,
  add column if not exists checksum text,
  add column if not exists original_name text,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

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
update app.lesson_media set storage_bucket = 'lesson-media' where storage_bucket is null;

do $$
begin
  alter table app.lesson_media
    add constraint lesson_media_path_or_object
      check (media_id is not null or storage_path is not null);
exception
  when duplicate_object then null;
end$$;

alter table app.profiles
  add column if not exists avatar_media_id uuid references app.media_objects(id);
create index if not exists idx_profiles_avatar_media on app.profiles(avatar_media_id);

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
), inserted_media as (
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

create table if not exists app.enrollments (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references app.profiles(user_id) on delete cascade,
  course_id uuid not null references app.courses(id) on delete cascade,
  source app.enrollment_source not null default 'purchase',
  created_at timestamptz not null default now(),
  unique(user_id, course_id)
);
create index if not exists idx_enroll_user on app.enrollments(user_id);
create index if not exists idx_enroll_course on app.enrollments(course_id);

create table if not exists app.memberships (
  user_id uuid primary key references app.profiles(user_id) on delete cascade,
  plan app.membership_plan not null default 'none',
  status app.membership_status not null default 'inactive',
  current_period_end timestamptz,
  updated_at timestamptz not null default now()
);

create table if not exists app.orders (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references app.profiles(user_id) on delete cascade,
  course_id uuid references app.courses(id) on delete set null,
  amount_cents integer not null,
  currency text not null default 'sek',
  status app.order_status not null default 'pending',
  stripe_checkout_id text,
  stripe_payment_intent text,
  metadata jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_orders_user on app.orders(user_id);
create index if not exists idx_orders_status on app.orders(status);

create table if not exists app.stripe_customers (
  user_id uuid primary key references app.profiles(user_id) on delete cascade,
  customer_id text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists app.subscriptions (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references app.profiles(user_id) on delete cascade,
  subscription_id text not null,
  status text not null,
  customer_id text,
  price_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(subscription_id)
);
create index if not exists idx_subscriptions_user on app.subscriptions(user_id);
create index if not exists idx_subscriptions_status on app.subscriptions(status);
create index if not exists idx_subscriptions_customer on app.subscriptions(customer_id);

create table if not exists app.purchases (
  id uuid primary key default uuid_generate_v4(),
  order_id uuid references app.orders(id) on delete set null,
  user_id uuid references app.profiles(user_id) on delete set null,
  buyer_email text not null,
  course_id uuid not null references app.courses(id) on delete cascade,
  stripe_checkout_id text unique,
  stripe_payment_intent text unique,
  status text not null default 'succeeded' check (status in ('succeeded','refunded','failed','pending')),
  amount_cents integer,
  currency text,
  created_at timestamptz not null default now()
);
create index if not exists idx_purchases_user on app.purchases(user_id);
create index if not exists idx_purchases_course on app.purchases(course_id);
create index if not exists idx_purchases_email on app.purchases(buyer_email);
create unique index if not exists idx_purchases_order on app.purchases(order_id) where order_id is not null;

create table if not exists app.guest_claim_tokens (
  token uuid primary key default uuid_generate_v4(),
  buyer_email text not null,
  course_id uuid not null references app.courses(id) on delete cascade,
  purchase_id uuid not null references app.purchases(id) on delete cascade,
  used boolean not null default false,
  expires_at timestamptz not null default (now() + interval '14 days'),
  created_at timestamptz not null default now()
);
create index if not exists idx_guest_claim_email on app.guest_claim_tokens(buyer_email);
create index if not exists idx_guest_claim_purchase on app.guest_claim_tokens(purchase_id);

-- App configuration
create table if not exists app.app_config (
  id integer primary key default 1,
  free_course_limit integer not null default 5,
  platform_fee_pct numeric not null default 10
);

insert into app.app_config(id)
select 1 where not exists (select 1 from app.app_config where id = 1);

create table if not exists app.events (
  id uuid primary key default uuid_generate_v4(),
  created_by uuid references app.profiles(user_id) on delete set null,
  title text not null,
  description text,
  starts_at timestamptz not null,
  ends_at timestamptz,
  location text,
  is_published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists app.services (
  id uuid primary key default uuid_generate_v4(),
  provider_id uuid not null references app.profiles(user_id) on delete cascade,
  title text not null,
  description text,
  price_cents integer not null default 0,
  duration_min integer,
  requires_cert boolean not null default false,
  certified_area text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'app'
      and table_name = 'services'
      and column_name = 'is_active'
  ) then
    execute 'alter table app.services rename column is_active to active';
  end if;
end$$;
alter table if exists app.services
  add column if not exists duration_min integer,
  add column if not exists requires_cert boolean not null default false,
  add column if not exists certified_area text,
  add column if not exists active boolean not null default true;
create index if not exists idx_services_provider on app.services(provider_id);

create table if not exists app.teacher_requests (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references app.profiles(user_id) on delete cascade,
  message text,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  reviewed_by uuid references app.profiles(user_id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id)
);

create table if not exists app.teacher_directory (
  user_id uuid primary key references app.profiles(user_id) on delete cascade,
  headline text,
  specialties text[],
  rating numeric(3,2),
  created_at timestamptz not null default now()
);

create table if not exists app.teacher_permissions (
  profile_id uuid primary key references app.profiles(user_id) on delete cascade,
  can_edit_courses boolean not null default false,
  can_publish boolean not null default false,
  granted_by uuid references app.profiles(user_id),
  granted_at timestamptz not null default now()
);

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
create index if not exists idx_auth_events_created on app.auth_events(created_at desc);

create table if not exists public.user_certifications (
  user_id uuid not null references app.profiles(user_id) on delete cascade,
  area text not null,
  created_at timestamptz not null default now(),
  primary key (user_id, area)
);

create table if not exists app.meditations (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references app.profiles(user_id) on delete cascade,
  title text not null,
  description text,
  audio_path text not null,
  duration_seconds integer,
  is_public boolean not null default true,
  created_at timestamptz not null default now()
);
create index if not exists idx_meditations_teacher on app.meditations(teacher_id);

create table if not exists app.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references app.profiles(user_id) on delete cascade,
  content text not null,
  media_paths jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);
create index if not exists idx_posts_author on app.posts(author_id);
create index if not exists idx_posts_created on app.posts(created_at desc);

create table if not exists app.follows (
  follower_id uuid not null references app.profiles(user_id) on delete cascade,
  followee_id uuid not null references app.profiles(user_id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_id, followee_id)
);
create index if not exists idx_follows_followee on app.follows(followee_id);

create table if not exists app.course_quizzes (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references app.courses(id) on delete cascade,
  title text not null,
  pass_score integer not null default 80,
  created_by uuid references app.profiles(user_id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(course_id)
);

create table if not exists app.quiz_questions (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid not null references app.course_quizzes(id) on delete cascade,
  position integer not null default 0,
  kind text not null default 'single',
  prompt text not null,
  options jsonb not null default '{}'::jsonb,
  correct text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_quiz_questions_quiz on app.quiz_questions(quiz_id, position);

create table if not exists app.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references app.profiles(user_id) on delete cascade,
  kind text not null,
  payload jsonb not null default '{}'::jsonb,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists idx_notifications_user on app.notifications(user_id);
create index if not exists idx_notifications_unread on app.notifications(user_id) where is_read = false;

create table if not exists app.reviews (
  id uuid primary key default gen_random_uuid(),
  service_id uuid not null references app.services(id) on delete cascade,
  reviewer_id uuid not null references app.profiles(user_id) on delete cascade,
  rating integer not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz not null default now()
);
create index if not exists idx_reviews_service on app.reviews(service_id);
create index if not exists idx_reviews_reviewer on app.reviews(reviewer_id);

create table if not exists app.teacher_slots (
  id uuid primary key default uuid_generate_v4(),
  teacher_id uuid not null references app.profiles(user_id) on delete cascade,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  is_booked boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists idx_slots_teacher on app.teacher_slots(teacher_id);

create table if not exists app.bookings (
  id uuid primary key default uuid_generate_v4(),
  slot_id uuid not null references app.teacher_slots(id) on delete cascade,
  user_id uuid not null references app.profiles(user_id) on delete cascade,
  order_id uuid references app.orders(id) on delete set null,
  status text not null default 'pending' check (status in ('pending','confirmed','canceled','completed')),
  created_at timestamptz not null default now(),
  unique(slot_id)
);

create table if not exists app.pro_requirements (
  id serial primary key,
  code text unique not null,
  title text not null,
  created_by uuid not null default gen_random_uuid(),
  updated_at timestamptz not null default now()
);

insert into app.pro_requirements (code, title, created_by)
values
  ('STEP1','Grundutbildning', coalesce((select created_by from app.pro_requirements where code = 'STEP1'),
                                       (select user_id from app.profiles where is_admin = true order by created_at limit 1),
                                       gen_random_uuid())),
  ('STEP2','Fördjupning', coalesce((select created_by from app.pro_requirements where code = 'STEP2'),
                                    (select user_id from app.profiles where is_admin = true order by created_at limit 1),
                                    gen_random_uuid())),
  ('STEP3','Praktik', coalesce((select created_by from app.pro_requirements where code = 'STEP3'),
                                 (select user_id from app.profiles where is_admin = true order by created_at limit 1),
                                 gen_random_uuid()))
on conflict (code) do update set
  title = excluded.title,
  updated_at = now();

create table if not exists app.pro_progress (
  user_id uuid references app.profiles(user_id) on delete cascade,
  requirement_id int references app.pro_requirements(id) on delete cascade,
  completed_at timestamptz default now(),
  primary key (user_id, requirement_id)
);

create table if not exists app.certificates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references app.profiles(user_id) on delete cascade,
  course_id uuid references app.courses(id) on delete set null,
  title text not null,
  status text not null default 'pending',
  evidence_url text,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
alter table if exists app.certificates
  add column if not exists course_id uuid references app.courses(id) on delete set null;
create unique index if not exists idx_certificates_user_course
  on app.certificates(user_id, course_id)
  where course_id is not null;

create table if not exists app.teacher_approvals (
  user_id uuid primary key references app.profiles(user_id) on delete cascade,
  approved_by uuid,
  approved_at timestamptz
);

create table if not exists app.tarot_requests (
  id uuid primary key default uuid_generate_v4(),
  requester_id uuid not null references app.profiles(user_id) on delete cascade,
  reader_id uuid references app.profiles(user_id) on delete set null,
  question text not null,
  status text not null default 'open' check (status in ('open','in_progress','delivered','canceled')),
  order_id uuid references app.orders(id) on delete set null,
  deliverable_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- 2) Hjälpfunktioner ----------
create or replace function app.is_admin()
returns boolean
language plpgsql
stable
security definer
set search_path = app, public
as $$
declare
  v_jwt_role text;
  v_has_publish boolean := false;
  v_old_rowsec text;
begin
  v_jwt_role := auth.jwt() -> 'app_metadata' ->> 'role';
  if v_jwt_role = 'admin' then
    return true;
  end if;

  if to_regclass('app.teacher_permissions') is not null then
    select exists (
      select 1
      from app.teacher_permissions tp
      where tp.profile_id = auth.uid()
        and coalesce(tp.can_publish, false) = true
    ) into v_has_publish;
    if coalesce(v_has_publish, false) then
      return true;
    end if;
  end if;

  if to_regclass('app.profiles') is not null then
    v_old_rowsec := coalesce(current_setting('row_security', true), 'on');
    perform set_config('row_security', 'off', true);
    begin
      if exists (
        select 1
        from app.profiles p
        where p.user_id = auth.uid()
          and coalesce(p.is_admin, false) = true
      ) then
        perform set_config('row_security', v_old_rowsec, true);
        return true;
      end if;
    exception
      when others then
        perform set_config('row_security', v_old_rowsec, true);
        raise;
    end;
    perform set_config('row_security', v_old_rowsec, true);
  end if;

  return false;
end;
$$;

create or replace function app.is_teacher()
returns boolean
language plpgsql
stable
security definer
set search_path = app, public
as $$
declare
  v_jwt_role text;
  v_has_perm boolean := false;
  v_old_rowsec text;
begin
  v_jwt_role := auth.jwt() -> 'app_metadata' ->> 'role';
  if v_jwt_role in ('teacher', 'admin') then
    return true;
  end if;

  if to_regclass('app.teacher_permissions') is not null then
    select exists (
      select 1
      from app.teacher_permissions tp
      where tp.profile_id = auth.uid()
        and (coalesce(tp.can_edit_courses, false) or coalesce(tp.can_publish, false))
    ) into v_has_perm;
    if coalesce(v_has_perm, false) then
      return true;
    end if;
  end if;

  if to_regclass('app.teacher_approvals') is not null then
    v_old_rowsec := coalesce(current_setting('row_security', true), 'on');
    perform set_config('row_security', 'off', true);
    begin
      if exists (
        select 1
        from app.teacher_approvals ta
        where ta.user_id = auth.uid()
      ) then
        perform set_config('row_security', v_old_rowsec, true);
        return true;
      end if;
    exception
      when others then
        perform set_config('row_security', v_old_rowsec, true);
        raise;
    end;
    perform set_config('row_security', v_old_rowsec, true);
  end if;

  if to_regclass('app.certificates') is not null then
    v_old_rowsec := coalesce(current_setting('row_security', true), 'on');
    perform set_config('row_security', 'off', true);
    begin
      if exists (
        select 1
        from app.certificates c
        where c.user_id = auth.uid()
          and lower(c.title) = 'läraransökan'
          and lower(c.status) in ('verified','approved')
      ) then
        perform set_config('row_security', v_old_rowsec, true);
        return true;
      end if;
    exception
      when others then
        perform set_config('row_security', v_old_rowsec, true);
        raise;
    end;
    perform set_config('row_security', v_old_rowsec, true);
  end if;

  if to_regclass('app.profiles') is not null then
    v_old_rowsec := coalesce(current_setting('row_security', true), 'on');
    perform set_config('row_security', 'off', true);
    begin
      if exists (
        select 1
        from app.profiles p
        where p.user_id = auth.uid()
          and (
            p.role_v2 = 'teacher'
            or coalesce(p.is_admin, false) = true
            or (
              p.role_v2 = 'professional'
              and exists (
                select 1 from app.teacher_approvals ta where ta.user_id = p.user_id
              )
            )
          )
      ) then
        perform set_config('row_security', v_old_rowsec, true);
        return true;
      end if;
    exception
      when others then
        perform set_config('row_security', v_old_rowsec, true);
        raise;
    end;
    perform set_config('row_security', v_old_rowsec, true);
  end if;

  return false;
end;
$$;

create or replace function app.current_user_role()
returns app.user_role
language plpgsql
stable
security definer
set search_path = app, public
as $$
declare
  v_claim text;
  v_profile_role app.user_role;
  v_old_rowsec text;
begin
  v_claim := auth.jwt() -> 'app_metadata' ->> 'role';
  if v_claim = 'admin' then
    return 'teacher';
  elsif v_claim = 'teacher' then
    return 'teacher';
  elsif v_claim = 'professional' then
    return 'professional';
  end if;

  if app.is_admin() then
    return 'teacher';
  end if;
  if app.is_teacher() then
    return 'teacher';
  end if;

  if to_regclass('app.profiles') is not null then
    v_old_rowsec := coalesce(current_setting('row_security', true), 'on');
    perform set_config('row_security', 'off', true);
    begin
      select p.role_v2 into v_profile_role
      from app.profiles p
      where p.user_id = auth.uid();
    exception
      when others then
        perform set_config('row_security', v_old_rowsec, true);
        raise;
    end;
    perform set_config('row_security', v_old_rowsec, true);
    if v_profile_role is not null then
      return v_profile_role;
    end if;
  end if;

  return 'user';
end;
$$;

drop function if exists app.current_role();

create or replace function app.current_role()
returns text
language plpgsql
stable
security definer
set search_path = app, public
as $$
declare
  v_claim text;
  v_new_role app.user_role;
begin
  v_claim := auth.jwt() -> 'app_metadata' ->> 'role';
  if v_claim in ('admin', 'teacher', 'user', 'member') then
    return case when v_claim = 'member' then 'member' else v_claim end;
  end if;

  if app.is_admin() then
    return 'admin';
  end if;
  v_new_role := app.current_user_role();

  if v_new_role = 'teacher' then
    return 'teacher';
  elsif v_new_role = 'professional' then
    return 'member';
  else
    return 'user';
  end if;
end;
$$;

create or replace function app.can_access_course(p_user uuid, p_course uuid)
returns boolean
language sql stable
as $$
  with course_flags as (
    select is_free_intro from app.courses where id = p_course
  ),
  enroll as (
    select 1 from app.enrollments where user_id = p_user and course_id = p_course
  ),
  successful_purchases as (
    select 1 from app.purchases where user_id = p_user and course_id = p_course and status = 'succeeded'
  ),
  legacy_orders as (
    select 1 from app.orders where user_id = p_user and course_id = p_course and status = 'paid'
  ),
  memberships as (
    select status from app.memberships where user_id = p_user
  )
  select exists(select 1 from course_flags where is_free_intro)
      or exists(select 1 from enroll)
      or exists(select 1 from successful_purchases)
      or exists(select 1 from legacy_orders)
      or exists(select 1 from memberships where status = 'active');
$$;

create or replace function app.get_config()
returns app.app_config language sql stable as $$
  select * from app.app_config where id=1
$$;

create or replace function app.free_consumed_count(p_user uuid)
returns integer
language sql stable
as $$
  select count(*)::int
  from app.enrollments e
  join app.courses c on c.id = e.course_id
  where e.user_id = p_user
    and e.source = 'free_intro'
    and c.is_free_intro = true;
$$;

-- ---------- 3) RLS ----------
alter table app.profiles enable row level security;
alter table app.courses enable row level security;
alter table app.modules enable row level security;
alter table app.lessons enable row level security;
alter table app.media_objects enable row level security;
alter table app.lesson_media enable row level security;
alter table app.enrollments enable row level security;
alter table app.certificates enable row level security;
alter table app.purchases enable row level security;
alter table app.guest_claim_tokens enable row level security;
alter table app.pro_requirements enable row level security;
alter table app.pro_progress enable row level security;
alter table app.teacher_approvals enable row level security;
alter table app.memberships enable row level security;
alter table app.orders enable row level security;
alter table app.events enable row level security;
alter table app.services enable row level security;
alter table app.teacher_requests enable row level security;
alter table app.teacher_directory enable row level security;
alter table app.teacher_slots enable row level security;
alter table app.bookings enable row level security;
alter table app.tarot_requests enable row level security;
alter table app.meditations enable row level security;
alter table app.posts enable row level security;
alter table app.follows enable row level security;
alter table app.course_quizzes enable row level security;
alter table app.quiz_questions enable row level security;
alter table app.notifications enable row level security;
alter table app.reviews enable row level security;
alter table app.refresh_tokens enable row level security;
alter table app.auth_events enable row level security;

drop policy if exists "profiles_read_own_or_admin" on app.profiles;
create policy "profiles_read_own_or_admin" on app.profiles for select
using (auth.uid() = user_id or app.is_teacher());

drop policy if exists "profiles_update_own" on app.profiles;
create policy "profiles_update_own" on app.profiles for update
using (auth.uid() = user_id);

-- Tillåt admin att uppdatera profiler (för lärargodkännande m.m.)
drop policy if exists "profiles_admin_update" on app.profiles;
create policy "profiles_admin_update" on app.profiles for update
using (app.is_admin()) with check (app.is_admin());

drop policy if exists "profiles_insert_self" on app.profiles;
create policy "profiles_insert_self" on app.profiles for insert
with check (auth.uid() = user_id);

drop policy if exists "courses_public_read" on app.courses;
create policy "courses_public_read" on app.courses for select
using (is_published = true or app.is_teacher());

drop policy if exists "courses_teacher_write" on app.courses;
create policy "courses_teacher_write" on app.courses for all
using (app.is_teacher() and (created_by = auth.uid() or app.is_admin()))
with check (app.is_teacher() and (created_by = auth.uid() or app.is_admin()));

drop policy if exists "modules_read" on app.modules;
create policy "modules_read" on app.modules for select
using (exists(select 1 from app.courses c where c.id=course_id and (c.is_published or app.is_teacher())));

drop policy if exists "modules_teacher_write" on app.modules;
create policy "modules_teacher_write" on app.modules for all
using (
  app.is_teacher() and exists (
    select 1 from app.courses c where c.id = modules.course_id and (c.created_by = auth.uid() or app.is_admin())
  )
)
with check (
  app.is_teacher() and exists (
    select 1 from app.courses c where c.id = modules.course_id and (c.created_by = auth.uid() or app.is_admin())
  )
);

drop policy if exists "lessons_read" on app.lessons;
create policy "lessons_read" on app.lessons for select
using (
  app.is_teacher()
  or exists (
    select 1
    from app.modules m join app.courses c on c.id=m.course_id
    where m.id = lessons.module_id
      and c.is_published = true
      and (lessons.is_intro = true or app.can_access_course(auth.uid(), c.id))
  )
);

drop policy if exists "lessons_teacher_write" on app.lessons;
create policy "lessons_teacher_write" on app.lessons for all
using (
  app.is_teacher() and exists (
    select 1
    from app.modules m
    join app.courses c on c.id = m.course_id
    where m.id = lessons.module_id
      and (c.created_by = auth.uid() or app.is_admin())
  )
)
with check (
  app.is_teacher() and exists (
    select 1
    from app.modules m
    join app.courses c on c.id = m.course_id
    where m.id = lessons.module_id
      and (c.created_by = auth.uid() or app.is_admin())
  )
);

drop policy if exists "media_read" on app.lesson_media;
create policy "media_read" on app.lesson_media for select
using (
  app.is_teacher()
  or exists (
    select 1
    from app.lessons l
    join app.modules m on m.id = l.module_id
    join app.courses c on c.id = m.course_id
    where l.id = lesson_media.lesson_id
      and c.is_published = true
      and (l.is_intro = true or app.can_access_course(auth.uid(), c.id))
  )
);

drop policy if exists "media_teacher_write" on app.lesson_media;
create policy "media_teacher_write" on app.lesson_media for all
using (
  app.is_teacher() and exists (
    select 1
    from app.lessons l
    join app.modules m on m.id = l.module_id
    join app.courses c on c.id = m.course_id
    where l.id = lesson_media.lesson_id
      and (c.created_by = auth.uid() or app.is_admin())
  )
)
with check (
  app.is_teacher() and exists (
    select 1
    from app.lessons l
    join app.modules m on m.id = l.module_id
    join app.courses c on c.id = m.course_id
    where l.id = lesson_media.lesson_id
      and (c.created_by = auth.uid() or app.is_admin())
  )
);

drop policy if exists "media_owner_manage" on app.media_objects;
create policy "media_owner_manage" on app.media_objects for all
using (owner_id = auth.uid() or app.is_admin())
with check (owner_id = auth.uid() or app.is_admin());

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

drop policy if exists "enroll_read_own_or_teacher" on app.enrollments;
create policy "enroll_read_own_or_teacher" on app.enrollments for select
using (user_id = auth.uid() or app.is_teacher());

drop policy if exists "enroll_insert_self" on app.enrollments;
create policy "enroll_insert_self" on app.enrollments for insert
with check (user_id = auth.uid());

drop policy if exists "cert_read_own_or_teacher" on app.certificates;
create policy "cert_read_own_or_teacher" on app.certificates for select
using (user_id = auth.uid() or app.is_teacher());

drop policy if exists "cert_teacher_write" on app.certificates;
create policy "cert_teacher_write" on app.certificates for all
using (app.is_teacher()) with check (app.is_teacher());

drop policy if exists "memb_read_own_or_admin" on app.memberships;
create policy "memb_read_own_or_admin" on app.memberships for select
using (user_id = auth.uid() or app.is_admin());

drop policy if exists "memb_admin_write" on app.memberships;
create policy "memb_admin_write" on app.memberships for all
using (app.is_admin()) with check (app.is_admin());

drop policy if exists "orders_read_own" on app.orders;
create policy "orders_read_own" on app.orders for select
using (user_id = auth.uid());

drop policy if exists "orders_insert_self" on app.orders;
create policy "orders_insert_self" on app.orders for insert
with check (user_id = auth.uid());

drop policy if exists "orders_update_service" on app.orders;
create policy "orders_update_service" on app.orders for update
using (app.is_admin());

drop policy if exists "purchases_read_own" on app.purchases;
create policy "purchases_read_own" on app.purchases for select
using (auth.uid() = user_id);

revoke all on app.guest_claim_tokens from anon, authenticated;

drop policy if exists "progress_read_own" on app.pro_progress;
create policy "progress_read_own" on app.pro_progress for select
using (user_id = auth.uid());

drop policy if exists "progress_write_own" on app.pro_progress;
create policy "progress_write_own" on app.pro_progress for all
using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "pro_req_read_all" on app.pro_requirements;
create policy "pro_req_read_all" on app.pro_requirements for select
using (true);

drop policy if exists "teacher_approvals_read" on app.teacher_approvals;
create policy "teacher_approvals_read" on app.teacher_approvals for select
using (app.is_admin() or app.is_teacher());

drop policy if exists "events_public_read" on app.events;
create policy "events_public_read" on app.events for select
using (is_published = true or app.is_teacher());

drop policy if exists "events_teacher_write" on app.events;
create policy "events_teacher_write" on app.events for all
using (app.is_teacher()) with check (app.is_teacher());

drop policy if exists "services_public_read" on app.services;
create policy "services_public_read" on app.services for select
using (active = true or app.is_teacher());

drop policy if exists "services_owner_write" on app.services;
create policy "services_owner_write" on app.services for all
using (provider_id = auth.uid() or app.is_teacher())
with check (provider_id = auth.uid() or app.is_teacher());

drop policy if exists "treq_read_owner_or_admin" on app.teacher_requests;
create policy "treq_read_owner_or_admin" on app.teacher_requests for select
using (user_id = auth.uid() or app.is_teacher());

drop policy if exists "treq_owner_insert" on app.teacher_requests;
create policy "treq_owner_insert" on app.teacher_requests for insert
with check (user_id = auth.uid());

drop policy if exists "treq_admin_update" on app.teacher_requests;
create policy "treq_admin_update" on app.teacher_requests for update
using (app.is_admin()) with check (app.is_admin());

drop policy if exists "tdir_public_read" on app.teacher_directory;
create policy "tdir_public_read" on app.teacher_directory for select using (true);

drop policy if exists "tdir_admin_write" on app.teacher_directory;
create policy "tdir_admin_write" on app.teacher_directory for all
using (app.is_admin()) with check (app.is_admin());

drop policy if exists "slots_read_teacher_or_public_future" on app.teacher_slots;
create policy "slots_read_teacher_or_public_future" on app.teacher_slots for select
using (app.is_teacher() or (is_booked = false and starts_at > now()));

drop policy if exists "slots_teacher_write" on app.teacher_slots;
create policy "slots_teacher_write" on app.teacher_slots for all
using (teacher_id = auth.uid() or app.is_teacher())
with check (teacher_id = auth.uid() or app.is_teacher());

drop policy if exists "bookings_read_own_or_teacher" on app.bookings;
create policy "bookings_read_own_or_teacher" on app.bookings for select
using (user_id = auth.uid() or app.is_teacher());

drop policy if exists "bookings_owner_insert" on app.bookings;
create policy "bookings_owner_insert" on app.bookings for insert
with check (user_id = auth.uid());

drop policy if exists "bookings_owner_update" on app.bookings;
create policy "bookings_owner_update" on app.bookings for update
using (user_id = auth.uid() or app.is_teacher())
with check (user_id = auth.uid() or app.is_teacher());

drop policy if exists "tarot_read_parties" on app.tarot_requests;
create policy "tarot_read_parties" on app.tarot_requests for select
using (requester_id = auth.uid() or reader_id = auth.uid() or app.is_teacher());

drop policy if exists "tarot_insert_requester" on app.tarot_requests;
create policy "tarot_insert_requester" on app.tarot_requests for insert
with check (requester_id = auth.uid());

drop policy if exists "tarot_update_parties" on app.tarot_requests;
create policy "tarot_update_parties" on app.tarot_requests for update
using (requester_id = auth.uid() or reader_id = auth.uid() or app.is_teacher())
with check (requester_id = auth.uid() or reader_id = auth.uid() or app.is_teacher());

drop policy if exists "posts_public_read" on app.posts;
create policy "posts_public_read" on app.posts for select using (true);

drop policy if exists "posts_author_insert" on app.posts;
create policy "posts_author_insert" on app.posts for insert
with check (author_id = auth.uid());

drop policy if exists "posts_author_update" on app.posts;
create policy "posts_author_update" on app.posts for update
using (author_id = auth.uid()) with check (author_id = auth.uid());

drop policy if exists "posts_author_delete" on app.posts;
create policy "posts_author_delete" on app.posts for delete
using (author_id = auth.uid());

drop policy if exists "follows_public_read" on app.follows;
create policy "follows_public_read" on app.follows for select using (true);

drop policy if exists "follows_self_insert" on app.follows;
create policy "follows_self_insert" on app.follows for insert
with check (follower_id = auth.uid());

drop policy if exists "follows_self_delete" on app.follows;
create policy "follows_self_delete" on app.follows for delete
using (follower_id = auth.uid());

drop policy if exists "meditations_public_read" on app.meditations;
create policy "meditations_public_read" on app.meditations for select
using (is_public = true or app.is_teacher());

drop policy if exists "meditations_teacher_write" on app.meditations;
create policy "meditations_teacher_write" on app.meditations for all
using (teacher_id = auth.uid() or app.is_teacher())
with check (teacher_id = auth.uid() or app.is_teacher());

drop policy if exists "course_quiz_teacher_read" on app.course_quizzes;
create policy "course_quiz_teacher_read" on app.course_quizzes for select
using (
  app.is_teacher() and exists (
    select 1 from app.courses c
    where c.id = course_id and (c.created_by = auth.uid() or app.is_admin())
  )
);

drop policy if exists "course_quiz_teacher_write" on app.course_quizzes;
create policy "course_quiz_teacher_write" on app.course_quizzes for all
using (
  app.is_teacher() and exists (
    select 1 from app.courses c
    where c.id = course_id and (c.created_by = auth.uid() or app.is_admin())
  )
)
with check (
  app.is_teacher() and exists (
    select 1 from app.courses c
    where c.id = course_id and (c.created_by = auth.uid() or app.is_admin())
  )
);

drop policy if exists "quiz_questions_teacher_read" on app.quiz_questions;
create policy "quiz_questions_teacher_read" on app.quiz_questions for select
using (
  app.is_teacher() and exists (
    select 1 from app.course_quizzes cq
    join app.courses c on c.id = cq.course_id
    where cq.id = quiz_id and (c.created_by = auth.uid() or app.is_admin())
  )
);

drop policy if exists "quiz_questions_teacher_write" on app.quiz_questions;
create policy "quiz_questions_teacher_write" on app.quiz_questions for all
using (
  app.is_teacher() and exists (
    select 1 from app.course_quizzes cq
    join app.courses c on c.id = cq.course_id
    where cq.id = quiz_id and (c.created_by = auth.uid() or app.is_admin())
  )
)
with check (
  app.is_teacher() and exists (
    select 1 from app.course_quizzes cq
    join app.courses c on c.id = cq.course_id
    where cq.id = quiz_id and (c.created_by = auth.uid() or app.is_admin())
  )
);

drop policy if exists "notifications_self_read" on app.notifications;
create policy "notifications_self_read" on app.notifications for select
using (user_id = auth.uid());

drop policy if exists "notifications_self_update" on app.notifications;
create policy "notifications_self_update" on app.notifications for update
using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "notifications_self_insert" on app.notifications;
create policy "notifications_self_insert" on app.notifications for insert
with check (user_id = auth.uid());

drop policy if exists "reviews_public_read" on app.reviews;
create policy "reviews_public_read" on app.reviews for select using (true);

drop policy if exists "reviews_reviewer_insert" on app.reviews;
create policy "reviews_reviewer_insert" on app.reviews for insert
with check (reviewer_id = auth.uid());

drop policy if exists "reviews_reviewer_delete" on app.reviews;
create policy "reviews_reviewer_delete" on app.reviews for delete
using (reviewer_id = auth.uid());
drop policy if exists "refresh_tokens_self_read" on app.refresh_tokens;
create policy "refresh_tokens_self_read" on app.refresh_tokens for select
using (user_id = auth.uid() or app.is_admin());

drop policy if exists "auth_events_self_read" on app.auth_events;
create policy "auth_events_self_read" on app.auth_events for select
using (user_id = auth.uid() or app.is_admin());

-- ---------- 4) RPC ----------
-- Lärar-godkännande och moderering
create or replace function app.approve_teacher(p_user uuid)
returns void language plpgsql security definer as $$
begin
  update app.profiles
     set role_v2 = 'teacher',
         updated_at = now()
   where user_id = p_user;
  update app.teacher_requests
     set status='approved', reviewed_by = auth.uid(), updated_at = now()
   where user_id = p_user;
end; $$;

create or replace function app.reject_teacher(p_user uuid)
returns void language plpgsql security definer as $$
begin
  update app.teacher_requests
     set status='rejected', reviewed_by = auth.uid(), updated_at = now()
   where user_id = p_user;
end; $$;
create or replace function app.start_order(p_course_id uuid, p_amount_cents integer, p_currency text default 'sek', p_metadata jsonb default '{}'::jsonb)
returns app.orders language plpgsql security definer as $$
declare v_user uuid := auth.uid(); v_order app.orders;
begin
  if v_user is null then raise exception 'Not authenticated'; end if;
  insert into app.orders(user_id, course_id, amount_cents, currency, status, metadata)
  values (v_user, p_course_id, p_amount_cents, coalesce(p_currency,'sek'), 'pending', p_metadata)
  returning * into v_order;
  return v_order;
end; $$;

create or replace function app.complete_order(p_order_id uuid, p_payment_intent text, p_checkout_id text default null)
returns app.orders language plpgsql security definer as $$
declare v_order app.orders;
begin
  update app.orders
     set status='paid',
         stripe_payment_intent=p_payment_intent,
         stripe_checkout_id = coalesce(p_checkout_id, stripe_checkout_id),
         updated_at = now()
   where id=p_order_id
  returning * into v_order;
  if not found then raise exception 'Order not found'; end if;

  if v_order.course_id is not null then
    insert into app.enrollments(user_id, course_id, source)
    values (v_order.user_id, v_order.course_id, 'purchase')
    on conflict (user_id, course_id) do nothing;
  end if;
  return v_order;
end; $$;

create or replace function app.grade_quiz_and_issue_certificate(p_quiz_id uuid, p_answers jsonb)
returns jsonb
language plpgsql
security definer
set search_path = app, public
as $$
declare
  v_quiz record;
  v_question record;
  v_total integer := 0;
  v_correct integer := 0;
  v_user uuid := auth.uid();
  v_answer text;
  v_score numeric := 0;
  v_passed boolean := false;
  v_certificate uuid;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  select id, course_id, coalesce(pass_score, 0) as pass_score
    into v_quiz
  from app.course_quizzes
  where id = p_quiz_id;

  if v_quiz.id is null then
    raise exception 'quiz_not_found';
  end if;

  for v_question in
    select id, kind, coalesce(correct, '') as correct
    from app.quiz_questions
    where quiz_id = p_quiz_id
    order by position
  loop
    v_total := v_total + 1;
    v_answer := coalesce(p_answers ->> v_question.id::text, '');

    if v_question.kind in ('single', 'text', 'multi') then
      if lower(trim(v_answer)) = lower(trim(v_question.correct)) then
        v_correct := v_correct + 1;
      end if;
    end if;
  end loop;

  if v_total > 0 then
    v_score := (v_correct::numeric / v_total::numeric) * 100;
  end if;

  v_passed := (v_total > 0) and v_score >= coalesce(v_quiz.pass_score, 0);

  if v_passed then
    insert into app.certificates (user_id, course_id, title, status, notes)
    values (
      v_user,
      v_quiz.course_id,
      coalesce((select title from app.courses where id = v_quiz.course_id), 'Kurscertifikat'),
      'verified',
      'Godkänt quiz'
    )
    on conflict (user_id, course_id) do update
      set status = 'verified',
          updated_at = now()
    returning id into v_certificate;
  end if;

  return jsonb_build_object(
    'correct', v_correct,
    'total', v_total,
    'score', v_score,
    'passed', v_passed,
    'certificate_id', v_certificate
  );
end;
$$;

create or replace function app.can_access_course(p_course uuid)
returns boolean
language sql
stable
as $$
  select app.can_access_course(auth.uid(), p_course);
$$;

create or replace function app.claim_purchase(p_token uuid)
returns boolean
language plpgsql
security definer
set search_path = app, public
as $$
declare
  v_token app.guest_claim_tokens%rowtype;
  v_user uuid := auth.uid();
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  select * into v_token
  from app.guest_claim_tokens
  where token = p_token
    and used = false
    and expires_at > now()
  for update;

  if not found then
    return false;
  end if;

  update app.purchases
     set user_id = v_user
   where id = v_token.purchase_id;

  update app.guest_claim_tokens
     set used = true
   where token = p_token;

  insert into app.enrollments(user_id, course_id, source)
  values (v_user, v_token.course_id, 'purchase')
  on conflict (user_id, course_id) do nothing;

  return true;
end;
$$;

grant execute on function app.claim_purchase(uuid) to authenticated;

create or replace function app.free_consumed_count()
returns integer
language sql
stable
as $$
  select app.free_consumed_count(auth.uid());
$$;

-- ---------- 5) Storage (media) ----------
insert into storage.buckets (id, name, public)
select 'media', 'media', true
where not exists (select 1 from storage.buckets where id='media');

drop policy if exists "media_public_read" on storage.objects;
create policy "media_public_read" on storage.objects for select
using (bucket_id = 'media');

drop policy if exists "media_teacher_write" on storage.objects;
create policy "media_teacher_write" on storage.objects for insert
with check (bucket_id='media' and app.is_teacher());

drop policy if exists "media_teacher_update" on storage.objects;
create policy "media_teacher_update" on storage.objects for update
using (bucket_id='media' and app.is_teacher())
with check (bucket_id='media' and app.is_teacher());

drop policy if exists "media_teacher_delete" on storage.objects;
create policy "media_teacher_delete" on storage.objects for delete
using (bucket_id='media' and app.is_teacher());

-- ---------- 6) Triggers ----------
create or replace function app.touch_updated_at()
returns trigger language plpgsql as $$ begin new.updated_at := now(); return new; end $$;

drop trigger if exists trg_profiles_touch on app.profiles;
create trigger trg_profiles_touch before update on app.profiles for each row execute function app.touch_updated_at();

drop trigger if exists trg_courses_touch on app.courses;
create trigger trg_courses_touch before update on app.courses for each row execute function app.touch_updated_at();

drop trigger if exists trg_orders_touch on app.orders;
create trigger trg_orders_touch before update on app.orders for each row execute function app.touch_updated_at();

drop trigger if exists trg_tarot_touch on app.tarot_requests;
create trigger trg_tarot_touch before update on app.tarot_requests for each row execute function app.touch_updated_at();

drop trigger if exists trg_course_quizzes_touch on app.course_quizzes;
create trigger trg_course_quizzes_touch before update on app.course_quizzes for each row execute function app.touch_updated_at();

drop trigger if exists trg_quiz_questions_touch on app.quiz_questions;
create trigger trg_quiz_questions_touch before update on app.quiz_questions for each row execute function app.touch_updated_at();

-- ---------- 7) Seed (minimal) ----------
do $$
declare v_admin uuid; v_teacher uuid;
begin
  select id into v_admin from auth.users order by created_at asc limit 1;
  select id into v_teacher from auth.users order by created_at asc offset 1 limit 1;

  if v_admin is not null then
    insert into app.profiles(user_id, email, display_name, role_v2, is_admin)
    values (v_admin, (select email from auth.users where id=v_admin), 'Admin', 'teacher', true)
    on conflict (user_id) do update
      set role_v2   = 'teacher',
          is_admin  = true,
          updated_at = now();
    insert into app.memberships(user_id, plan, status) values (v_admin,'pro','active')
    on conflict (user_id) do nothing;
  end if;

  if v_teacher is not null then
    insert into app.profiles(user_id, email, display_name, role_v2)
    values (v_teacher, (select email from auth.users where id=v_teacher), 'Teacher One', 'teacher')
    on conflict (user_id) do update
      set role_v2   = 'teacher',
          updated_at = now();
  end if;

  insert into app.courses(slug,title,description,is_free_intro,price_cents,is_published,created_by)
  values ('introduktion-till-ritual','Introduktion till Ritual','Grundkurs med 3 intro-lektioner',true,12900,true,v_teacher)
  on conflict (slug) do nothing;

  if exists (select 1 from app.courses where slug='introduktion-till-ritual') then
    insert into app.modules(course_id,title,position)
    select id,'Kapitel 1',1 from app.courses where slug='introduktion-till-ritual'
    on conflict do nothing;

    insert into app.lessons(module_id,title,content_markdown,is_intro,position)
    select m.id,'Välkommen','### Start',true,1
    from app.modules m join app.courses c on c.id=m.course_id
    where c.slug='introduktion-till-ritual' and m.position=1
    on conflict do nothing;

    insert into app.lessons(module_id,title,content_markdown,is_intro,position)
    select m.id,'Andning','### Andningsövning',true,2
    from app.modules m join app.courses c on c.id=m.course_id
    where c.slug='introduktion-till-ritual' and m.position=1
    on conflict do nothing;

    insert into app.lessons(module_id,title,content_markdown,is_intro,position)
    select m.id,'Intention','### Intentionssättning',true,3
    from app.modules m join app.courses c on c.id=m.course_id
    where c.slug='introduktion-till-ritual' and m.position=1
    on conflict do nothing;
  end if;
end$$;

-- ---------- 8) Messages (Realtime chat) ----------
create table if not exists app.messages (
  id uuid primary key default uuid_generate_v4(),
  channel text not null,
  sender_id uuid not null references app.profiles(user_id) on delete cascade,
  content text not null,
  created_at timestamptz not null default now(),
  -- Begränsa innehållslängd och kanalformat:
  constraint messages_content_len check (char_length(content) between 1 and 4000),
  constraint messages_channel_format check (
    channel ~ '^(global|course:[0-9a-fA-F-]{36}|event:[0-9a-fA-F-]{36})$'
  )
);
create index if not exists idx_messages_channel on app.messages(channel);
create index if not exists idx_messages_sender on app.messages(sender_id);

alter table app.messages enable row level security;

-- Kanal-åtkomstfunktioner
create or replace function app.can_read_channel(p_channel text)
returns boolean language sql stable as $$
  with
  kind as (
    select
      case
        when p_channel = 'global' then 'global'
        when left(p_channel,7) = 'course:' then 'course'
        when left(p_channel,6) = 'event:' then 'event'
        else 'other'
      end as k
  )
  select
    -- Global: alla inloggade kan läsa
    (exists(select 1 from kind where k='global') and auth.uid() is not null)
    or
    -- Course:<uuid> kräver enrollment eller teacher/admin
    (exists(select 1 from kind where k='course')
     and (
       app.is_teacher()
       or exists (
         select 1
         from app.enrollments e
         where e.user_id = auth.uid()
           and e.course_id = (substring(p_channel from 8)::uuid)
       )
     ))
    or
    -- Event:<uuid> läsbart om publicerat, skapare, eller teacher/admin
    (exists(select 1 from kind where k='event')
     and (
       app.is_teacher()
       or exists (
         select 1 from app.events ev
         where ev.id = (substring(p_channel from 7)::uuid)
           and (ev.is_published = true or ev.created_by = auth.uid())
       )
     ));
$$;

create or replace function app.can_post_channel(p_channel text, p_sender uuid)
returns boolean language sql stable as $$
  with
  kind as (
    select
      case
        when p_channel = 'global' then 'global'
        when left(p_channel,7) = 'course:' then 'course'
        when left(p_channel,6) = 'event:' then 'event'
        else 'other'
      end as k
  )
  select
    -- Global: alla inloggade kan posta
    (exists(select 1 from kind where k='global') and p_sender = auth.uid())
    or
    -- Course:<uuid>: enrollment eller teacher/admin
    (exists(select 1 from kind where k='course')
     and (
       app.is_teacher()
       or exists (
         select 1
         from app.enrollments e
         where e.user_id = p_sender
           and e.course_id = (substring(p_channel from 8)::uuid)
       )
     )
     and p_sender = auth.uid())
    or
    -- Event:<uuid>: event-skapare eller teacher/admin
    (exists(select 1 from kind where k='event')
     and (
       app.is_teacher()
       or exists (
         select 1 from app.events ev
         where ev.id = (substring(p_channel from 7)::uuid)
           and ev.created_by = p_sender
       )
     )
     and p_sender = auth.uid());
$$;

-- RLS: läs/skriv efter reglerna ovan
drop policy if exists "messages_read" on app.messages;
create policy "messages_read" on app.messages for select
using (app.can_read_channel(channel));

drop policy if exists "messages_insert" on app.messages;
create policy "messages_insert" on app.messages for insert
with check (sender_id = auth.uid() and app.can_post_channel(channel, sender_id));

-- ---------- 9) GDPR (Export & Delete) ----------
create or replace function app.export_user_data(p_user uuid default auth.uid())
returns jsonb language plpgsql security definer as $$
declare result jsonb;
begin
  if p_user is null then raise exception 'Not authenticated'; end if;

  result := jsonb_build_object(
    'profile',        (select row_to_json(p) from app.profiles p where p.user_id = p_user),
    'memberships',    (select jsonb_agg(m) from app.memberships m where m.user_id = p_user),
    'enrollments',    (select jsonb_agg(e) from app.enrollments e where e.user_id = p_user),
    'certificates',   (select jsonb_agg(c) from app.certificates c where c.user_id = p_user),
    'purchases',      (select jsonb_agg(pr) from app.purchases pr where pr.user_id = p_user),
    'orders',         (select jsonb_agg(o) from app.orders o where o.user_id = p_user),
    'guest_claim_tokens', (select jsonb_agg(g) from app.guest_claim_tokens g where g.buyer_email = (select email from app.profiles where user_id = p_user)),
    'pro_progress',   (select jsonb_agg(pp) from app.pro_progress pp where pp.user_id = p_user),
    'events',         (select jsonb_agg(ev) from app.events ev where ev.created_by = p_user),
    'services',       (select jsonb_agg(s) from app.services s where s.provider_id = p_user),
    'bookings',       (select jsonb_agg(b) from app.bookings b where b.user_id = p_user),
    'tarot_requests', (select jsonb_agg(t) from app.tarot_requests t where t.requester_id = p_user or t.reader_id = p_user),
    'messages',       (select jsonb_agg(m) from app.messages m where m.sender_id = p_user)
  );

  return coalesce(result, '{}'::jsonb);
end; $$;

create or replace function app.delete_user_data(p_user uuid)
returns void language plpgsql security definer as $$
begin
  delete from app.messages where sender_id = p_user;
  delete from app.bookings where user_id = p_user;
  delete from app.tarot_requests where requester_id = p_user or reader_id = p_user;
  delete from app.services where provider_id = p_user;
  delete from app.events where created_by = p_user;
  delete from app.guest_claim_tokens
    where purchase_id in (select id from app.purchases where user_id = p_user)
       or buyer_email = (select email from app.profiles where user_id = p_user);
  delete from app.purchases where user_id = p_user;
  delete from app.orders where user_id = p_user;
  delete from app.certificates where user_id = p_user;
  delete from app.pro_progress where user_id = p_user;
  delete from app.teacher_approvals where user_id = p_user;
  delete from app.enrollments where user_id = p_user;
  delete from app.memberships where user_id = p_user;
  delete from app.teacher_requests where user_id = p_user;
  delete from app.teacher_directory where user_id = p_user;
  delete from app.teacher_slots where teacher_id = p_user;
  delete from app.profiles where user_id = p_user;
  -- auth.users raderas via Supabase Auth Admin API
end; $$;

commit;
