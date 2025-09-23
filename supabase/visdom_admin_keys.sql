-- Admin keys + RPC for Visdom (public schema)
-- Idempotent: safe to run multiple times

create extension if not exists pgcrypto;

create table if not exists public.admin_keys (
  code text primary key,
  note text,
  created_at timestamptz not null default now(),
  used_at timestamptz,
  used_by uuid references auth.users(id)
);

alter table public.admin_keys enable row level security;

-- Only service_role should manage keys directly
drop policy if exists "admin_keys_service_manage" on public.admin_keys;
create policy "admin_keys_service_manage"
on public.admin_keys for all
to service_role
using (true)
with check (true);

-- RPC to redeem a one-time key. Returns boolean.
create or replace function public.redeem_key(p_code text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
begin
  update public.admin_keys
  set used_at = now(),
      used_by = uid
  where code = p_code
    and used_at is null;

  if found then
    return true;
  else
    return false;
  end if;
end;
$$;

revoke all on function public.redeem_key(text) from public;
grant execute on function public.redeem_key(text) to anon, authenticated;

-- Seed example key (no-op if exists)
insert into public.admin_keys(code, note)
values ('VISDOM-KEY-INITIAL', 'Initial one-time key')
on conflict do nothing;

