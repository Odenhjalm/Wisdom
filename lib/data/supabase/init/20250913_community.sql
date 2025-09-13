-- =====================================================================
-- Visdom • Community Space migration (idempotent)
-- Schema: app
-- Adds: service orders, DM/service channels, meditations catalog
-- =====================================================================

begin;

-- 1) Orders: service support -------------------------------------------------
alter table app.orders
  add column if not exists service_id uuid;

do $$
begin
  if not exists (
    select 1 from information_schema.table_constraints
    where constraint_schema = 'app'
      and table_name = 'orders'
      and constraint_name = 'fk_orders_service_id'
  ) then
    alter table app.orders
      add constraint fk_orders_service_id
      foreign key (service_id) references app.services(id)
      on delete set null;
  end if;
end$$;

create index if not exists idx_orders_service on app.orders(service_id);

-- 2) Messages: service + dm channels ----------------------------------------
-- Allow channel formats: global | course:<uuid> | event:<uuid> | service:<uuid> | dm:<uuid>
alter table app.messages drop constraint if exists messages_channel_format;
alter table app.messages
  add constraint messages_channel_format
  check (
    channel ~ '^(global|course:[0-9a-fA-F-]{36}|event:[0-9a-fA-F-]{36}|service:[0-9a-fA-F-]{36}|dm:[0-9a-fA-F-]{36})$'
  );

-- Read access: add service + dm
create or replace function app.can_read_channel(p_channel text)
returns boolean language sql stable as $$
  with kind as (
    select case
      when p_channel = 'global' then 'global'
      when left(p_channel,7) = 'course:' then 'course'
      when left(p_channel,6) = 'event:' then 'event'
      when left(p_channel,8) = 'service:' then 'service'
      when left(p_channel,3) = 'dm:' then 'dm'
      else 'other' end as k
  )
  select
    -- Global: alla inloggade
    (exists(select 1 from kind where k='global') and auth.uid() is not null)
    or
    -- Course:<uuid>: enrollment eller teacher/admin
    (exists(select 1 from kind where k='course') and (
      app.is_teacher()
      or exists (
        select 1 from app.enrollments e
        where e.user_id = auth.uid()
          and e.course_id = (substring(p_channel from 8)::uuid)
      )
    ))
    or
    -- Event:<uuid>: publicerat, skapare eller teacher/admin
    (exists(select 1 from kind where k='event') and (
      app.is_teacher()
      or exists (
        select 1 from app.events ev
        where ev.id = (substring(p_channel from 7)::uuid)
          and (ev.is_published = true or ev.created_by = auth.uid())
      )
    ))
    or
    -- Service:<uuid>: tjänsteägare, betalda kunder eller teacher/admin
    (exists(select 1 from kind where k='service') and (
      app.is_teacher()
      or exists (
        select 1 from app.services s
        where s.id = (substring(p_channel from 9)::uuid)
          and s.provider_id = auth.uid()
      )
      or exists (
        select 1 from app.orders o
        where o.user_id = auth.uid()
          and o.service_id = (substring(p_channel from 9)::uuid)
          and o.status = 'paid'
      )
    ))
    or
    -- dm:<other_user_id>: mellan other_user_id och auth.uid(), samt teacher/admin
    (exists(select 1 from kind where k='dm') and (
      app.is_teacher()
      or auth.uid() = (substring(p_channel from 4)::uuid)
      or exists (
        select 1 from app.messages m
        where m.channel = p_channel and m.sender_id = auth.uid()
      )
    ));
$$;

-- Post access: add service + dm
create or replace function app.can_post_channel(p_channel text, p_sender uuid)
returns boolean language sql stable as $$
  with kind as (
    select case
      when p_channel = 'global' then 'global'
      when left(p_channel,7) = 'course:' then 'course'
      when left(p_channel,6) = 'event:' then 'event'
      when left(p_channel,8) = 'service:' then 'service'
      when left(p_channel,3) = 'dm:' then 'dm'
      else 'other' end as k
  )
  select
    -- Global: alla inloggade kan posta
    (exists(select 1 from kind where k='global') and p_sender = auth.uid())
    or
    -- Course:<uuid>: enrollment eller teacher/admin
    (exists(select 1 from kind where k='course') and p_sender = auth.uid() and (
      app.is_teacher()
      or exists (
        select 1 from app.enrollments e
        where e.user_id = p_sender
          and e.course_id = (substring(p_channel from 8)::uuid)
      )
    ))
    or
    -- Event:<uuid>: event-skapare eller teacher/admin
    (exists(select 1 from kind where k='event') and p_sender = auth.uid() and (
      app.is_teacher()
      or exists (
        select 1 from app.events ev
        where ev.id = (substring(p_channel from 7)::uuid)
          and ev.created_by = p_sender
      )
    ))
    or
    -- Service:<uuid>: tjänsteägare, betalande kund eller teacher/admin
    (exists(select 1 from kind where k='service') and p_sender = auth.uid() and (
      app.is_teacher()
      or exists (
        select 1 from app.services s
        where s.id = (substring(p_channel from 9)::uuid)
          and s.provider_id = p_sender
      )
      or exists (
        select 1 from app.orders o
        where o.user_id = p_sender
          and o.service_id = (substring(p_channel from 9)::uuid)
          and o.status = 'paid'
      )
    ))
    or
    -- dm:<other_user_id>: auth får posta (teacher/admin också)
    (exists(select 1 from kind where k='dm') and p_sender = auth.uid());
$$;

-- 3) Meditations-katalog -----------------------------------------------------
-- Lagra metadata + storage path för meditationer (audio) per lärare
create table if not exists app.meditations (
  id uuid primary key default uuid_generate_v4(),
  teacher_id uuid not null references app.profiles(user_id) on delete cascade,
  title text not null,
  description text,
  audio_path text not null, -- storage path i bucket 'media' (ex: meditations/<teacher_id>/<fil>.mp3)
  duration_seconds integer,
  is_public boolean not null default true,
  created_at timestamptz not null default now()
);
create index if not exists idx_meditations_teacher on app.meditations(teacher_id);

alter table app.meditations enable row level security;

-- RLS: Läs publika + ägarens; skriv endast ägaren eller admin/teacher
drop policy if exists "med_read" on app.meditations;
create policy "med_read" on app.meditations for select
using (is_public = true or teacher_id = auth.uid() or app.is_teacher());

drop policy if exists "med_write_owner" on app.meditations;
create policy "med_write_owner" on app.meditations for all
using (teacher_id = auth.uid() or app.is_teacher())
with check (teacher_id = auth.uid() or app.is_teacher());

commit;

-- Notering:
-- Lagra filer i bucket 'media' under
--   meditations/<teacher_id>/<filnamn>.mp3
-- Publik åtkomst styrs via storage-policys (se tidigare migrationer).

-- 4) Order-start för tjänster -------------------------------------------------
create or replace function app.start_service_order(
  p_service_id uuid,
  p_amount_cents integer,
  p_currency text default 'sek',
  p_metadata jsonb default '{}'::jsonb
) returns app.orders language plpgsql security definer as $$
declare v_user uuid := auth.uid(); v_order app.orders;
begin
  if v_user is null then raise exception 'Not authenticated'; end if;
  insert into app.orders(user_id, service_id, amount_cents, currency, status, metadata)
  values (v_user, p_service_id, p_amount_cents, coalesce(p_currency,'sek'), 'pending', p_metadata)
  returning * into v_order;
  return v_order;
end; $$;

-- 5) Profil-hjälpare (RPC) för att undvika schema-header vid login -----------
create or replace function app.ensure_profile(
  p_email text default null,
  p_display_name text default null
) returns app.profiles language plpgsql security definer as $$
declare v_user uuid := auth.uid(); v_row app.profiles; v_mail text; v_name text;
begin
  if v_user is null then raise exception 'Not authenticated'; end if;
  select email into v_mail from auth.users where id = v_user;
  v_mail := coalesce(p_email, v_mail);
  v_name := coalesce(p_display_name, split_part(coalesce(v_mail,''),'@',1));
  insert into app.profiles(user_id, email, display_name)
  values (v_user, v_mail, coalesce(v_name, 'Användare'))
  on conflict (user_id)
  do update set email = excluded.email,
                display_name = coalesce(excluded.display_name, app.profiles.display_name),
                updated_at = now()
  returning * into v_row;
  return v_row;
end; $$;

create or replace function app.get_my_profile()
returns app.profiles language sql security definer as $$
  select * from app.profiles where user_id = auth.uid();
$$;

-- 6) Grants: schema- och funktions-åtkomst (förhindrar 42501)
grant usage on schema app to anon, authenticated;

-- Tabell/sekvens-privilegier (RLS begränsar faktiska rader)
grant select, insert, update, delete on all tables in schema app to anon, authenticated;
grant usage, select on all sequences in schema app to anon, authenticated;

-- Default privileges för framtida objekt
alter default privileges in schema app grant select, insert, update, delete on tables to anon, authenticated;
alter default privileges in schema app grant usage, select on sequences to anon, authenticated;

-- EXECUTE på använda RPC:er
grant execute on function app.ensure_profile(text, text) to anon, authenticated;
grant execute on function app.get_my_profile() to anon, authenticated;
grant execute on function app.start_service_order(uuid, integer, text, jsonb) to authenticated;
grant execute on function app.start_order(uuid, integer, text, jsonb) to authenticated;
grant execute on function app.free_consumed_count() to authenticated;
grant execute on function app.can_access_course(uuid) to authenticated;
