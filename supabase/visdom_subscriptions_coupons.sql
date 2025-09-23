-- Visdom subscriptions, coupons, RLS and RPCs (idempotent, public schema)

begin;

create extension if not exists pgcrypto;
create extension if not exists "uuid-ossp";

-- Helpers to read role from JWT app_metadata
create or replace function public.is_admin()
returns boolean language sql stable as $$
  select coalesce((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin', false);
$$;

create or replace function public.is_teacher()
returns boolean language sql stable as $$
  select coalesce((auth.jwt() -> 'app_metadata' ->> 'role') in ('teacher','admin'), false);
$$;

-- 1) profiles
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique,
  full_name text,
  avatar_url text,
  bio text,
  subjects text,
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
drop policy if exists "profiles_public_read" on public.profiles;
create policy "profiles_public_read" on public.profiles for select using (true);
drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);

-- 2) courses (+ extra columns)
create table if not exists public.courses (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  is_intro boolean not null default false,
  is_published boolean not null default false,
  video_url text,
  hero_image_url text,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);
alter table public.courses enable row level security;
drop policy if exists "courses_public_read" on public.courses;
create policy "courses_public_read" on public.courses for select using (is_published = true or public.is_teacher());
drop policy if exists "courses_teacher_write" on public.courses;
create policy "courses_teacher_write" on public.courses for all using (public.is_teacher() and (created_by = auth.uid() or public.is_admin())) with check (public.is_teacher() and (created_by = auth.uid() or public.is_admin()));

-- 3) teacher_permissions
create table if not exists public.teacher_permissions (
  profile_id uuid primary key references public.profiles(id) on delete cascade,
  can_edit_courses boolean not null default false,
  granted_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);
alter table public.teacher_permissions enable row level security;
drop policy if exists "teacher_perms_admin_only" on public.teacher_permissions;
create policy "teacher_perms_admin_only" on public.teacher_permissions for all using (public.is_admin()) with check (public.is_admin());

-- 4) services (simplified)
create table if not exists public.services (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  description text,
  price_cents integer not null default 0,
  certified_area text,
  hero_image_url text,
  created_at timestamptz not null default now()
);
alter table public.services enable row level security;
drop policy if exists "services_public_read" on public.services;
create policy "services_public_read" on public.services for select using (true);
drop policy if exists "services_owner_write" on public.services;
create policy "services_owner_write" on public.services for all using (owner_id = auth.uid());

-- 5) subscriptions
create table if not exists public.subscription_plans (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  price_cents integer not null default 0,
  interval text not null check (interval in ('month','year')),
  is_active boolean not null default true
);

create table if not exists public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  plan_id uuid not null references public.subscription_plans(id),
  status text not null check (status in ('active','canceled','incomplete')),
  current_period_end timestamptz not null,
  created_at timestamptz not null default now()
);
alter table public.subscriptions enable row level security;
drop policy if exists "subs_read_own" on public.subscriptions;
create policy "subs_read_own" on public.subscriptions for select using (auth.uid() = user_id or public.is_admin());
-- No direct writes; use RPC
drop policy if exists "subs_no_direct_write" on public.subscriptions;
create policy "subs_no_direct_write" on public.subscriptions for all using (false) with check (false);

-- 6) coupons / invites
create table if not exists public.coupons (
  code text primary key,
  plan_id uuid references public.subscription_plans(id) on delete cascade,
  grants jsonb,
  max_redemptions int not null default 1,
  redeemed_count int not null default 0,
  expires_at timestamptz,
  issued_by uuid references auth.users(id),
  issued_at timestamptz not null default now()
);
alter table public.coupons enable row level security;
drop policy if exists "coupons_admin_only" on public.coupons;
create policy "coupons_admin_only" on public.coupons for all using (public.is_admin()) with check (public.is_admin());

-- 7) user certifications (areas)
create table if not exists public.user_certifications (
  user_id uuid not null references auth.users(id) on delete cascade,
  area text not null,
  primary key (user_id, area)
);
alter table public.user_certifications enable row level security;
drop policy if exists "certs_read_own" on public.user_certifications;
create policy "certs_read_own" on public.user_certifications for select using (auth.uid() = user_id or public.is_admin());
drop policy if exists "certs_write_own" on public.user_certifications;
create policy "certs_write_own" on public.user_certifications for all using (auth.uid() = user_id or public.is_admin()) with check (auth.uid() = user_id or public.is_admin());

-- RPC: preview_coupon
create or replace function public.preview_coupon(p_plan uuid, p_code text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  plan record;
  c record;
  pay int := 0;
begin
  select * into plan from public.subscription_plans where id = p_plan and is_active = true;
  if plan is null then
    return jsonb_build_object('valid', false, 'pay_amount_cents', 0);
  end if;

  pay := plan.price_cents;

  if p_code is null or length(p_code) = 0 then
    return jsonb_build_object('valid', false, 'pay_amount_cents', pay);
  end if;

  select * into c from public.coupons where code = p_code and (expires_at is null or expires_at > now()) and (plan_id is null or plan_id = plan.id);
  if c is null then
    return jsonb_build_object('valid', false, 'pay_amount_cents', pay);
  end if;
  if c.redeemed_count >= c.max_redemptions then
    return jsonb_build_object('valid', false, 'pay_amount_cents', pay);
  end if;

  return jsonb_build_object('valid', true, 'pay_amount_cents', 0);
end;
$$;

revoke all on function public.preview_coupon(uuid, text) from public;
grant execute on function public.preview_coupon(uuid, text) to anon, authenticated;

-- RPC: redeem_coupon_and_provision
create or replace function public.redeem_coupon_and_provision(p_plan uuid, p_code text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  plan record;
  c record;
  period_end timestamptz;
  grants jsonb;
  role_target text;
  area_text text;
  is_teacher_grant boolean := false;
begin
  if uid is null then
    return jsonb_build_object('ok', false, 'reason', 'not_authenticated');
  end if;

  select * into plan from public.subscription_plans where id = p_plan and is_active = true;
  if plan is null then
    return jsonb_build_object('ok', false, 'reason', 'invalid_plan');
  end if;

  select * into c from public.coupons where code = p_code and (expires_at is null or expires_at > now()) and (plan_id is null or plan_id = plan.id);
  if c is null then
    return jsonb_build_object('ok', false, 'reason', 'invalid_coupon');
  end if;
  if c.redeemed_count >= c.max_redemptions then
    return jsonb_build_object('ok', false, 'reason', 'coupon_redeemed');
  end if;

  -- consume coupon
  update public.coupons set redeemed_count = redeemed_count + 1 where code = c.code;

  -- subscription
  if plan.interval = 'month' then
    period_end := now() + interval '30 days';
  else
    period_end := now() + interval '365 days';
  end if;

  insert into public.subscriptions(user_id, plan_id, status, current_period_end)
  values (uid, plan.id, 'active', period_end);

  -- grants
  grants := coalesce(c.grants, '{}'::jsonb);
  role_target := coalesce(grants->>'role', null);
  is_teacher_grant := (grants->>'teacher')::boolean is true;

  -- update auth.users app_metadata.role (requires definer privileges)
  if role_target is not null then
    update auth.users set raw_app_meta_data = coalesce(raw_app_meta_data,'{}'::jsonb) || jsonb_build_object('role', role_target)
    where id = uid;
  end if;

  -- teacher permission
  if is_teacher_grant then
    insert into app.teacher_permissions(profile_id, can_edit_courses, can_publish, granted_by, granted_at)
    values (uid, true, true, uid, now())
    on conflict (profile_id) do update
      set can_edit_courses = true,
          can_publish = true,
          granted_at = coalesce(app.teacher_permissions.granted_at, excluded.granted_at);
  end if;

  -- user certifications
  if (grants ? 'certified_areas') then
    for area_text in select jsonb_array_elements_text(grants->'certified_areas') loop
      insert into public.user_certifications(user_id, area) values (uid, area_text)
      on conflict (user_id, area) do nothing;
    end loop;
  end if;

  return jsonb_build_object('ok', true);
end;
$$;

revoke all on function public.redeem_coupon_and_provision(uuid, text) from public;
grant execute on function public.redeem_coupon_and_provision(uuid, text) to authenticated;

-- Storage bucket for public assets
insert into storage.buckets(id, name, public)
values ('public-assets', 'public-assets', true)
on conflict (id) do nothing;

-- Storage policies for the bucket
drop policy if exists "public_select_public_assets" on storage.objects;
create policy "public_select_public_assets" on storage.objects
for select to public
using (bucket_id = 'public-assets');

drop policy if exists "admin_write_public_assets" on storage.objects;
create policy "admin_write_public_assets" on storage.objects
for all to authenticated
using (public.is_admin()) with check (public.is_admin());

-- Seed data
-- 5 intro courses (upsert by title for demo)
insert into public.courses(id,title,description,is_intro,is_published,hero_image_url)
select gen_random_uuid(), x.title, x.desc, true, true, x.img
from (values
  ('Mindfulness Intro','Grunder i medveten närvaro.',''),
  ('Andningsteknik','Lär dig lugnande andning.',''),
  ('Mentalt fokus','Träna upp ditt fokus.',''),
  ('Kroppsscanning','Lyssna in kroppens signaler.',''),
  ('Vanor & balans','Skapa hållbara vanor.','')
) as x(title,desc,img)
on conflict do nothing;

-- 2 plans
insert into public.subscription_plans(id,name,price_cents,interval,is_active)
values
  (gen_random_uuid(),'Bas',14900,'month',true),
  (gen_random_uuid(),'Pro',29900,'month',true)
on conflict do nothing;

-- Seed one invite coupon for Pro
do $$
declare pro_id uuid;
begin
  select id into pro_id from public.subscription_plans where name='Pro' limit 1;
  if pro_id is not null then
    insert into public.coupons(code, plan_id, grants, max_redemptions)
    values ('VISDOM-PRO-INVITE-0', pro_id, '{"role":"member","teacher":true,"certified_areas":["tarot"]}'::jsonb, 100)
    on conflict do nothing;
  end if;
end$$;

commit;
