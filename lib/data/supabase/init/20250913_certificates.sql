-- =====================================================================
-- Visdom • Certificates (idempotent)
-- Schema: app
-- Users can add certificates; verified ones are public for teacher profiles.
-- =====================================================================

begin;

create table if not exists app.certificates (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references app.profiles(user_id) on delete cascade,
  title text not null,
  issuer text,
  issued_at date,
  verified boolean not null default false,
  specialties text[] not null default '{}',
  credential_id text,
  credential_url text,
  badge_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_cert_user on app.certificates(user_id);
create index if not exists idx_cert_verified on app.certificates(verified);

alter table app.certificates enable row level security;

-- Read: everyone can read verified certificates; owners and teachers can read their own/unverified
drop policy if exists "cert_read" on app.certificates;
create policy "cert_read" on app.certificates for select
using (
  verified = true
  or user_id = auth.uid()
  or app.is_teacher()
);

-- Write: owners can insert/update/delete their certificates; teachers/admin can update verified flag
drop policy if exists "cert_write_owner" on app.certificates;
create policy "cert_write_owner" on app.certificates for all
using (user_id = auth.uid() or app.is_teacher())
with check (user_id = auth.uid() or app.is_teacher());

-- Trigger to update updated_at
create or replace function app.set_updated_at() returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

drop trigger if exists trg_cert_updated_at on app.certificates;
create trigger trg_cert_updated_at before update on app.certificates
for each row execute function app.set_updated_at();

-- Grants
grant select, insert, update, delete on app.certificates to anon, authenticated;

commit;

