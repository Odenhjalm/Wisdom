-- Migration: add refresh token rotation tracking and auth audit events
-- Idempotent so it can be re-run safely.

begin;

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

alter table app.refresh_tokens enable row level security;
alter table app.auth_events enable row level security;

-- Allow users and admins to inspect their own tokens / audit entries.
drop policy if exists "refresh_tokens_self_read" on app.refresh_tokens;
create policy "refresh_tokens_self_read" on app.refresh_tokens for select
using (user_id = auth.uid() or app.is_admin());

drop policy if exists "auth_events_self_read" on app.auth_events;
create policy "auth_events_self_read" on app.auth_events for select
using (user_id = auth.uid() or app.is_admin());

commit;
