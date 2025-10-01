-- Phase A — Purchases & Claim Tokens (idempotent)
-- Creates app.purchases + app.guest_claim_tokens and supporting helpers.

begin;

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

alter table app.purchases enable row level security;

drop policy if exists "purchases_owner_select" on app.purchases;
create policy "purchases_owner_select" on app.purchases for select
  using (auth.uid() = user_id);

-- Insert/update handled via service-role (bypasses RLS).

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

alter table app.guest_claim_tokens enable row level security;
-- No direct access; mutations go through RPC.
revoke all on app.guest_claim_tokens from authenticated, anon;

-- Claim helper RPC ---------------------------------------------------------
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

-- Access helper ------------------------------------------------------------
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

create or replace function app.can_access_course(p_course uuid)
returns boolean
language sql stable
as $$
  select app.can_access_course(auth.uid(), p_course);
$$;

commit;
