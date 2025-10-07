-- ============================================================================
-- bootstrap.sql
-- Local development compatibility layer that emulates Supabase auth/storage
-- primitives on a plain PostgreSQL instance. Idempotent.
-- ============================================================================

begin;

-- Foundational extensions (match Supabase defaults)
create extension if not exists pgcrypto;
create extension if not exists "uuid-ossp";

-- ------------------------------------------------------------
-- Roles that Supabase usually provisions. Helpful for RLS tests
-- ------------------------------------------------------------
do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then
    create role anon;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then
    create role authenticated;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then
    create role service_role;
  end if;
exception when insufficient_privilege then
  -- Fail silently if we are not allowed to create roles (e.g. hosted env)
  null;
end$$;

create schema if not exists app;

create schema if not exists auth;

create table if not exists auth.users (
  instance_id uuid,
  id uuid primary key,
  aud varchar(255),
  role varchar(255),
  email varchar(255) unique,
  encrypted_password varchar(255),
  email_confirmed_at timestamptz,
  invited_at timestamptz,
  confirmation_token varchar(255),
  confirmation_sent_at timestamptz,
  recovery_token varchar(255),
  recovery_sent_at timestamptz,
  email_change_token_new varchar(255),
  email_change varchar(255),
  email_change_sent_at timestamptz,
  last_sign_in_at timestamptz,
  raw_app_meta_data jsonb,
  raw_user_meta_data jsonb,
  is_super_admin boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  phone text,
  phone_confirmed_at timestamptz,
  phone_change text default ''::text,
  phone_change_token varchar(255) default ''::varchar,
  phone_change_sent_at timestamptz,
  confirmed_at timestamptz generated always as (least(email_confirmed_at, phone_confirmed_at)) stored,
  email_change_token_current varchar(255) default ''::varchar,
  email_change_confirm_status smallint default 0,
  banned_until timestamptz,
  reauthentication_token varchar(255) default ''::varchar,
  reauthentication_sent_at timestamptz,
  is_sso_user boolean default false not null,
  deleted_at timestamptz,
  is_anonymous boolean default false not null,
  constraint users_email_change_confirm_status_check
    check (email_change_confirm_status between 0 and 2)
);

create index if not exists users_email_idx on auth.users(lower(email));

create table if not exists auth.identities (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  identity_data jsonb,
  provider text,
  provider_id text,
  last_sign_in_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  email text
);

create unique index if not exists identities_provider_unique
  on auth.identities(provider_id, provider);
create index if not exists identities_user_idx on auth.identities(user_id);

-- Emulate Supabase auth helpers (context stored in custom GUCs)
create or replace function auth.uid()
returns uuid
language sql
stable
as $$
  select nullif(current_setting('app.current_user_id', true), '')::uuid;
$$;

create or replace function auth.jwt()
returns jsonb
language sql
stable
as $$
  select coalesce(nullif(current_setting('app.current_jwt', true), '')::jsonb, '{}'::jsonb);
$$;

create or replace function auth.role()
returns text
language sql
stable
as $$
  select
    coalesce(
      nullif(current_setting('app.current_role', true), ''),
      auth.jwt() ->> 'role',
      'authenticated'
    );
$$;

create or replace function auth.email()
returns text
language sql
stable
as $$
  select coalesce(
    nullif(current_setting('app.current_email', true), ''),
    auth.jwt() ->> 'email'
  );
$$;

create or replace function app.set_local_auth(
  p_user uuid default null,
  p_email text default null,
  p_role text default null,
  p_jwt jsonb default null
) returns void
language plpgsql
as $$
begin
  perform set_config('app.current_user_id', coalesce(p_user::text, ''), true);
  perform set_config('app.current_email', coalesce(p_email, ''), true);
  if p_jwt is not null then
    perform set_config('app.current_jwt', p_jwt::text, true);
  elsif p_role is not null or p_email is not null then
    perform set_config(
      'app.current_jwt',
      jsonb_build_object(
        'sub', coalesce(p_user::text, ''),
        'email', p_email,
        'role', p_role,
        'app_metadata', jsonb_build_object('role', p_role)
      )::text,
      true
    );
  else
    perform set_config('app.current_jwt', '{}'::jsonb::text, true);
  end if;
  perform set_config('app.current_role', coalesce(p_role, ''), true);
end;
$$;

-- ============================================================
-- Schema: storage
-- ============================================================
create schema if not exists storage;

create table if not exists storage.buckets (
  id text primary key,
  name text,
  owner uuid,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  public boolean default false,
  avif_autodetection boolean default false,
  file_size_limit bigint,
  allowed_mime_types text[]
);

create table if not exists storage.objects (
  id uuid primary key default gen_random_uuid(),
  bucket_id text references storage.buckets(id) on delete cascade,
  name text not null,
  owner uuid,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  last_accessed_at timestamptz,
  metadata jsonb default '{}'::jsonb,
  path_tokens text[] default array[]::text[],
  version uuid default gen_random_uuid(),
  etag text,
  content_length bigint,
  uploaded_at timestamptz default now()
);

alter table storage.objects enable row level security;

commit;

-- End of bootstrap.sql
