-- =====================================================================
-- Visdom • Social Platform (idempotent)
-- Schema: app (PostgreSQL 15)
-- Features: posts, follows, reviews, notifications, meditations (+ RLS),
--           RPC follow/unfollow, get_my_profile, ensure_profile.
-- =====================================================================

begin;

-- 0) Baseline references (assumes app.profiles/services/orders/messages exist)
-- Ensure orders has service_id FK + index (harmless if already applied elsewhere)
alter table app.orders add column if not exists service_id uuid;
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

-- 1) Posts ------------------------------------------------------------------
create table if not exists app.posts (
  id uuid primary key default uuid_generate_v4(),
  author_id uuid not null references app.profiles(user_id) on delete cascade,
  content text not null check (char_length(content) between 1 and 2000),
  media_paths text[],
  created_at timestamptz not null default now()
);
create index if not exists idx_posts_author on app.posts(author_id);
alter table app.posts enable row level security;

drop policy if exists "posts_read_all" on app.posts;
create policy "posts_read_all" on app.posts for select using (true);

drop policy if exists "posts_insert_owner_or_teacher" on app.posts;
create policy "posts_insert_owner_or_teacher" on app.posts for insert
with check (author_id = auth.uid() or app.is_teacher());

drop policy if exists "posts_update_owner_or_teacher" on app.posts;
create policy "posts_update_owner_or_teacher" on app.posts for update
using (author_id = auth.uid() or app.is_teacher());

drop policy if exists "posts_delete_owner_or_teacher" on app.posts;
create policy "posts_delete_owner_or_teacher" on app.posts for delete
using (author_id = auth.uid() or app.is_teacher());

-- 2) Follows ----------------------------------------------------------------
create table if not exists app.follows (
  follower_id uuid not null references app.profiles(user_id) on delete cascade,
  followee_id uuid not null references app.profiles(user_id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_id, followee_id),
  check (follower_id <> followee_id)
);
alter table app.follows enable row level security;

drop policy if exists "follows_read_all" on app.follows;
create policy "follows_read_all" on app.follows for select using (true);

drop policy if exists "follows_write_owner" on app.follows;
create policy "follows_write_owner" on app.follows for all
using (follower_id = auth.uid())
with check (follower_id = auth.uid());

-- 3) Reviews ----------------------------------------------------------------
create table if not exists app.reviews (
  id uuid primary key default uuid_generate_v4(),
  service_id uuid not null references app.services(id) on delete cascade,
  reviewer_id uuid not null references app.profiles(user_id) on delete cascade,
  rating int not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz not null default now(),
  unique (service_id, reviewer_id)
);
create index if not exists idx_reviews_service on app.reviews(service_id);
alter table app.reviews enable row level security;

drop policy if exists "reviews_read_all" on app.reviews;
create policy "reviews_read_all" on app.reviews for select using (true);

drop policy if exists "reviews_write_owner" on app.reviews;
create policy "reviews_write_owner" on app.reviews for insert
with check (reviewer_id = auth.uid());
-- TODO: Enforce paid order for reviewer via CHECK in trigger/RPC

drop policy if exists "reviews_update_delete_owner_or_teacher" on app.reviews;
create policy "reviews_update_delete_owner_or_teacher" on app.reviews for update
using (reviewer_id = auth.uid() or app.is_teacher());
create policy "reviews_delete_owner_or_teacher" on app.reviews for delete
using (reviewer_id = auth.uid() or app.is_teacher());

-- 4) Notifications ----------------------------------------------------------
create table if not exists app.notifications (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references app.profiles(user_id) on delete cascade,
  kind text not null check (kind in ('follow','order','message','review')),
  payload jsonb not null default '{}'::jsonb,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists idx_notifications_user on app.notifications(user_id);
alter table app.notifications enable row level security;

drop policy if exists "notif_read_owner" on app.notifications;
create policy "notif_read_owner" on app.notifications for select
using (user_id = auth.uid());

drop policy if exists "notif_insert_owner_or_teacher" on app.notifications;
create policy "notif_insert_owner_or_teacher" on app.notifications for insert
with check (user_id = auth.uid() or app.is_teacher());

drop policy if exists "notif_update_owner_or_teacher" on app.notifications;
create policy "notif_update_owner_or_teacher" on app.notifications for update
using (user_id = auth.uid() or app.is_teacher());

-- 5) Messages channel constraint (service:, dm:) ----------------------------
alter table app.messages drop constraint if exists messages_channel_format;
alter table app.messages
  add constraint messages_channel_format
  check (
    channel ~ '^(global|course:[0-9a-fA-F-]{36}|event:[0-9a-fA-F-]{36}|service:[0-9a-fA-F-]{36}|dm:[0-9a-fA-F-]{36})$'
  );

-- 6) Meditations (if missing) ----------------------------------------------
create table if not exists app.meditations (
  id uuid primary key default uuid_generate_v4(),
  teacher_id uuid not null references app.profiles(user_id) on delete cascade,
  title text not null,
  description text,
  audio_path text not null,
  duration_seconds int,
  is_public boolean not null default true,
  created_at timestamptz not null default now()
);
create index if not exists idx_meditations_teacher on app.meditations(teacher_id);
alter table app.meditations enable row level security;

drop policy if exists "med_read" on app.meditations;
create policy "med_read" on app.meditations for select
using (is_public = true or teacher_id = auth.uid() or app.is_teacher());

drop policy if exists "med_write_owner" on app.meditations;
create policy "med_write_owner" on app.meditations for all
using (teacher_id = auth.uid() or app.is_teacher())
with check (teacher_id = auth.uid() or app.is_teacher());

-- 7) RPCs -------------------------------------------------------------------
create or replace function app.get_my_profile()
returns app.profiles language sql security definer as $$
  select * from app.profiles where user_id = auth.uid();
$$;

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

create or replace function app.follow(p_user uuid)
returns void language plpgsql security definer as $$
declare v_user uuid := auth.uid();
begin
  if v_user is null then raise exception 'Not authenticated'; end if;
  if p_user is null or p_user = v_user then return; end if;
  insert into app.follows(follower_id, followee_id)
  values (v_user, p_user)
  on conflict do nothing;
end; $$;

create or replace function app.unfollow(p_user uuid)
returns void language plpgsql security definer as $$
declare v_user uuid := auth.uid();
begin
  if v_user is null then raise exception 'Not authenticated'; end if;
  delete from app.follows where follower_id = v_user and followee_id = p_user;
end; $$;

-- 8) Grants -----------------------------------------------------------------
grant usage on schema app to anon, authenticated;
grant select, insert, update, delete on all tables in schema app to anon, authenticated;
grant usage, select on all sequences in schema app to anon, authenticated;
alter default privileges in schema app grant select, insert, update, delete on tables to anon, authenticated;
alter default privileges in schema app grant usage, select on sequences to anon, authenticated;

grant execute on function app.get_my_profile() to anon, authenticated;
grant execute on function app.ensure_profile(text, text) to anon, authenticated;
grant execute on function app.follow(uuid) to authenticated;
grant execute on function app.unfollow(uuid) to authenticated;

commit;

