--
-- PostgreSQL database dump
--

\restrict cdlzQCxDBpGicOhH3GqnsdIkodSbiHPSijOzQ4U4g3mZICk9BRz3fZcmszKDzAO

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.6 (Ubuntu 17.6-2.pgdg24.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: app; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "app";


--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "auth";


--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "extensions";


--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "graphql";


--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "graphql_public";


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "pgbouncer";


--
-- Name: SCHEMA "public"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA "public" IS 'standard public schema';


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "realtime";


--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "storage";


--
-- Name: supabase_migrations; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "supabase_migrations";


--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "vault";


--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";


--
-- Name: EXTENSION "pg_graphql"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "pg_graphql" IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";


--
-- Name: EXTENSION "pg_stat_statements"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "pg_stat_statements" IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";


--
-- Name: EXTENSION "pgcrypto"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "pgcrypto" IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";


--
-- Name: EXTENSION "supabase_vault"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "supabase_vault" IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: channel; Type: TYPE; Schema: app; Owner: -
--

CREATE TYPE "app"."channel" AS ENUM (
    'push',
    'email',
    'in_app'
);


--
-- Name: drip_mode; Type: TYPE; Schema: app; Owner: -
--

CREATE TYPE "app"."drip_mode" AS ENUM (
    'relative',
    'absolute'
);


--
-- Name: enrollment_source; Type: TYPE; Schema: app; Owner: -
--

CREATE TYPE "app"."enrollment_source" AS ENUM (
    'free_intro',
    'purchase',
    'membership',
    'grant'
);


--
-- Name: magic_action; Type: TYPE; Schema: app; Owner: -
--

CREATE TYPE "app"."magic_action" AS ENUM (
    'open_url',
    'deep_link',
    'navigate_course',
    'start_meditation',
    'enroll_course'
);


--
-- Name: membership_plan; Type: TYPE; Schema: app; Owner: -
--

CREATE TYPE "app"."membership_plan" AS ENUM (
    'none',
    'basic',
    'pro',
    'lifetime'
);


--
-- Name: membership_status; Type: TYPE; Schema: app; Owner: -
--

CREATE TYPE "app"."membership_status" AS ENUM (
    'inactive',
    'active',
    'past_due',
    'canceled'
);


--
-- Name: order_status; Type: TYPE; Schema: app; Owner: -
--

CREATE TYPE "app"."order_status" AS ENUM (
    'pending',
    'requires_action',
    'paid',
    'canceled',
    'failed',
    'refunded'
);


--
-- Name: role_type; Type: TYPE; Schema: app; Owner: -
--

CREATE TYPE "app"."role_type" AS ENUM (
    'user',
    'member',
    'teacher',
    'admin'
);


--
-- Name: user_role; Type: TYPE; Schema: app; Owner: -
--

CREATE TYPE "app"."user_role" AS ENUM (
    'user',
    'professional',
    'teacher'
);


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE "auth"."aal_level" AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE "auth"."code_challenge_method" AS ENUM (
    's256',
    'plain'
);


--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE "auth"."factor_status" AS ENUM (
    'unverified',
    'verified'
);


--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE "auth"."factor_type" AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE "auth"."oauth_registration_type" AS ENUM (
    'dynamic',
    'manual'
);


--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE "auth"."one_time_token_type" AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


--
-- Name: app_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE "public"."app_role" AS ENUM (
    'student',
    'teacher',
    'admin'
);


--
-- Name: user_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE "public"."user_role" AS ENUM (
    'user',
    'teacher',
    'admin'
);


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE "realtime"."action" AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE "realtime"."equality_op" AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE "realtime"."user_defined_filter" AS (
	"column_name" "text",
	"op" "realtime"."equality_op",
	"value" "text"
);


--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE "realtime"."wal_column" AS (
	"name" "text",
	"type_name" "text",
	"type_oid" "oid",
	"value" "jsonb",
	"is_pkey" boolean,
	"is_selectable" boolean
);


--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE "realtime"."wal_rls" AS (
	"wal" "jsonb",
	"is_rls_enabled" boolean,
	"subscription_ids" "uuid"[],
	"errors" "text"[]
);


--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: -
--

CREATE TYPE "storage"."buckettype" AS ENUM (
    'STANDARD',
    'ANALYTICS'
);


--
-- Name: _courses_set_owner(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."_courses_set_owner"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  if new.created_by is null then
    new.created_by := auth.uid();
  end if;
  return new;
end$$;


--
-- Name: approve_teacher("uuid"); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."approve_teacher"("p_user" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  update app.profiles set role='teacher' where user_id = p_user;
  update app.teacher_requests
     set status='approved', reviewed_by = auth.uid(), updated_at = now()
   where user_id = p_user;
end; $$;


--
-- Name: can_access_course("uuid"); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."can_access_course"("p_course" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE
    AS $$
  select app.can_access_course(auth.uid(), p_course);
$$;


--
-- Name: can_access_course("uuid", "uuid"); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."can_access_course"("p_user" "uuid", "p_course" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE
    AS $$
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


--
-- Name: can_post_channel("text", "uuid"); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."can_post_channel"("p_channel" "text", "p_sender" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE
    AS $$
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


--
-- Name: can_read_channel("text"); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."can_read_channel"("p_channel" "text") RETURNS boolean
    LANGUAGE "sql" STABLE
    AS $$
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


--
-- Name: claim_purchase("uuid"); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."claim_purchase"("p_token" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'app', 'public'
    AS $$
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


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION "auth"."uid"() RETURNS "uuid"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


--
-- Name: FUNCTION "uid"(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION "auth"."uid"() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


SET default_tablespace = '';

SET default_table_access_method = "heap";

--
-- Name: orders; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."orders" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "course_id" "uuid",
    "amount_cents" integer NOT NULL,
    "currency" "text" DEFAULT 'sek'::"text" NOT NULL,
    "status" "app"."order_status" DEFAULT 'pending'::"app"."order_status" NOT NULL,
    "stripe_checkout_id" "text",
    "stripe_payment_intent" "text",
    "metadata" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "service_id" "uuid",
    "created_by" "uuid" DEFAULT "auth"."uid"() NOT NULL
);


--
-- Name: complete_order("uuid", "text", "text"); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."complete_order"("p_order_id" "uuid", "p_payment_intent" "text", "p_checkout_id" "text" DEFAULT NULL::"text") RETURNS "app"."orders"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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


--
-- Name: current_role(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."current_role"() RETURNS "app"."role_type"
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'app', 'public'
    AS $$
declare
  v_claim text;
  v_profile_role text;
  v_old_rowsec text;
begin
  v_claim := auth.jwt() -> 'app_metadata' ->> 'role';
  if v_claim in ('admin', 'teacher', 'user') then
    return v_claim::app.role_type;
  end if;

  if app.is_admin() then
    return 'admin';
  end if;
  if app.is_teacher() then
    return 'teacher';
  end if;

  if to_regclass('app.profiles') is not null then
    v_old_rowsec := coalesce(current_setting('row_security', true), 'on');
    perform set_config('row_security', 'off', true);
    begin
      select p.role_v2::text into v_profile_role
      from app.profiles p
      where p.user_id = auth.uid();
    exception
      when others then
        perform set_config('row_security', v_old_rowsec, true);
        raise;
    end;
    perform set_config('row_security', v_old_rowsec, true);
    if v_profile_role is not null then
      if v_profile_role = 'teacher' then
        return 'teacher';
      elsif v_profile_role = 'professional' then
        return 'user';
      else
        return 'user';
      end if;
    end if;
  end if;

  return 'user';
end;
$$;


--
-- Name: delete_user_data("uuid"); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."delete_user_data"("p_user" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  delete from app.messages where sender_id = p_user;
  delete from app.bookings where user_id = p_user;
  delete from app.tarot_requests where requester_id = p_user or reader_id = p_user;
  delete from app.services where provider_id = p_user;
  delete from app.events where created_by = p_user;
  delete from app.orders where user_id = p_user;
  delete from app.certifications where user_id = p_user;
  delete from app.enrollments where user_id = p_user;
  delete from app.memberships where user_id = p_user;
  delete from app.teacher_requests where user_id = p_user;
  delete from app.teacher_directory where user_id = p_user;
  delete from app.teacher_slots where teacher_id = p_user;
-- ---------- -1) App Config ----------
create table if not exists app.app_config (
  id integer primary key default 1,
  free_course_limit integer not null default 5,
  platform_fee_pct numeric not null default 10
);
alter table app.app_config enable row level security;
drop policy if exists "cfg_public_read" on app.app_config;
create policy "cfg_public_read" on app.app_config for select using (true);

insert into app.app_config(id)
select 1 where not exists (select 1 from app.app_config where id=1);

  delete from app.profiles where user_id = p_user;
  -- auth.users raderas via Supabase Auth Admin API
end; $$;


--
-- Name: enrollments_materialize_trg_fn(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."enrollments_materialize_trg_fn"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'app', 'public'
    AS $$
begin
  perform app.materialize_drip_jobs(new.user_id, new.course_id);
  return new;
end
$$;


--
-- Name: ensure_owner_policies("text"); Type: PROCEDURE; Schema: app; Owner: -
--

CREATE PROCEDURE "app"."ensure_owner_policies"(IN "p_table" "text")
    LANGUAGE "plpgsql"
    AS $_$
declare
  tbl text := p_table;
  has_course boolean;
  has_module boolean;
  has_user   boolean;
  sel_using  text;
  ins_check  text;
  v_owner    uuid := coalesce(auth.uid(), app.get_fallback_owner());
begin
  -- Add columns (nullable default for created_by)
  execute format('alter table app.%I add column if not exists created_by uuid default auth.uid()', tbl);
  execute format('alter table app.%I add column if not exists updated_at timestamptz not null default now()', tbl);

  -- Prefer backfill from parents
  has_course := app.has_column('app', tbl, 'course_id');
  has_module := app.has_column('app', tbl, 'module_id');
  has_user   := app.has_column('app', tbl, 'user_id');

  if has_course then
    execute format(
      'update app.%I t set created_by = c.created_by from app.courses c where t.course_id = c.id and t.created_by is null',
      tbl
    );
  elsif has_module then
    execute format(
      'update app.%I t set created_by = m.created_by from app.modules m where t.module_id = m.id and t.created_by is null',
      tbl
    );
  elsif has_user then
    execute format(
      'update app.%I t set created_by = p.user_id from app.profiles p where t.user_id = p.user_id and t.created_by is null',
      tbl
    );
  end if;

  -- Final backfill for any remaining NULLs (handles SQL Editor context)
  execute format('update app.%I set created_by = $1 where created_by is null', tbl) using v_owner;

  -- Enforce NOT NULL after backfill
  execute format('alter table app.%I alter column created_by set not null', tbl);

  -- Ensure updated_at trigger
  call app.ensure_touch_trigger('app', tbl, 'trg_'||tbl||'_touch');

  -- Rebuild RLS/policies
  execute format('alter table app.%I enable row level security', tbl);
  execute format('drop policy if exists "%I_select" on app.%I', tbl, tbl);
  execute format('drop policy if exists "%I_insert" on app.%I', tbl, tbl);
  execute format('drop policy if exists "%I_update" on app.%I', tbl, tbl);
  execute format('drop policy if exists "%I_delete" on app.%I', tbl, tbl);

  if has_course then
    sel_using := format(
      'created_by = auth.uid() or exists (select 1 from app.courses c where c.id = app.%I.course_id and coalesce(c.is_published,false) = true)',
      tbl
    );
    ins_check := format(
      'created_by = auth.uid() and exists (select 1 from app.courses c where c.id = app.%I.course_id and c.created_by = auth.uid())',
      tbl
    );
  else
    sel_using := 'created_by = auth.uid()';
    ins_check := 'created_by = auth.uid()';
  end if;

  execute format('create policy "%I_select" on app.%I for select using (%s)', tbl, tbl, sel_using);
  execute format('create policy "%I_insert" on app.%I for insert with check (%s)', tbl, tbl, ins_check);
  execute format('create policy "%I_update" on app.%I for update using (created_by = auth.uid()) with check (created_by = auth.uid())', tbl, tbl);
  execute format('create policy "%I_delete" on app.%I for delete using (created_by = auth.uid())', tbl, tbl);
end;
$_$;


--
-- Name: profiles; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."profiles" (
    "user_id" "uuid" NOT NULL,
    "email" "text",
    "display_name" "text",
    "bio" "text",
    "photo_url" "text",
    "role" "app"."role_type" DEFAULT 'user'::"app"."role_type" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "is_admin" boolean DEFAULT false NOT NULL,
    "role_v2" "app"."user_role" DEFAULT 'user'::"app"."user_role" NOT NULL
);


--
-- Name: ensure_profile("text", "text"); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."ensure_profile"("p_email" "text" DEFAULT NULL::"text", "p_display_name" "text" DEFAULT NULL::"text") RETURNS "app"."profiles"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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


--
-- Name: ensure_touch_trigger("text", "text", "text"); Type: PROCEDURE; Schema: app; Owner: -
--

CREATE PROCEDURE "app"."ensure_touch_trigger"(IN "p_schema" "text", IN "p_table" "text", IN "p_trigger" "text")
    LANGUAGE "plpgsql"
    AS $$
begin
  execute format('drop trigger if exists %I on %I.%I', p_trigger, p_schema, p_table);
  execute format('create trigger %I before update on %I.%I for each row execute function app.touch_updated_at()', p_trigger, p_schema, p_table);
end;
$$;


--
-- Name: export_user_data("uuid"); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."export_user_data"("p_user" "uuid" DEFAULT "auth"."uid"()) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare result jsonb;
begin
  if p_user is null then raise exception 'Not authenticated'; end if;

  result := jsonb_build_object(
    'profile',        (select row_to_json(p) from app.profiles p where p.user_id = p_user),
    'memberships',    (select jsonb_agg(m) from app.memberships m where m.user_id = p_user),
    'enrollments',    (select jsonb_agg(e) from app.enrollments e where e.user_id = p_user),
    'certifications', (select jsonb_agg(c) from app.certifications c where c.user_id = p_user),
    'orders',         (select jsonb_agg(o) from app.orders o where o.user_id = p_user),
    'events',         (select jsonb_agg(ev) from app.events ev where ev.created_by = p_user),
    'services',       (select jsonb_agg(s) from app.services s where s.provider_id = p_user),
    'bookings',       (select jsonb_agg(b) from app.bookings b where b.user_id = p_user),
    'tarot_requests', (select jsonb_agg(t) from app.tarot_requests t where t.requester_id = p_user or t.reader_id = p_user),
    'messages',       (select jsonb_agg(m) from app.messages m where m.sender_id = p_user)
  );

  return coalesce(result, '{}'::jsonb);
end; $$;


--
-- Name: free_consumed_count(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."free_consumed_count"() RETURNS integer
    LANGUAGE "sql" STABLE
    AS $$ select app.free_consumed_count(auth.uid()); $$;


--
-- Name: free_consumed_count("uuid"); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."free_consumed_count"("p_user" "uuid") RETURNS integer
    LANGUAGE "sql" STABLE
    AS $$
  select count(*)::int
  from app.enrollments e
  join app.courses c on c.id = e.course_id
  where e.user_id = p_user
    and e.source = 'free_intro'
    and c.is_free_intro = true;
$$;


--
-- Name: app_config; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."app_config" (
    "id" integer DEFAULT 1 NOT NULL,
    "free_course_limit" integer DEFAULT 5 NOT NULL,
    "platform_fee_pct" numeric DEFAULT 10 NOT NULL,
    "created_by" "uuid" DEFAULT "auth"."uid"()
);


--
-- Name: get_config(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."get_config"() RETURNS "app"."app_config"
    LANGUAGE "sql" STABLE
    AS $$
  select * from app.app_config where id=1
$$;


--
-- Name: get_fallback_owner(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."get_fallback_owner"() RETURNS "uuid"
    LANGUAGE "plpgsql" STABLE
    AS $$
declare
  v_admin uuid;
begin
  -- Prefer explicit admins
  select p.user_id into v_admin
  from app.profiles p
  where coalesce(p.is_admin,false) = true
  limit 1;

  -- Fallback: role_v2/role indicates admin/owner/superadmin
  if v_admin is null then
    select p.user_id into v_admin
    from app.profiles p
    where coalesce(p.role_v2, p.role) in ('admin','owner','superadmin')
    limit 1;
  end if;

  -- Last fallback: any existing profile
  if v_admin is null then
    select p.user_id into v_admin
    from app.profiles p
    order by p.user_id
    limit 1;
  end if;

  return v_admin;
end;
$$;


--
-- Name: get_my_profile(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."get_my_profile"() RETURNS "app"."profiles"
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  select * from app.profiles where user_id = auth.uid();
$$;


--
-- Name: grant_professional_if_ready("uuid"); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."grant_professional_if_ready"("p_user" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  req_count int;
  done_count int;
BEGIN
  SELECT COUNT(*) INTO req_count FROM app.pro_requirements;
  SELECT COUNT(*) INTO done_count FROM app.pro_progress WHERE user_id = p_user;

  IF done_count >= req_count AND req_count > 0 THEN
    UPDATE app.profiles
      SET role_v2 = CASE WHEN role_v2 = 'teacher' THEN role_v2 ELSE 'professional' END,
          updated_at = now()
    WHERE user_id = p_user;
  END IF;
END;
$$;


--
-- Name: handle_new_user(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  insert into app.profiles(user_id, email, display_name, role, created_at)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'full_name',''), 'user', coalesce(new.created_at, now()))
  on conflict (user_id) do nothing;
  return new;
end $$;


--
-- Name: has_column("text", "text", "text"); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."has_column"("p_schema" "text", "p_table" "text", "p_column" "text") RETURNS boolean
    LANGUAGE "sql" STABLE
    AS $$
  select exists (
    select 1 from information_schema.columns
    where table_schema = p_schema
      and table_name   = p_table
      and column_name  = p_column
  );
$$;


--
-- Name: is_admin(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."is_admin"() RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'app', 'public'
    AS $$
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


--
-- Name: is_admin("uuid"); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."is_admin"("u" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE
    AS $$
  select coalesce((select is_admin from app.profiles p where p.user_id = u), false);
$$;


--
-- Name: is_teacher(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."is_teacher"() RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'app', 'public'
    AS $$
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
                select 1
                from app.teacher_approvals ta
                where ta.user_id = p.user_id
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


--
-- Name: is_teacher_uid("uuid"); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."is_teacher_uid"("uid" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE
    AS $$
  select exists (
    select 1
    from app.profiles p
    where p.user_id = uid
      and p.role = 'teacher'
  );
$$;


--
-- Name: materialize_drip_jobs("uuid", "uuid"); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."materialize_drip_jobs"("p_user" "uuid", "p_course" "uuid") RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'app', 'public'
    AS $$
declare
  _count int := 0;
begin
  -- RELATIVE (offset från enrollments.created_at)
  insert into app.notification_jobs (user_id, course_id, module_id, page_id, scheduled_at, template_id, created_by)
  select e.user_id, p.course_id, r.module_id, r.page_id,
         (
           (date_trunc('day', coalesce(e.created_at, now()))::date)
           + make_interval(days => r.offset_days)
         )::timestamptz,
         r.notify_template_id, e.user_id
  from app.enrollments e
  join app.drip_plans p on p.course_id = e.course_id and p.mode = 'relative'
  join app.drip_rules r on r.plan_id = p.id
  where e.user_id = p_user and e.course_id = p_course
  on conflict do nothing;

  get diagnostics _count = row_count;

  -- ABSOLUTE (fast datum)
  insert into app.notification_jobs (user_id, course_id, module_id, page_id, scheduled_at, template_id, created_by)
  select p_user, p.course_id, r.module_id, r.page_id,
         r.release_at::timestamptz,
         r.notify_template_id, p_user
  from app.drip_plans p
  join app.drip_rules r on r.plan_id = p.id
  where p.course_id = p_course and p.mode = 'absolute'
  on conflict do nothing;

  get diagnostics _count = _count + row_count;
  return _count;
end
$$;


--
-- Name: null_created_by_report(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."null_created_by_report"() RETURNS TABLE("schema_name" "text", "table_name" "text", "null_count" bigint)
    LANGUAGE "plpgsql" STABLE
    AS $$
declare
  r record;
  q text;
begin
  for r in
    select t.table_schema, t.table_name
    from information_schema.tables t
    where t.table_schema = 'app' and t.table_type = 'BASE TABLE'
      and exists (
        select 1
        from information_schema.columns c
        where c.table_schema = t.table_schema
          and c.table_name   = t.table_name
          and c.column_name  = 'created_by'
      )
    order by t.table_name
  loop
    q := format('select %L::text, %L::text, count(*)::bigint from %I.%I where created_by is null',
                r.table_schema, r.table_name, r.table_schema, r.table_name);
    return query execute q;
  end loop;
end;
$$;


--
-- Name: owns_course("uuid"); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."owns_course"("_course_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE
    AS $$
  select exists(
    select 1
    from app.courses c
    where c.id = _course_id
      and (c.created_by = auth.uid() or app.is_admin(auth.uid()))
  );
$$;


--
-- Name: reject_teacher("uuid"); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."reject_teacher"("p_user" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  update app.teacher_requests
     set status='rejected', reviewed_by = auth.uid(), updated_at = now()
   where user_id = p_user;
end; $$;


--
-- Name: start_order("uuid", integer, "text", "jsonb"); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."start_order"("p_course_id" "uuid", "p_amount_cents" integer, "p_currency" "text" DEFAULT 'sek'::"text", "p_metadata" "jsonb" DEFAULT '{}'::"jsonb") RETURNS "app"."orders"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare v_user uuid := auth.uid(); v_order app.orders;
begin
  if v_user is null then raise exception 'Not authenticated'; end if;
  insert into app.orders(user_id, course_id, amount_cents, currency, status, metadata)
  values (v_user, p_course_id, p_amount_cents, coalesce(p_currency,'sek'), 'pending', p_metadata)
  returning * into v_order;
  return v_order;
end; $$;


--
-- Name: start_service_order("uuid", integer, "text", "jsonb"); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."start_service_order"("p_service_id" "uuid", "p_amount_cents" integer, "p_currency" "text" DEFAULT 'sek'::"text", "p_metadata" "jsonb" DEFAULT '{}'::"jsonb") RETURNS "app"."orders"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare v_user uuid := auth.uid(); v_order app.orders;
begin
  if v_user is null then raise exception 'Not authenticated'; end if;
  insert into app.orders(user_id, service_id, amount_cents, currency, status, metadata)
  values (v_user, p_service_id, p_amount_cents, coalesce(p_currency,'sek'), 'pending', p_metadata)
  returning * into v_order;
  return v_order;
end; $$;


--
-- Name: touch_updated_at(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."touch_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  new.updated_at := now();
  return new;
end;
$$;


--
-- Name: trigger_report(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION "app"."trigger_report"() RETURNS TABLE("schema_name" "text", "table_name" "text", "trigger_name" "text", "enabled_state" "text", "trigger_def" "text")
    LANGUAGE "sql" STABLE
    AS $$
  select
    n.nspname::text   as schema_name,
    c.relname::text   as table_name,
    t.tgname::text    as trigger_name,
    t.tgenabled::text as enabled_state,     -- 'O' = enabled, 'D' = disabled
    pg_get_triggerdef(t.oid) as trigger_def
  from pg_trigger t
  join pg_class    c on c.oid = t.tgrelid
  join pg_namespace n on n.oid = c.relnamespace
  where not t.tgisinternal
    and n.nspname in ('app','public')
  order by n.nspname, c.relname, t.tgname;
$$;


--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION "auth"."email"() RETURNS "text"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


--
-- Name: FUNCTION "email"(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION "auth"."email"() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION "auth"."jwt"() RETURNS "jsonb"
    LANGUAGE "sql" STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION "auth"."role"() RETURNS "text"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


--
-- Name: FUNCTION "role"(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION "auth"."role"() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION "extensions"."grant_pg_cron_access"() RETURNS "event_trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


--
-- Name: FUNCTION "grant_pg_cron_access"(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION "extensions"."grant_pg_cron_access"() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION "extensions"."grant_pg_graphql_access"() RETURNS "event_trigger"
    LANGUAGE "plpgsql"
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


--
-- Name: FUNCTION "grant_pg_graphql_access"(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION "extensions"."grant_pg_graphql_access"() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION "extensions"."grant_pg_net_access"() RETURNS "event_trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


--
-- Name: FUNCTION "grant_pg_net_access"(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION "extensions"."grant_pg_net_access"() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION "extensions"."pgrst_ddl_watch"() RETURNS "event_trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION "extensions"."pgrst_drop_watch"() RETURNS "event_trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION "extensions"."set_graphql_placeholder"() RETURNS "event_trigger"
    LANGUAGE "plpgsql"
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


--
-- Name: FUNCTION "set_graphql_placeholder"(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION "extensions"."set_graphql_placeholder"() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth("text"); Type: FUNCTION; Schema: pgbouncer; Owner: -
--

CREATE FUNCTION "pgbouncer"."get_auth"("p_usename" "text") RETURNS TABLE("username" "text", "password" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $_$
begin
    raise debug 'PgBouncer auth request: %', p_usename;

    return query
    select 
        rolname::text, 
        case when rolvaliduntil < now() 
            then null 
            else rolpassword::text 
        end 
    from pg_authid 
    where rolname=$1 and rolcanlogin;
end;
$_$;


--
-- Name: _next_period_end("text", integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "public"."_next_period_end"("p_interval" "text", "p_trial_days" integer) RETURNS timestamp with time zone
    LANGUAGE "sql" IMMUTABLE
    AS $$
  select case when p_interval='year'
    then now() + make_interval(years=>1, days=>p_trial_days)
    else now() + make_interval(months=>1, days=>p_trial_days)
  end;
$$;


--
-- Name: _set_created_by(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "public"."_set_created_by"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  if tg_op = 'INSERT' then
    if new.created_by is null then
      new.created_by := auth.uid();
    end if;
    new.updated_at := now();
  elsif tg_op = 'UPDATE' then
    new.updated_at := now();
  end if;
  return new;
end;
$$;


--
-- Name: grade_quiz_and_issue_certificate("uuid", "jsonb"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "public"."grade_quiz_and_issue_certificate"("p_quiz" "uuid", "p_answers" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  uid uuid := auth.uid();
  qz record;
  total int := 0;
  correct_count int := 0;
  pct int := 0;
  passed boolean := false;
  qs record;
  ans jsonb;
  norm_answer text;
  norm_correct text;
begin
  if uid is null then
    return jsonb_build_object('ok', false, 'reason', 'not_authenticated');
  end if;

  select * into qz from public.course_quizzes where id = p_quiz;
  if qz is null then
    return jsonb_build_object('ok', false, 'reason', 'quiz_not_found');
  end if;

  for qs in select * from public.quiz_questions where quiz_id = p_quiz order by position loop
    total := total + 1;
    -- fetch provided answer for this question id
    ans := coalesce(p_answers -> qs.id::text, 'null'::jsonb);

    if qs.kind = 'single' then
      norm_answer := coalesce(ans::text, '');
      norm_correct := coalesce(qs.correct::text, '');
      if norm_answer = norm_correct then
        correct_count := correct_count + 1;
      end if;
    elsif qs.kind = 'multi' then
      -- sort arrays and compare as comma-joined string
      norm_answer := coalesce((
        select string_agg(x, ',' order by x)
        from (
          select jsonb_array_elements_text(ans)
        ) s(x)
      ), '');

      norm_correct := coalesce((
        select string_agg(x, ',' order by x)
        from (
          select jsonb_array_elements_text(qs.correct)
        ) s(x)
      ), '');

      if norm_answer = norm_correct then
        correct_count := correct_count + 1;
      end if;
    elsif qs.kind = 'boolean' then
      norm_answer := lower(coalesce(ans::text, ''));
      norm_correct := lower(coalesce(qs.correct::text, ''));
      if norm_answer = norm_correct then
        correct_count := correct_count + 1;
      end if;
    else
      -- unknown kind -> treat as wrong
    end if;
  end loop;

  if total > 0 then
    pct := round((correct_count::numeric * 100.0) / total)::int;
  else
    pct := 0;
  end if;
  passed := (pct >= qz.pass_score);

  insert into public.quiz_attempts(quiz_id, user_id, answers, score, passed)
  values (p_quiz, uid, p_answers, pct, passed);

  if passed then
    insert into public.certificates(user_id, course_id, issued_at)
    values (uid, qz.course_id, now())
    on conflict (user_id, course_id) do update set issued_at = greatest(public.certificates.issued_at, excluded.issued_at);
  end if;

  return jsonb_build_object(
    'ok', true,
    'score', pct,
    'passed', passed,
    'total', total,
    'correct', correct_count
  );
end;
$$;


--
-- Name: handle_new_teacher(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "public"."handle_new_teacher"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  -- When a teacher role is assigned, create public teacher info from profile
  IF NEW.role = 'teacher'::app_role THEN
    INSERT INTO public.public_teacher_info (user_id, full_name, bio, avatar_url)
    SELECT user_id, full_name, bio, avatar_url
    FROM public.profiles
    WHERE user_id = NEW.user_id
    ON CONFLICT (user_id) DO UPDATE SET
      full_name = EXCLUDED.full_name,
      bio = EXCLUDED.bio,
      avatar_url = EXCLUDED.avatar_url,
      updated_at = now();
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name',''));
  return new;
end;
$$;


--
-- Name: has_role("uuid", "public"."app_role"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "public"."has_role"("_user_id" "uuid", "_role" "public"."app_role") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id
      AND role = _role
  )
$$;


--
-- Name: is_teacher(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "public"."is_teacher"() RETURNS boolean
    LANGUAGE "sql" STABLE
    AS $$
  select coalesce((auth.jwt() -> 'app_metadata' ->> 'role') in ('teacher','admin'), false)
$$;


--
-- Name: preview_coupon("uuid", "text"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "public"."preview_coupon"("p_plan" "uuid", "p_code" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare v_plan public.subscription_plans; v_coupon public.coupons; v_valid boolean:=false; v_pay int:=0;
begin
  select * into v_plan from public.subscription_plans where id=p_plan and is_active=true limit 1;
  if not found then return jsonb_build_object('valid',false,'reason','plan_not_found','pay_amount_cents',null); end if;
  v_pay := v_plan.price_cents;
  if p_code is null or length(trim(p_code))=0 then return jsonb_build_object('valid',false,'pay_amount_cents',v_pay); end if;
  select * into v_coupon from public.coupons
    where code=p_code and is_enabled=true
      and (expires_at is null or expires_at>now())
      and (max_redemptions is null or redeemed_count<max_redemptions)
      and (plan_id is null or plan_id=p_plan)
    limit 1;
  if found then v_valid:=true; v_pay:=0; end if;
  return jsonb_build_object('valid',v_valid,'pay_amount_cents',v_pay,'grants',coalesce(v_coupon.grants,'{}'::jsonb));
end; $$;


--
-- Name: redeem_coupon_and_provision("uuid", "text"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "public"."redeem_coupon_and_provision"("p_plan" "uuid", "p_code" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare uid uuid:=auth.uid(); v_plan public.subscription_plans; v_coupon public.coupons;
        v_period_end timestamptz; v_role text; v_teacher boolean; v_area text;
begin
  if uid is null then raise exception 'Not authenticated'; end if;
  select * into v_plan from public.subscription_plans where id=p_plan and is_active=true limit 1;
  if not found then return jsonb_build_object('ok',false,'reason','plan_not_found'); end if;

  select * into v_coupon from public.coupons where code=p_code for update;
  if not found or v_coupon.is_enabled=false
     or (v_coupon.expires_at is not null and v_coupon.expires_at<=now())
     or (v_coupon.max_redemptions is not null and v_coupon.redeemed_count>=v_coupon.max_redemptions)
     or (v_coupon.plan_id is not null and v_coupon.plan_id<>p_plan)
  then return jsonb_build_object('ok',false,'reason','invalid_coupon'); end if;

  update public.coupons set redeemed_count=redeemed_count+1 where code=v_coupon.code;

  update public.subscriptions set status='canceled' where user_id=uid and status='active';

  v_period_end := public._next_period_end(v_plan.interval, v_plan.trial_days);
  insert into public.subscriptions(user_id,plan_id,status,amount_cents,current_period_end)
  values(uid,v_plan.id,'active',0,v_period_end);

  v_role := coalesce(v_coupon.grants->>'role',null);
  v_teacher := coalesce((v_coupon.grants->>'teacher')::boolean,false);
  if v_role is not null then
    update auth.users set raw_app_meta_data = coalesce(raw_app_meta_data,'{}'::jsonb) || jsonb_build_object('role',v_role) where id=uid;
  end if;
  if v_teacher then insert into public.teacher_permissions(user_id) values(uid) on conflict(user_id) do nothing; end if;

  if (v_coupon.grants ? 'certified_areas') then
    for v_area in select jsonb_array_elements_text(v_coupon.grants->'certified_areas') loop
      insert into public.user_certifications(user_id,area) values(uid,v_area) on conflict(user_id,area) do nothing;
    end loop;
  end if;

  return jsonb_build_object('ok',true,'period_end',v_period_end);
end; $$;


--
-- Name: redeem_key("text"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "public"."redeem_key"("p_code" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare uid uuid:=auth.uid(); k record;
begin
  if uid is null then raise exception 'Not authenticated'; end if;
  select * into k from public.admin_keys where code=p_code and redeemed_by is null limit 1;
  if not found then return jsonb_build_object('ok',false); end if;
  update public.admin_keys set redeemed_by=uid, redeemed_at=now() where code=p_code;
  return jsonb_build_object('ok',true);
end; $$;


--
-- Name: set_created_by(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "public"."set_created_by"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  if new.created_by is null then
    new.created_by := auth.uid();
  end if;
  return new;
end;
$$;


--
-- Name: set_owner(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "public"."set_owner"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  if new.owner is null then
    new.owner := auth.uid();
  end if;
  return new;
end;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


--
-- Name: user_is_teacher(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "public"."user_is_teacher"() RETURNS boolean
    LANGUAGE "plpgsql" STABLE
    SET "search_path" TO 'public'
    AS $$
declare
  has_tp boolean;
  has_profile_id boolean;
  has_user_id boolean;
  has_can_edit boolean;
  sql text;
  allowed boolean := false;
begin
  -- If JWT role says teacher/admin -> true
  if public.is_teacher() then
    return true;
  end if;

  -- Fallback to teacher_permissions table presence
  select to_regclass('public.teacher_permissions') is not null into has_tp;
  if not has_tp then
    return false;
  end if;

  select exists(
    select 1 from information_schema.columns
    where table_schema='public' and table_name='teacher_permissions' and column_name='profile_id'
  ) into has_profile_id;

  select exists(
    select 1 from information_schema.columns
    where table_schema='public' and table_name='teacher_permissions' and column_name='user_id'
  ) into has_user_id;

  select exists(
    select 1 from information_schema.columns
    where table_schema='public' and table_name='teacher_permissions' and column_name='can_edit_courses'
  ) into has_can_edit;

  if has_profile_id then
    sql := 'select exists(select 1 from public.teacher_permissions where profile_id = auth.uid()';
  elsif has_user_id then
    sql := 'select exists(select 1 from public.teacher_permissions where user_id = auth.uid()';
  else
    return false;
  end if;

  if has_can_edit then
    sql := sql || ' and can_edit_courses = true)';
  else
    sql := sql || ')';
  end if;

  execute sql into allowed;
  return coalesce(allowed, false);
end;
$$;


--
-- Name: apply_rls("jsonb", integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."apply_rls"("wal" "jsonb", "max_record_bytes" integer DEFAULT (1024 * 1024)) RETURNS SETOF "realtime"."wal_rls"
    LANGUAGE "plpgsql"
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_;

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


--
-- Name: broadcast_changes("text", "text", "text", "text", "text", "record", "record", "text"); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."broadcast_changes"("topic_name" "text", "event_name" "text", "operation" "text", "table_name" "text", "table_schema" "text", "new" "record", "old" "record", "level" "text" DEFAULT 'ROW'::"text") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


--
-- Name: build_prepared_statement_sql("text", "regclass", "realtime"."wal_column"[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."build_prepared_statement_sql"("prepared_statement_name" "text", "entity" "regclass", "columns" "realtime"."wal_column"[]) RETURNS "text"
    LANGUAGE "sql"
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


--
-- Name: cast("text", "regtype"); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."cast"("val" "text", "type_" "regtype") RETURNS "jsonb"
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


--
-- Name: check_equality_op("realtime"."equality_op", "regtype", "text", "text"); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."check_equality_op"("op" "realtime"."equality_op", "type_" "regtype", "val_1" "text", "val_2" "text") RETURNS boolean
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


--
-- Name: is_visible_through_filters("realtime"."wal_column"[], "realtime"."user_defined_filter"[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."is_visible_through_filters"("columns" "realtime"."wal_column"[], "filters" "realtime"."user_defined_filter"[]) RETURNS boolean
    LANGUAGE "sql" IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


--
-- Name: list_changes("name", "name", integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."list_changes"("publication" "name", "slot_name" "name", "max_changes" integer, "max_record_bytes" integer) RETURNS SETOF "realtime"."wal_rls"
    LANGUAGE "sql"
    SET "log_min_messages" TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


--
-- Name: quote_wal2json("regclass"); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."quote_wal2json"("entity" "regclass") RETURNS "text"
    LANGUAGE "sql" IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


--
-- Name: send("jsonb", "text", "text", boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."send"("payload" "jsonb", "event" "text", "topic" "text", "private" boolean DEFAULT true) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  BEGIN
    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (payload, event, topic, private, extension)
    VALUES (payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."subscription_check_filters"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


--
-- Name: to_regrole("text"); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."to_regrole"("role_name" "text") RETURNS "regrole"
    LANGUAGE "sql" IMMUTABLE
    AS $$ select role_name::regrole $$;


--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."topic"() RETURNS "text"
    LANGUAGE "sql" STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


--
-- Name: add_prefixes("text", "text"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."add_prefixes"("_bucket_id" "text", "_name" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    prefixes text[];
BEGIN
    prefixes := "storage"."get_prefixes"("_name");

    IF array_length(prefixes, 1) > 0 THEN
        INSERT INTO storage.prefixes (name, bucket_id)
        SELECT UNNEST(prefixes) as name, "_bucket_id" ON CONFLICT DO NOTHING;
    END IF;
END;
$$;


--
-- Name: can_insert_object("text", "text", "uuid", "jsonb"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."can_insert_object"("bucketid" "text", "name" "text", "owner" "uuid", "metadata" "jsonb") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


--
-- Name: delete_leaf_prefixes("text"[], "text"[]); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."delete_leaf_prefixes"("bucket_ids" "text"[], "names" "text"[]) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_rows_deleted integer;
BEGIN
    LOOP
        WITH candidates AS (
            SELECT DISTINCT
                t.bucket_id,
                unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        ),
        uniq AS (
             SELECT
                 bucket_id,
                 name,
                 storage.get_level(name) AS level
             FROM candidates
             WHERE name <> ''
             GROUP BY bucket_id, name
        ),
        leaf AS (
             SELECT
                 p.bucket_id,
                 p.name,
                 p.level
             FROM storage.prefixes AS p
                  JOIN uniq AS u
                       ON u.bucket_id = p.bucket_id
                           AND u.name = p.name
                           AND u.level = p.level
             WHERE NOT EXISTS (
                 SELECT 1
                 FROM storage.objects AS o
                 WHERE o.bucket_id = p.bucket_id
                   AND o.level = p.level + 1
                   AND o.name COLLATE "C" LIKE p.name || '/%'
             )
             AND NOT EXISTS (
                 SELECT 1
                 FROM storage.prefixes AS c
                 WHERE c.bucket_id = p.bucket_id
                   AND c.level = p.level + 1
                   AND c.name COLLATE "C" LIKE p.name || '/%'
             )
        )
        DELETE
        FROM storage.prefixes AS p
            USING leaf AS l
        WHERE p.bucket_id = l.bucket_id
          AND p.name = l.name
          AND p.level = l.level;

        GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;
        EXIT WHEN v_rows_deleted = 0;
    END LOOP;
END;
$$;


--
-- Name: delete_prefix("text", "text"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."delete_prefix"("_bucket_id" "text", "_name" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Check if we can delete the prefix
    IF EXISTS(
        SELECT FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name") + 1
          AND "prefixes"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    )
    OR EXISTS(
        SELECT FROM "storage"."objects"
        WHERE "objects"."bucket_id" = "_bucket_id"
          AND "storage"."get_level"("objects"."name") = "storage"."get_level"("_name") + 1
          AND "objects"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    ) THEN
    -- There are sub-objects, skip deletion
    RETURN false;
    ELSE
        DELETE FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name")
          AND "prefixes"."name" = "_name";
        RETURN true;
    END IF;
END;
$$;


--
-- Name: delete_prefix_hierarchy_trigger(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."delete_prefix_hierarchy_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    prefix text;
BEGIN
    prefix := "storage"."get_prefix"(OLD."name");

    IF coalesce(prefix, '') != '' THEN
        PERFORM "storage"."delete_prefix"(OLD."bucket_id", prefix);
    END IF;

    RETURN OLD;
END;
$$;


--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."enforce_bucket_name_length"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


--
-- Name: extension("text"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."extension"("name" "text") RETURNS "text"
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    SELECT _parts[array_length(_parts,1)] INTO _filename;
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


--
-- Name: filename("text"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."filename"("name" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


--
-- Name: foldername("text"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."foldername"("name" "text") RETURNS "text"[]
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


--
-- Name: get_level("text"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."get_level"("name" "text") RETURNS integer
    LANGUAGE "sql" IMMUTABLE STRICT
    AS $$
SELECT array_length(string_to_array("name", '/'), 1);
$$;


--
-- Name: get_prefix("text"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."get_prefix"("name" "text") RETURNS "text"
    LANGUAGE "sql" IMMUTABLE STRICT
    AS $_$
SELECT
    CASE WHEN strpos("name", '/') > 0 THEN
             regexp_replace("name", '[\/]{1}[^\/]+\/?$', '')
         ELSE
             ''
        END;
$_$;


--
-- Name: get_prefixes("text"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."get_prefixes"("name" "text") RETURNS "text"[]
    LANGUAGE "plpgsql" IMMUTABLE STRICT
    AS $$
DECLARE
    parts text[];
    prefixes text[];
    prefix text;
BEGIN
    -- Split the name into parts by '/'
    parts := string_to_array("name", '/');
    prefixes := '{}';

    -- Construct the prefixes, stopping one level below the last part
    FOR i IN 1..array_length(parts, 1) - 1 LOOP
            prefix := array_to_string(parts[1:i], '/');
            prefixes := array_append(prefixes, prefix);
    END LOOP;

    RETURN prefixes;
END;
$$;


--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."get_size_by_bucket"() RETURNS TABLE("size" bigint, "bucket_id" "text")
    LANGUAGE "plpgsql" STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


--
-- Name: list_multipart_uploads_with_delimiter("text", "text", "text", integer, "text", "text"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."list_multipart_uploads_with_delimiter"("bucket_id" "text", "prefix_param" "text", "delimiter_param" "text", "max_keys" integer DEFAULT 100, "next_key_token" "text" DEFAULT ''::"text", "next_upload_token" "text" DEFAULT ''::"text") RETURNS TABLE("key" "text", "id" "text", "created_at" timestamp with time zone)
    LANGUAGE "plpgsql"
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


--
-- Name: list_objects_with_delimiter("text", "text", "text", integer, "text", "text"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."list_objects_with_delimiter"("bucket_id" "text", "prefix_param" "text", "delimiter_param" "text", "max_keys" integer DEFAULT 100, "start_after" "text" DEFAULT ''::"text", "next_token" "text" DEFAULT ''::"text") RETURNS TABLE("name" "text", "id" "uuid", "metadata" "jsonb", "updated_at" timestamp with time zone)
    LANGUAGE "plpgsql"
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


--
-- Name: lock_top_prefixes("text"[], "text"[]); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."lock_top_prefixes"("bucket_ids" "text"[], "names" "text"[]) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_bucket text;
    v_top text;
BEGIN
    FOR v_bucket, v_top IN
        SELECT DISTINCT t.bucket_id,
            split_part(t.name, '/', 1) AS top
        FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        WHERE t.name <> ''
        ORDER BY 1, 2
        LOOP
            PERFORM pg_advisory_xact_lock(hashtextextended(v_bucket || '/' || v_top, 0));
        END LOOP;
END;
$$;


--
-- Name: objects_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."objects_delete_cleanup"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


--
-- Name: objects_insert_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."objects_insert_prefix_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    NEW.level := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


--
-- Name: objects_update_cleanup(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."objects_update_cleanup"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    -- NEW - OLD (destinations to create prefixes for)
    v_add_bucket_ids text[];
    v_add_names      text[];

    -- OLD - NEW (sources to prune)
    v_src_bucket_ids text[];
    v_src_names      text[];
BEGIN
    IF TG_OP <> 'UPDATE' THEN
        RETURN NULL;
    END IF;

    -- 1) Compute NEW−OLD (added paths) and OLD−NEW (moved-away paths)
    WITH added AS (
        SELECT n.bucket_id, n.name
        FROM new_rows n
        WHERE n.name <> '' AND position('/' in n.name) > 0
        EXCEPT
        SELECT o.bucket_id, o.name FROM old_rows o WHERE o.name <> ''
    ),
    moved AS (
         SELECT o.bucket_id, o.name
         FROM old_rows o
         WHERE o.name <> ''
         EXCEPT
         SELECT n.bucket_id, n.name FROM new_rows n WHERE n.name <> ''
    )
    SELECT
        -- arrays for ADDED (dest) in stable order
        COALESCE( (SELECT array_agg(a.bucket_id ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        COALESCE( (SELECT array_agg(a.name      ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        -- arrays for MOVED (src) in stable order
        COALESCE( (SELECT array_agg(m.bucket_id ORDER BY m.bucket_id, m.name) FROM moved m), '{}' ),
        COALESCE( (SELECT array_agg(m.name      ORDER BY m.bucket_id, m.name) FROM moved m), '{}' )
    INTO v_add_bucket_ids, v_add_names, v_src_bucket_ids, v_src_names;

    -- Nothing to do?
    IF (array_length(v_add_bucket_ids, 1) IS NULL) AND (array_length(v_src_bucket_ids, 1) IS NULL) THEN
        RETURN NULL;
    END IF;

    -- 2) Take per-(bucket, top) locks: ALL prefixes in consistent global order to prevent deadlocks
    DECLARE
        v_all_bucket_ids text[];
        v_all_names text[];
    BEGIN
        -- Combine source and destination arrays for consistent lock ordering
        v_all_bucket_ids := COALESCE(v_src_bucket_ids, '{}') || COALESCE(v_add_bucket_ids, '{}');
        v_all_names := COALESCE(v_src_names, '{}') || COALESCE(v_add_names, '{}');

        -- Single lock call ensures consistent global ordering across all transactions
        IF array_length(v_all_bucket_ids, 1) IS NOT NULL THEN
            PERFORM storage.lock_top_prefixes(v_all_bucket_ids, v_all_names);
        END IF;
    END;

    -- 3) Create destination prefixes (NEW−OLD) BEFORE pruning sources
    IF array_length(v_add_bucket_ids, 1) IS NOT NULL THEN
        WITH candidates AS (
            SELECT DISTINCT t.bucket_id, unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(v_add_bucket_ids, v_add_names) AS t(bucket_id, name)
            WHERE name <> ''
        )
        INSERT INTO storage.prefixes (bucket_id, name)
        SELECT c.bucket_id, c.name
        FROM candidates c
        ON CONFLICT DO NOTHING;
    END IF;

    -- 4) Prune source prefixes bottom-up for OLD−NEW
    IF array_length(v_src_bucket_ids, 1) IS NOT NULL THEN
        -- re-entrancy guard so DELETE on prefixes won't recurse
        IF current_setting('storage.gc.prefixes', true) <> '1' THEN
            PERFORM set_config('storage.gc.prefixes', '1', true);
        END IF;

        PERFORM storage.delete_leaf_prefixes(v_src_bucket_ids, v_src_names);
    END IF;

    RETURN NULL;
END;
$$;


--
-- Name: objects_update_level_trigger(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."objects_update_level_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Set the new level
        NEW."level" := "storage"."get_level"(NEW."name");
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: objects_update_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."objects_update_prefix_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    old_prefixes TEXT[];
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Retrieve old prefixes
        old_prefixes := "storage"."get_prefixes"(OLD."name");

        -- Remove old prefixes that are only used by this object
        WITH all_prefixes as (
            SELECT unnest(old_prefixes) as prefix
        ),
        can_delete_prefixes as (
             SELECT prefix
             FROM all_prefixes
             WHERE NOT EXISTS (
                 SELECT 1 FROM "storage"."objects"
                 WHERE "bucket_id" = OLD."bucket_id"
                   AND "name" <> OLD."name"
                   AND "name" LIKE (prefix || '%')
             )
         )
        DELETE FROM "storage"."prefixes" WHERE name IN (SELECT prefix FROM can_delete_prefixes);

        -- Add new prefixes
        PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    END IF;
    -- Set the new level
    NEW."level" := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."operation"() RETURNS "text"
    LANGUAGE "plpgsql" STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


--
-- Name: prefixes_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."prefixes_delete_cleanup"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


--
-- Name: prefixes_insert_trigger(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."prefixes_insert_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    RETURN NEW;
END;
$$;


--
-- Name: search("text", "text", integer, integer, integer, "text", "text", "text"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."search"("prefix" "text", "bucketname" "text", "limits" integer DEFAULT 100, "levels" integer DEFAULT 1, "offsets" integer DEFAULT 0, "search" "text" DEFAULT ''::"text", "sortcolumn" "text" DEFAULT 'name'::"text", "sortorder" "text" DEFAULT 'asc'::"text") RETURNS TABLE("name" "text", "id" "uuid", "updated_at" timestamp with time zone, "created_at" timestamp with time zone, "last_accessed_at" timestamp with time zone, "metadata" "jsonb")
    LANGUAGE "plpgsql"
    AS $$
declare
    can_bypass_rls BOOLEAN;
begin
    SELECT rolbypassrls
    INTO can_bypass_rls
    FROM pg_roles
    WHERE rolname = coalesce(nullif(current_setting('role', true), 'none'), current_user);

    IF can_bypass_rls THEN
        RETURN QUERY SELECT * FROM storage.search_v1_optimised(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    ELSE
        RETURN QUERY SELECT * FROM storage.search_legacy_v1(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    END IF;
end;
$$;


--
-- Name: search_legacy_v1("text", "text", integer, integer, integer, "text", "text", "text"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."search_legacy_v1"("prefix" "text", "bucketname" "text", "limits" integer DEFAULT 100, "levels" integer DEFAULT 1, "offsets" integer DEFAULT 0, "search" "text" DEFAULT ''::"text", "sortcolumn" "text" DEFAULT 'name'::"text", "sortorder" "text" DEFAULT 'asc'::"text") RETURNS TABLE("name" "text", "id" "uuid", "updated_at" timestamp with time zone, "created_at" timestamp with time zone, "last_accessed_at" timestamp with time zone, "metadata" "jsonb")
    LANGUAGE "plpgsql" STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select path_tokens[$1] as folder
           from storage.objects
             where objects.name ilike $2 || $3 || ''%''
               and bucket_id = $4
               and array_length(objects.path_tokens, 1) <> $1
           group by folder
           order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


--
-- Name: search_v1_optimised("text", "text", integer, integer, integer, "text", "text", "text"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."search_v1_optimised"("prefix" "text", "bucketname" "text", "limits" integer DEFAULT 100, "levels" integer DEFAULT 1, "offsets" integer DEFAULT 0, "search" "text" DEFAULT ''::"text", "sortcolumn" "text" DEFAULT 'name'::"text", "sortorder" "text" DEFAULT 'asc'::"text") RETURNS TABLE("name" "text", "id" "uuid", "updated_at" timestamp with time zone, "created_at" timestamp with time zone, "last_accessed_at" timestamp with time zone, "metadata" "jsonb")
    LANGUAGE "plpgsql" STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select (string_to_array(name, ''/''))[level] as name
           from storage.prefixes
             where lower(prefixes.name) like lower($2 || $3) || ''%''
               and bucket_id = $4
               and level = $1
           order by name ' || v_sort_order || '
     )
     (select name,
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[level] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where lower(objects.name) like lower($2 || $3) || ''%''
       and bucket_id = $4
       and level = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


--
-- Name: search_v2("text", "text", integer, integer, "text", "text", "text", "text"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."search_v2"("prefix" "text", "bucket_name" "text", "limits" integer DEFAULT 100, "levels" integer DEFAULT 1, "start_after" "text" DEFAULT ''::"text", "sort_order" "text" DEFAULT 'asc'::"text", "sort_column" "text" DEFAULT 'name'::"text", "sort_column_after" "text" DEFAULT ''::"text") RETURNS TABLE("key" "text", "name" "text", "id" "uuid", "updated_at" timestamp with time zone, "created_at" timestamp with time zone, "last_accessed_at" timestamp with time zone, "metadata" "jsonb")
    LANGUAGE "plpgsql" STABLE
    AS $_$
DECLARE
    sort_col text;
    sort_ord text;
    cursor_op text;
    cursor_expr text;
    sort_expr text;
BEGIN
    -- Validate sort_order
    sort_ord := lower(sort_order);
    IF sort_ord NOT IN ('asc', 'desc') THEN
        sort_ord := 'asc';
    END IF;

    -- Determine cursor comparison operator
    IF sort_ord = 'asc' THEN
        cursor_op := '>';
    ELSE
        cursor_op := '<';
    END IF;
    
    sort_col := lower(sort_column);
    -- Validate sort column  
    IF sort_col IN ('updated_at', 'created_at') THEN
        cursor_expr := format(
            '($5 = '''' OR ROW(date_trunc(''milliseconds'', %I), name COLLATE "C") %s ROW(COALESCE(NULLIF($6, '''')::timestamptz, ''epoch''::timestamptz), $5))',
            sort_col, cursor_op
        );
        sort_expr := format(
            'COALESCE(date_trunc(''milliseconds'', %I), ''epoch''::timestamptz) %s, name COLLATE "C" %s',
            sort_col, sort_ord, sort_ord
        );
    ELSE
        cursor_expr := format('($5 = '''' OR name COLLATE "C" %s $5)', cursor_op);
        sort_expr := format('name COLLATE "C" %s', sort_ord);
    END IF;

    RETURN QUERY EXECUTE format(
        $sql$
        SELECT * FROM (
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    NULL::uuid AS id,
                    updated_at,
                    created_at,
                    NULL::timestamptz AS last_accessed_at,
                    NULL::jsonb AS metadata
                FROM storage.prefixes
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
            UNION ALL
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    id,
                    updated_at,
                    created_at,
                    last_accessed_at,
                    metadata
                FROM storage.objects
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
        ) obj
        ORDER BY %s
        LIMIT $3
        $sql$,
        cursor_expr,    -- prefixes WHERE
        sort_expr,      -- prefixes ORDER BY
        cursor_expr,    -- objects WHERE
        sort_expr,      -- objects ORDER BY
        sort_expr       -- final ORDER BY
    )
    USING prefix, bucket_name, limits, levels, start_after, sort_column_after;
END;
$_$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


--
-- Name: bookings; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."bookings" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "slot_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "order_id" "uuid",
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "bookings_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'confirmed'::"text", 'canceled'::"text", 'completed'::"text"])))
);


--
-- Name: certificates; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."certificates" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "evidence_url" "text",
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid" DEFAULT "auth"."uid"() NOT NULL
);


--
-- Name: certifications; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."certifications" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "course_id" "uuid" NOT NULL,
    "issued_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: courses; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."courses" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "slug" "text" NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "cover_url" "text",
    "is_free_intro" boolean DEFAULT false NOT NULL,
    "price_cents" integer DEFAULT 0 NOT NULL,
    "is_published" boolean DEFAULT false NOT NULL,
    "created_by" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "intro_video_url" "text",
    "video_url" "text",
    "branch" "text"
);


--
-- Name: drip_plans; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."drip_plans" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "course_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "mode" "app"."drip_mode" DEFAULT 'relative'::"app"."drip_mode" NOT NULL,
    "start_at" "date",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" NOT NULL
);


--
-- Name: drip_rules; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."drip_rules" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "plan_id" "uuid" NOT NULL,
    "module_id" "uuid" NOT NULL,
    "page_id" "uuid",
    "offset_days" integer,
    "release_at" "date",
    "notify_template_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" NOT NULL,
    CONSTRAINT "drip_rules_offset_or_date" CHECK (((("offset_days" IS NOT NULL) AND ("release_at" IS NULL)) OR (("offset_days" IS NULL) AND ("release_at" IS NOT NULL))))
);


--
-- Name: editor_styles; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."editor_styles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "course_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "font_family" "text" DEFAULT 'System'::"text" NOT NULL,
    "base_font_size" integer DEFAULT 16 NOT NULL,
    "color_primary" "text" DEFAULT '#6C5CE7'::"text" NOT NULL,
    "color_accent" "text" DEFAULT '#A66BFF'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" NOT NULL
);


--
-- Name: enrollments; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."enrollments" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "course_id" "uuid" NOT NULL,
    "source" "app"."enrollment_source" DEFAULT 'purchase'::"app"."enrollment_source" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: events; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."events" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_by" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "starts_at" timestamp with time zone NOT NULL,
    "ends_at" timestamp with time zone,
    "location" "text",
    "is_published" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: guest_claim_tokens; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."guest_claim_tokens" (
    "token" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "buyer_email" "text" NOT NULL,
    "course_id" "uuid" NOT NULL,
    "purchase_id" "uuid" NOT NULL,
    "used" boolean DEFAULT false NOT NULL,
    "expires_at" timestamp with time zone DEFAULT ("now"() + '14 days'::interval) NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: lesson_media; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."lesson_media" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "lesson_id" "uuid" NOT NULL,
    "kind" "text" NOT NULL,
    "storage_path" "text" NOT NULL,
    "duration_seconds" integer,
    "position" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "lesson_media_kind_check" CHECK (("kind" = ANY (ARRAY['video'::"text", 'audio'::"text", 'image'::"text", 'pdf'::"text", 'other'::"text"])))
);


--
-- Name: lessons; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."lessons" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "module_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "content_markdown" "text",
    "is_intro" boolean DEFAULT false NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: magic_links; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."magic_links" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "course_id" "uuid" NOT NULL,
    "label" "text" NOT NULL,
    "action" "app"."magic_action" NOT NULL,
    "payload" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "style_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" NOT NULL
);


--
-- Name: meditations; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."meditations" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "teacher_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "audio_path" "text" NOT NULL,
    "duration_seconds" integer,
    "is_public" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: memberships; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."memberships" (
    "user_id" "uuid" NOT NULL,
    "plan" "app"."membership_plan" DEFAULT 'none'::"app"."membership_plan" NOT NULL,
    "status" "app"."membership_status" DEFAULT 'inactive'::"app"."membership_status" NOT NULL,
    "current_period_end" timestamp with time zone,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" DEFAULT "auth"."uid"() NOT NULL
);


--
-- Name: messages; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."messages" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "channel" "text" NOT NULL,
    "sender_id" "uuid" NOT NULL,
    "content" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "messages_channel_format" CHECK (("channel" ~ '^(global|course:[0-9a-fA-F-]{36}|event:[0-9a-fA-F-]{36}|service:[0-9a-fA-F-]{36}|dm:[0-9a-fA-F-]{36})$'::"text")),
    CONSTRAINT "messages_content_len" CHECK ((("char_length"("content") >= 1) AND ("char_length"("content") <= 4000)))
);


--
-- Name: modules; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."modules" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "course_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: notification_jobs; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."notification_jobs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "course_id" "uuid" NOT NULL,
    "module_id" "uuid" NOT NULL,
    "page_id" "uuid",
    "scheduled_at" timestamp with time zone NOT NULL,
    "template_id" "uuid",
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" NOT NULL
);


--
-- Name: notification_templates; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."notification_templates" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "course_id" "uuid" NOT NULL,
    "template_key" "text" NOT NULL,
    "locale" "text" DEFAULT 'sv-SE'::"text" NOT NULL,
    "title" "text" NOT NULL,
    "body" "text" NOT NULL,
    "channel" "app"."channel" DEFAULT 'push'::"app"."channel" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" NOT NULL
);


--
-- Name: pro_progress; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."pro_progress" (
    "user_id" "uuid" NOT NULL,
    "requirement_id" integer NOT NULL,
    "completed_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: pro_requirements; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."pro_requirements" (
    "id" integer NOT NULL,
    "code" "text" NOT NULL,
    "title" "text" NOT NULL,
    "created_by" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: pro_requirements_id_seq; Type: SEQUENCE; Schema: app; Owner: -
--

CREATE SEQUENCE "app"."pro_requirements_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pro_requirements_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: -
--

ALTER SEQUENCE "app"."pro_requirements_id_seq" OWNED BY "app"."pro_requirements"."id";


--
-- Name: purchases; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."purchases" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "order_id" "uuid",
    "user_id" "uuid",
    "buyer_email" "text" NOT NULL,
    "course_id" "uuid" NOT NULL,
    "stripe_checkout_id" "text",
    "stripe_payment_intent" "text",
    "status" "text" DEFAULT 'succeeded'::"text" NOT NULL,
    "amount_cents" integer,
    "currency" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "purchases_status_check" CHECK (("status" = ANY (ARRAY['succeeded'::"text", 'refunded'::"text", 'failed'::"text", 'pending'::"text"])))
);


--
-- Name: services; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."services" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "provider_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "price_cents" integer DEFAULT 0 NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: tarot_requests; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."tarot_requests" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "requester_id" "uuid" NOT NULL,
    "reader_id" "uuid",
    "question" "text" NOT NULL,
    "status" "text" DEFAULT 'open'::"text" NOT NULL,
    "order_id" "uuid",
    "deliverable_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    CONSTRAINT "tarot_requests_status_check" CHECK (("status" = ANY (ARRAY['open'::"text", 'in_progress'::"text", 'delivered'::"text", 'canceled'::"text"])))
);


--
-- Name: teacher_approvals; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."teacher_approvals" (
    "user_id" "uuid" NOT NULL,
    "approved_by" "uuid",
    "approved_at" timestamp with time zone,
    "created_by" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: teacher_directory; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."teacher_directory" (
    "user_id" "uuid" NOT NULL,
    "headline" "text",
    "specialties" "text"[],
    "rating" numeric(3,2),
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: teacher_permissions; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."teacher_permissions" (
    "profile_id" "uuid" NOT NULL,
    "can_edit_courses" boolean DEFAULT false NOT NULL,
    "can_publish" boolean DEFAULT false NOT NULL,
    "granted_by" "uuid",
    "granted_at" timestamp with time zone
);

ALTER TABLE ONLY "app"."teacher_permissions" FORCE ROW LEVEL SECURITY;


--
-- Name: TABLE "teacher_permissions"; Type: COMMENT; Schema: app; Owner: -
--

COMMENT ON TABLE "app"."teacher_permissions" IS 'Canonical teacher permissions; one row per profile_id (FK to app.profiles.user_id).';


--
-- Name: teacher_requests; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."teacher_requests" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "message" "text",
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "reviewed_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "teacher_requests_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'approved'::"text", 'rejected'::"text"])))
);


--
-- Name: teacher_slots; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE "app"."teacher_slots" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "teacher_id" "uuid" NOT NULL,
    "starts_at" timestamp with time zone NOT NULL,
    "ends_at" timestamp with time zone NOT NULL,
    "is_booked" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."audit_log_entries" (
    "instance_id" "uuid",
    "id" "uuid" NOT NULL,
    "payload" json,
    "created_at" timestamp with time zone,
    "ip_address" character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE "audit_log_entries"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."audit_log_entries" IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."flow_state" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid",
    "auth_code" "text" NOT NULL,
    "code_challenge_method" "auth"."code_challenge_method" NOT NULL,
    "code_challenge" "text" NOT NULL,
    "provider_type" "text" NOT NULL,
    "provider_access_token" "text",
    "provider_refresh_token" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "authentication_method" "text" NOT NULL,
    "auth_code_issued_at" timestamp with time zone
);


--
-- Name: TABLE "flow_state"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."flow_state" IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."identities" (
    "provider_id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "identity_data" "jsonb" NOT NULL,
    "provider" "text" NOT NULL,
    "last_sign_in_at" timestamp with time zone,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "email" "text" GENERATED ALWAYS AS ("lower"(("identity_data" ->> 'email'::"text"))) STORED,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


--
-- Name: TABLE "identities"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."identities" IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN "identities"."email"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN "auth"."identities"."email" IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."instances" (
    "id" "uuid" NOT NULL,
    "uuid" "uuid",
    "raw_base_config" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


--
-- Name: TABLE "instances"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."instances" IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."mfa_amr_claims" (
    "session_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "updated_at" timestamp with time zone NOT NULL,
    "authentication_method" "text" NOT NULL,
    "id" "uuid" NOT NULL
);


--
-- Name: TABLE "mfa_amr_claims"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."mfa_amr_claims" IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."mfa_challenges" (
    "id" "uuid" NOT NULL,
    "factor_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "verified_at" timestamp with time zone,
    "ip_address" "inet" NOT NULL,
    "otp_code" "text",
    "web_authn_session_data" "jsonb"
);


--
-- Name: TABLE "mfa_challenges"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."mfa_challenges" IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."mfa_factors" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "friendly_name" "text",
    "factor_type" "auth"."factor_type" NOT NULL,
    "status" "auth"."factor_status" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "updated_at" timestamp with time zone NOT NULL,
    "secret" "text",
    "phone" "text",
    "last_challenged_at" timestamp with time zone,
    "web_authn_credential" "jsonb",
    "web_authn_aaguid" "uuid"
);


--
-- Name: TABLE "mfa_factors"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."mfa_factors" IS 'auth: stores metadata about factors';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."oauth_clients" (
    "id" "uuid" NOT NULL,
    "client_id" "text" NOT NULL,
    "client_secret_hash" "text" NOT NULL,
    "registration_type" "auth"."oauth_registration_type" NOT NULL,
    "redirect_uris" "text" NOT NULL,
    "grant_types" "text" NOT NULL,
    "client_name" "text",
    "client_uri" "text",
    "logo_uri" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "deleted_at" timestamp with time zone,
    CONSTRAINT "oauth_clients_client_name_length" CHECK (("char_length"("client_name") <= 1024)),
    CONSTRAINT "oauth_clients_client_uri_length" CHECK (("char_length"("client_uri") <= 2048)),
    CONSTRAINT "oauth_clients_logo_uri_length" CHECK (("char_length"("logo_uri") <= 2048))
);


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."one_time_tokens" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "token_type" "auth"."one_time_token_type" NOT NULL,
    "token_hash" "text" NOT NULL,
    "relates_to" "text" NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "one_time_tokens_token_hash_check" CHECK (("char_length"("token_hash") > 0))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."refresh_tokens" (
    "instance_id" "uuid",
    "id" bigint NOT NULL,
    "token" character varying(255),
    "user_id" character varying(255),
    "revoked" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "parent" character varying(255),
    "session_id" "uuid"
);


--
-- Name: TABLE "refresh_tokens"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."refresh_tokens" IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

CREATE SEQUENCE "auth"."refresh_tokens_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: -
--

ALTER SEQUENCE "auth"."refresh_tokens_id_seq" OWNED BY "auth"."refresh_tokens"."id";


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."saml_providers" (
    "id" "uuid" NOT NULL,
    "sso_provider_id" "uuid" NOT NULL,
    "entity_id" "text" NOT NULL,
    "metadata_xml" "text" NOT NULL,
    "metadata_url" "text",
    "attribute_mapping" "jsonb",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "name_id_format" "text",
    CONSTRAINT "entity_id not empty" CHECK (("char_length"("entity_id") > 0)),
    CONSTRAINT "metadata_url not empty" CHECK ((("metadata_url" = NULL::"text") OR ("char_length"("metadata_url") > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK (("char_length"("metadata_xml") > 0))
);


--
-- Name: TABLE "saml_providers"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."saml_providers" IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."saml_relay_states" (
    "id" "uuid" NOT NULL,
    "sso_provider_id" "uuid" NOT NULL,
    "request_id" "text" NOT NULL,
    "for_email" "text",
    "redirect_to" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "flow_state_id" "uuid",
    CONSTRAINT "request_id not empty" CHECK (("char_length"("request_id") > 0))
);


--
-- Name: TABLE "saml_relay_states"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."saml_relay_states" IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."schema_migrations" (
    "version" character varying(255) NOT NULL
);


--
-- Name: TABLE "schema_migrations"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."schema_migrations" IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."sessions" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "factor_id" "uuid",
    "aal" "auth"."aal_level",
    "not_after" timestamp with time zone,
    "refreshed_at" timestamp without time zone,
    "user_agent" "text",
    "ip" "inet",
    "tag" "text"
);


--
-- Name: TABLE "sessions"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."sessions" IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN "sessions"."not_after"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN "auth"."sessions"."not_after" IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."sso_domains" (
    "id" "uuid" NOT NULL,
    "sso_provider_id" "uuid" NOT NULL,
    "domain" "text" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK (("char_length"("domain") > 0))
);


--
-- Name: TABLE "sso_domains"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."sso_domains" IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."sso_providers" (
    "id" "uuid" NOT NULL,
    "resource_id" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "disabled" boolean,
    CONSTRAINT "resource_id not empty" CHECK ((("resource_id" = NULL::"text") OR ("char_length"("resource_id") > 0)))
);


--
-- Name: TABLE "sso_providers"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."sso_providers" IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN "sso_providers"."resource_id"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN "auth"."sso_providers"."resource_id" IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."users" (
    "instance_id" "uuid",
    "id" "uuid" NOT NULL,
    "aud" character varying(255),
    "role" character varying(255),
    "email" character varying(255),
    "encrypted_password" character varying(255),
    "email_confirmed_at" timestamp with time zone,
    "invited_at" timestamp with time zone,
    "confirmation_token" character varying(255),
    "confirmation_sent_at" timestamp with time zone,
    "recovery_token" character varying(255),
    "recovery_sent_at" timestamp with time zone,
    "email_change_token_new" character varying(255),
    "email_change" character varying(255),
    "email_change_sent_at" timestamp with time zone,
    "last_sign_in_at" timestamp with time zone,
    "raw_app_meta_data" "jsonb",
    "raw_user_meta_data" "jsonb",
    "is_super_admin" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "phone" "text" DEFAULT NULL::character varying,
    "phone_confirmed_at" timestamp with time zone,
    "phone_change" "text" DEFAULT ''::character varying,
    "phone_change_token" character varying(255) DEFAULT ''::character varying,
    "phone_change_sent_at" timestamp with time zone,
    "confirmed_at" timestamp with time zone GENERATED ALWAYS AS (LEAST("email_confirmed_at", "phone_confirmed_at")) STORED,
    "email_change_token_current" character varying(255) DEFAULT ''::character varying,
    "email_change_confirm_status" smallint DEFAULT 0,
    "banned_until" timestamp with time zone,
    "reauthentication_token" character varying(255) DEFAULT ''::character varying,
    "reauthentication_sent_at" timestamp with time zone,
    "is_sso_user" boolean DEFAULT false NOT NULL,
    "deleted_at" timestamp with time zone,
    "is_anonymous" boolean DEFAULT false NOT NULL,
    CONSTRAINT "users_email_change_confirm_status_check" CHECK ((("email_change_confirm_status" >= 0) AND ("email_change_confirm_status" <= 2)))
);


--
-- Name: TABLE "users"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."users" IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN "users"."is_sso_user"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN "auth"."users"."is_sso_user" IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: admin_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."admin_keys" (
    "code" "text" NOT NULL,
    "issued_by" "uuid",
    "issued_at" timestamp with time zone DEFAULT "now"(),
    "redeemed_by" "uuid",
    "redeemed_at" timestamp with time zone
);


--
-- Name: availability_slots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."availability_slots" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "teacher_id" "uuid" NOT NULL,
    "start_time" timestamp with time zone NOT NULL,
    "end_time" timestamp with time zone NOT NULL,
    "price" integer NOT NULL,
    "duration_minutes" integer DEFAULT 60 NOT NULL,
    "is_booked" boolean DEFAULT false NOT NULL,
    "title" "text",
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."bookings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "student_id" "uuid" NOT NULL,
    "teacher_id" "uuid" NOT NULL,
    "slot_id" "uuid" NOT NULL,
    "status" "text" DEFAULT 'confirmed'::"text" NOT NULL,
    "payment_status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "stripe_payment_intent_id" "text",
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "bookings_payment_status_check" CHECK (("payment_status" = ANY (ARRAY['pending'::"text", 'paid'::"text", 'refunded'::"text"]))),
    CONSTRAINT "bookings_status_check" CHECK (("status" = ANY (ARRAY['confirmed'::"text", 'cancelled'::"text", 'completed'::"text", 'rescheduled'::"text"])))
);


--
-- Name: certificates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."certificates" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "course_id" "uuid" NOT NULL,
    "issued_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: coupons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."coupons" (
    "code" "text" NOT NULL,
    "plan_id" "uuid",
    "grants" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "max_redemptions" integer DEFAULT 1 NOT NULL,
    "redeemed_count" integer DEFAULT 0 NOT NULL,
    "expires_at" timestamp with time zone,
    "is_enabled" boolean DEFAULT true NOT NULL,
    "issued_by" "uuid",
    "issued_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: course_enrollments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."course_enrollments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "course_id" "uuid" NOT NULL,
    "student_id" "uuid" NOT NULL,
    "enrolled_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "status" "text" DEFAULT 'active'::"text" NOT NULL
);


--
-- Name: course_modules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."course_modules" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "course_id" "uuid" NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    "type" "text" NOT NULL,
    "title" "text",
    "body" "text",
    "media_url" "text",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    CONSTRAINT "course_modules_type_check" CHECK (("type" = ANY (ARRAY['text'::"text", 'video'::"text", 'audio'::"text", 'image'::"text", 'quiz'::"text"])))
);


--
-- Name: course_quizzes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."course_quizzes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "course_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "pass_score" integer DEFAULT 80 NOT NULL,
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: courses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."courses" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "teacher_id" "uuid",
    "title" "text" NOT NULL,
    "description" "text",
    "price" integer,
    "is_published" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "branch" "text",
    "cover_url" "text",
    "price_cents" integer DEFAULT 0,
    "is_free_intro" boolean DEFAULT false,
    "slug" "text",
    "is_free" boolean DEFAULT false NOT NULL,
    "is_intro" boolean DEFAULT false NOT NULL,
    "created_by" "uuid"
);


--
-- Name: lesson_media; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."lesson_media" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "lesson_id" "uuid" NOT NULL,
    "type" "text" NOT NULL,
    "storage_path" "text" NOT NULL,
    "is_public" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: lessons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."lessons" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "module_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "index" integer DEFAULT 0 NOT NULL,
    "content" "jsonb" DEFAULT '{}'::"jsonb",
    "free_preview" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."messages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "sender_id" "uuid" NOT NULL,
    "recipient_id" "uuid",
    "course_id" "uuid",
    "content" "text" NOT NULL,
    "is_read" boolean DEFAULT false NOT NULL,
    "parent_message_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "message_type_check" CHECK (((("recipient_id" IS NOT NULL) AND ("course_id" IS NULL)) OR (("recipient_id" IS NULL) AND ("course_id" IS NOT NULL))))
);


--
-- Name: modules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."modules" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "course_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "index" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."notifications" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "type" "text" NOT NULL,
    "title" "text" NOT NULL,
    "message" "text" NOT NULL,
    "is_read" boolean DEFAULT false NOT NULL,
    "metadata" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "notifications_type_check" CHECK (("type" = ANY (ARRAY['message'::"text", 'booking'::"text", 'tarot_reading'::"text", 'course_update'::"text", 'payment'::"text"])))
);


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."profiles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "email" "text",
    "full_name" "text",
    "avatar_url" "text",
    "bio" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "role" "public"."user_role" DEFAULT 'user'::"public"."user_role"
);


--
-- Name: public_teacher_info; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."public_teacher_info" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "full_name" "text",
    "bio" "text",
    "avatar_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: quiz_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."quiz_attempts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "quiz_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "answers" "jsonb" NOT NULL,
    "score" integer NOT NULL,
    "passed" boolean NOT NULL,
    "submitted_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: quiz_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."quiz_questions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "quiz_id" "uuid" NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    "kind" "text" NOT NULL,
    "prompt" "text" NOT NULL,
    "options" "jsonb",
    "correct" "jsonb" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "quiz_questions_kind_check" CHECK (("kind" = ANY (ARRAY['single'::"text", 'multi'::"text", 'boolean'::"text"])))
);


--
-- Name: services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."services" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "owner" "uuid",
    "title" "text" NOT NULL,
    "description" "text",
    "certified_area" "text",
    "price_cents" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"()
);


--
-- Name: subscription_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."subscription_plans" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "price_cents" integer NOT NULL,
    "interval" "text" NOT NULL,
    "trial_days" integer DEFAULT 0 NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "subscription_plans_interval_check" CHECK (("interval" = ANY (ARRAY['month'::"text", 'year'::"text"]))),
    CONSTRAINT "subscription_plans_price_cents_check" CHECK (("price_cents" >= 0))
);


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."subscriptions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "plan_id" "uuid",
    "status" "text" DEFAULT 'active'::"text" NOT NULL,
    "amount_cents" integer DEFAULT 0 NOT NULL,
    "current_period_end" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "subscriptions_status_check" CHECK (("status" = ANY (ARRAY['active'::"text", 'canceled'::"text", 'incomplete'::"text", 'past_due'::"text"])))
);


--
-- Name: tarot_readings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."tarot_readings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "student_id" "uuid" NOT NULL,
    "teacher_id" "uuid",
    "question" "text" NOT NULL,
    "delivery_type" "text" NOT NULL,
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "price" integer NOT NULL,
    "payment_status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "stripe_payment_intent_id" "text",
    "response_text" "text",
    "response_audio_url" "text",
    "response_video_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "tarot_readings_delivery_type_check" CHECK (("delivery_type" = ANY (ARRAY['text'::"text", 'voice'::"text", 'video'::"text"]))),
    CONSTRAINT "tarot_readings_payment_status_check" CHECK (("payment_status" = ANY (ARRAY['pending'::"text", 'paid'::"text", 'refunded'::"text"]))),
    CONSTRAINT "tarot_readings_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'in_progress'::"text", 'delivered'::"text", 'cancelled'::"text"])))
);


--
-- Name: teacher_directory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."teacher_directory" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "display_name" "text",
    "headline" "text",
    "specialties" "text"[] DEFAULT '{}'::"text"[],
    "price_cents" integer DEFAULT 0,
    "avatar_url" "text",
    "is_accepting" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: teacher_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."teacher_permissions" (
    "user_id" "uuid" NOT NULL,
    "granted_by" "uuid",
    "granted_at" timestamp with time zone DEFAULT "now"()
);


--
-- Name: teacher_permissions_compat; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW "public"."teacher_permissions_compat" WITH ("security_invoker"='true', "security_barrier"='true') AS
 SELECT "profile_id",
    "profile_id" AS "user_id",
    "can_edit_courses",
    "can_publish",
    "granted_by",
    "granted_at"
   FROM "app"."teacher_permissions" "tp";


--
-- Name: teacher_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."teacher_requests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "note" "text",
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: user_certifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."user_certifications" (
    "user_id" "uuid" NOT NULL,
    "area" "text" NOT NULL,
    "granted_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."user_roles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "role" "public"."app_role" DEFAULT 'student'::"public"."app_role" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE "realtime"."messages" (
    "topic" "text" NOT NULL,
    "extension" "text" NOT NULL,
    "payload" "jsonb",
    "event" "text",
    "private" boolean DEFAULT false,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "inserted_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
)
PARTITION BY RANGE ("inserted_at");


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE "realtime"."schema_migrations" (
    "version" bigint NOT NULL,
    "inserted_at" timestamp(0) without time zone
);


--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE "realtime"."subscription" (
    "id" bigint NOT NULL,
    "subscription_id" "uuid" NOT NULL,
    "entity" "regclass" NOT NULL,
    "filters" "realtime"."user_defined_filter"[] DEFAULT '{}'::"realtime"."user_defined_filter"[] NOT NULL,
    "claims" "jsonb" NOT NULL,
    "claims_role" "regrole" GENERATED ALWAYS AS ("realtime"."to_regrole"(("claims" ->> 'role'::"text"))) STORED NOT NULL,
    "created_at" timestamp without time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

ALTER TABLE "realtime"."subscription" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "realtime"."subscription_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE "storage"."buckets" (
    "id" "text" NOT NULL,
    "name" "text" NOT NULL,
    "owner" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "public" boolean DEFAULT false,
    "avif_autodetection" boolean DEFAULT false,
    "file_size_limit" bigint,
    "allowed_mime_types" "text"[],
    "owner_id" "text",
    "type" "storage"."buckettype" DEFAULT 'STANDARD'::"storage"."buckettype" NOT NULL
);


--
-- Name: COLUMN "buckets"."owner"; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN "storage"."buckets"."owner" IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE "storage"."buckets_analytics" (
    "id" "text" NOT NULL,
    "type" "storage"."buckettype" DEFAULT 'ANALYTICS'::"storage"."buckettype" NOT NULL,
    "format" "text" DEFAULT 'ICEBERG'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE "storage"."migrations" (
    "id" integer NOT NULL,
    "name" character varying(100) NOT NULL,
    "hash" character varying(40) NOT NULL,
    "executed_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: objects; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE "storage"."objects" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "bucket_id" "text",
    "name" "text",
    "owner" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "last_accessed_at" timestamp with time zone DEFAULT "now"(),
    "metadata" "jsonb",
    "path_tokens" "text"[] GENERATED ALWAYS AS ("string_to_array"("name", '/'::"text")) STORED,
    "version" "text",
    "owner_id" "text",
    "user_metadata" "jsonb",
    "level" integer
);


--
-- Name: COLUMN "objects"."owner"; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN "storage"."objects"."owner" IS 'Field is deprecated, use owner_id instead';


--
-- Name: prefixes; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE "storage"."prefixes" (
    "bucket_id" "text" NOT NULL,
    "name" "text" NOT NULL COLLATE "pg_catalog"."C",
    "level" integer GENERATED ALWAYS AS ("storage"."get_level"("name")) STORED NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE "storage"."s3_multipart_uploads" (
    "id" "text" NOT NULL,
    "in_progress_size" bigint DEFAULT 0 NOT NULL,
    "upload_signature" "text" NOT NULL,
    "bucket_id" "text" NOT NULL,
    "key" "text" NOT NULL COLLATE "pg_catalog"."C",
    "version" "text" NOT NULL,
    "owner_id" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_metadata" "jsonb"
);


--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE "storage"."s3_multipart_uploads_parts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "upload_id" "text" NOT NULL,
    "size" bigint DEFAULT 0 NOT NULL,
    "part_number" integer NOT NULL,
    "bucket_id" "text" NOT NULL,
    "key" "text" NOT NULL COLLATE "pg_catalog"."C",
    "etag" "text" NOT NULL,
    "owner_id" "text",
    "version" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: supabase_migrations; Owner: -
--

CREATE TABLE "supabase_migrations"."schema_migrations" (
    "version" "text" NOT NULL,
    "statements" "text"[],
    "name" "text",
    "created_by" "text",
    "idempotency_key" "text"
);


--
-- Name: seed_files; Type: TABLE; Schema: supabase_migrations; Owner: -
--

CREATE TABLE "supabase_migrations"."seed_files" (
    "path" "text" NOT NULL,
    "hash" "text" NOT NULL
);


--
-- Name: pro_requirements id; Type: DEFAULT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."pro_requirements" ALTER COLUMN "id" SET DEFAULT "nextval"('"app"."pro_requirements_id_seq"'::"regclass");


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."refresh_tokens" ALTER COLUMN "id" SET DEFAULT "nextval"('"auth"."refresh_tokens_id_seq"'::"regclass");


--
-- Name: app_config app_config_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."app_config"
    ADD CONSTRAINT "app_config_pkey" PRIMARY KEY ("id");


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."bookings"
    ADD CONSTRAINT "bookings_pkey" PRIMARY KEY ("id");


--
-- Name: bookings bookings_slot_id_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."bookings"
    ADD CONSTRAINT "bookings_slot_id_key" UNIQUE ("slot_id");


--
-- Name: certificates certificates_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."certificates"
    ADD CONSTRAINT "certificates_pkey" PRIMARY KEY ("id");


--
-- Name: certifications certifications_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."certifications"
    ADD CONSTRAINT "certifications_pkey" PRIMARY KEY ("id");


--
-- Name: certifications certifications_user_id_course_id_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."certifications"
    ADD CONSTRAINT "certifications_user_id_course_id_key" UNIQUE ("user_id", "course_id");


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."courses"
    ADD CONSTRAINT "courses_pkey" PRIMARY KEY ("id");


--
-- Name: courses courses_slug_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."courses"
    ADD CONSTRAINT "courses_slug_key" UNIQUE ("slug");


--
-- Name: drip_plans drip_plans_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."drip_plans"
    ADD CONSTRAINT "drip_plans_pkey" PRIMARY KEY ("id");


--
-- Name: drip_rules drip_rules_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."drip_rules"
    ADD CONSTRAINT "drip_rules_pkey" PRIMARY KEY ("id");


--
-- Name: editor_styles editor_styles_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."editor_styles"
    ADD CONSTRAINT "editor_styles_pkey" PRIMARY KEY ("id");


--
-- Name: enrollments enrollments_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."enrollments"
    ADD CONSTRAINT "enrollments_pkey" PRIMARY KEY ("id");


--
-- Name: enrollments enrollments_user_id_course_id_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."enrollments"
    ADD CONSTRAINT "enrollments_user_id_course_id_key" UNIQUE ("user_id", "course_id");


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."events"
    ADD CONSTRAINT "events_pkey" PRIMARY KEY ("id");


--
-- Name: guest_claim_tokens guest_claim_tokens_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."guest_claim_tokens"
    ADD CONSTRAINT "guest_claim_tokens_pkey" PRIMARY KEY ("token");


--
-- Name: lesson_media lesson_media_lesson_id_position_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."lesson_media"
    ADD CONSTRAINT "lesson_media_lesson_id_position_key" UNIQUE ("lesson_id", "position");


--
-- Name: lesson_media lesson_media_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."lesson_media"
    ADD CONSTRAINT "lesson_media_pkey" PRIMARY KEY ("id");


--
-- Name: lessons lessons_module_id_position_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."lessons"
    ADD CONSTRAINT "lessons_module_id_position_key" UNIQUE ("module_id", "position");


--
-- Name: lessons lessons_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."lessons"
    ADD CONSTRAINT "lessons_pkey" PRIMARY KEY ("id");


--
-- Name: magic_links magic_links_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."magic_links"
    ADD CONSTRAINT "magic_links_pkey" PRIMARY KEY ("id");


--
-- Name: meditations meditations_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."meditations"
    ADD CONSTRAINT "meditations_pkey" PRIMARY KEY ("id");


--
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."memberships"
    ADD CONSTRAINT "memberships_pkey" PRIMARY KEY ("user_id");


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");


--
-- Name: modules modules_course_id_position_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."modules"
    ADD CONSTRAINT "modules_course_id_position_key" UNIQUE ("course_id", "position");


--
-- Name: modules modules_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."modules"
    ADD CONSTRAINT "modules_pkey" PRIMARY KEY ("id");


--
-- Name: notification_jobs notification_jobs_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."notification_jobs"
    ADD CONSTRAINT "notification_jobs_pkey" PRIMARY KEY ("id");


--
-- Name: notification_templates notification_templates_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."notification_templates"
    ADD CONSTRAINT "notification_templates_pkey" PRIMARY KEY ("id");


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."orders"
    ADD CONSTRAINT "orders_pkey" PRIMARY KEY ("id");


--
-- Name: pro_progress pro_progress_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."pro_progress"
    ADD CONSTRAINT "pro_progress_pkey" PRIMARY KEY ("user_id", "requirement_id");


--
-- Name: pro_requirements pro_requirements_code_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."pro_requirements"
    ADD CONSTRAINT "pro_requirements_code_key" UNIQUE ("code");


--
-- Name: pro_requirements pro_requirements_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."pro_requirements"
    ADD CONSTRAINT "pro_requirements_pkey" PRIMARY KEY ("id");


--
-- Name: profiles profiles_email_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."profiles"
    ADD CONSTRAINT "profiles_email_key" UNIQUE ("email");


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("user_id");


--
-- Name: purchases purchases_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."purchases"
    ADD CONSTRAINT "purchases_pkey" PRIMARY KEY ("id");


--
-- Name: purchases purchases_stripe_checkout_id_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."purchases"
    ADD CONSTRAINT "purchases_stripe_checkout_id_key" UNIQUE ("stripe_checkout_id");


--
-- Name: purchases purchases_stripe_payment_intent_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."purchases"
    ADD CONSTRAINT "purchases_stripe_payment_intent_key" UNIQUE ("stripe_payment_intent");


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."services"
    ADD CONSTRAINT "services_pkey" PRIMARY KEY ("id");


--
-- Name: tarot_requests tarot_requests_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."tarot_requests"
    ADD CONSTRAINT "tarot_requests_pkey" PRIMARY KEY ("id");


--
-- Name: teacher_approvals teacher_approvals_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_approvals"
    ADD CONSTRAINT "teacher_approvals_pkey" PRIMARY KEY ("user_id");


--
-- Name: teacher_directory teacher_directory_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_directory"
    ADD CONSTRAINT "teacher_directory_pkey" PRIMARY KEY ("user_id");


--
-- Name: teacher_permissions teacher_permissions_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_permissions"
    ADD CONSTRAINT "teacher_permissions_pkey" PRIMARY KEY ("profile_id");


--
-- Name: teacher_requests teacher_requests_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_requests"
    ADD CONSTRAINT "teacher_requests_pkey" PRIMARY KEY ("id");


--
-- Name: teacher_requests teacher_requests_user_id_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_requests"
    ADD CONSTRAINT "teacher_requests_user_id_key" UNIQUE ("user_id");


--
-- Name: teacher_slots teacher_slots_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_slots"
    ADD CONSTRAINT "teacher_slots_pkey" PRIMARY KEY ("id");


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_amr_claims"
    ADD CONSTRAINT "amr_id_pk" PRIMARY KEY ("id");


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."audit_log_entries"
    ADD CONSTRAINT "audit_log_entries_pkey" PRIMARY KEY ("id");


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."flow_state"
    ADD CONSTRAINT "flow_state_pkey" PRIMARY KEY ("id");


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."identities"
    ADD CONSTRAINT "identities_pkey" PRIMARY KEY ("id");


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."identities"
    ADD CONSTRAINT "identities_provider_id_provider_unique" UNIQUE ("provider_id", "provider");


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."instances"
    ADD CONSTRAINT "instances_pkey" PRIMARY KEY ("id");


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_amr_claims"
    ADD CONSTRAINT "mfa_amr_claims_session_id_authentication_method_pkey" UNIQUE ("session_id", "authentication_method");


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_challenges"
    ADD CONSTRAINT "mfa_challenges_pkey" PRIMARY KEY ("id");


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_factors"
    ADD CONSTRAINT "mfa_factors_last_challenged_at_key" UNIQUE ("last_challenged_at");


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_factors"
    ADD CONSTRAINT "mfa_factors_pkey" PRIMARY KEY ("id");


--
-- Name: oauth_clients oauth_clients_client_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."oauth_clients"
    ADD CONSTRAINT "oauth_clients_client_id_key" UNIQUE ("client_id");


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."oauth_clients"
    ADD CONSTRAINT "oauth_clients_pkey" PRIMARY KEY ("id");


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."one_time_tokens"
    ADD CONSTRAINT "one_time_tokens_pkey" PRIMARY KEY ("id");


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_pkey" PRIMARY KEY ("id");


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_token_unique" UNIQUE ("token");


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."saml_providers"
    ADD CONSTRAINT "saml_providers_entity_id_key" UNIQUE ("entity_id");


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."saml_providers"
    ADD CONSTRAINT "saml_providers_pkey" PRIMARY KEY ("id");


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."saml_relay_states"
    ADD CONSTRAINT "saml_relay_states_pkey" PRIMARY KEY ("id");


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."schema_migrations"
    ADD CONSTRAINT "schema_migrations_pkey" PRIMARY KEY ("version");


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."sessions"
    ADD CONSTRAINT "sessions_pkey" PRIMARY KEY ("id");


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."sso_domains"
    ADD CONSTRAINT "sso_domains_pkey" PRIMARY KEY ("id");


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."sso_providers"
    ADD CONSTRAINT "sso_providers_pkey" PRIMARY KEY ("id");


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."users"
    ADD CONSTRAINT "users_phone_key" UNIQUE ("phone");


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");


--
-- Name: admin_keys admin_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."admin_keys"
    ADD CONSTRAINT "admin_keys_pkey" PRIMARY KEY ("code");


--
-- Name: availability_slots availability_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."availability_slots"
    ADD CONSTRAINT "availability_slots_pkey" PRIMARY KEY ("id");


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_pkey" PRIMARY KEY ("id");


--
-- Name: certificates certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."certificates"
    ADD CONSTRAINT "certificates_pkey" PRIMARY KEY ("id");


--
-- Name: certificates certificates_user_id_course_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."certificates"
    ADD CONSTRAINT "certificates_user_id_course_id_key" UNIQUE ("user_id", "course_id");


--
-- Name: coupons coupons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."coupons"
    ADD CONSTRAINT "coupons_pkey" PRIMARY KEY ("code");


--
-- Name: course_enrollments course_enrollments_course_id_student_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."course_enrollments"
    ADD CONSTRAINT "course_enrollments_course_id_student_id_key" UNIQUE ("course_id", "student_id");


--
-- Name: course_enrollments course_enrollments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."course_enrollments"
    ADD CONSTRAINT "course_enrollments_pkey" PRIMARY KEY ("id");


--
-- Name: course_modules course_modules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."course_modules"
    ADD CONSTRAINT "course_modules_pkey" PRIMARY KEY ("id");


--
-- Name: course_quizzes course_quizzes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."course_quizzes"
    ADD CONSTRAINT "course_quizzes_pkey" PRIMARY KEY ("id");


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."courses"
    ADD CONSTRAINT "courses_pkey" PRIMARY KEY ("id");


--
-- Name: courses courses_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."courses"
    ADD CONSTRAINT "courses_slug_key" UNIQUE ("slug");


--
-- Name: lesson_media lesson_media_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."lesson_media"
    ADD CONSTRAINT "lesson_media_pkey" PRIMARY KEY ("id");


--
-- Name: lessons lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."lessons"
    ADD CONSTRAINT "lessons_pkey" PRIMARY KEY ("id");


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");


--
-- Name: modules modules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."modules"
    ADD CONSTRAINT "modules_pkey" PRIMARY KEY ("id");


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");


--
-- Name: profiles profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_user_id_key" UNIQUE ("user_id");


--
-- Name: public_teacher_info public_teacher_info_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."public_teacher_info"
    ADD CONSTRAINT "public_teacher_info_pkey" PRIMARY KEY ("id");


--
-- Name: public_teacher_info public_teacher_info_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."public_teacher_info"
    ADD CONSTRAINT "public_teacher_info_user_id_key" UNIQUE ("user_id");


--
-- Name: quiz_attempts quiz_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."quiz_attempts"
    ADD CONSTRAINT "quiz_attempts_pkey" PRIMARY KEY ("id");


--
-- Name: quiz_questions quiz_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."quiz_questions"
    ADD CONSTRAINT "quiz_questions_pkey" PRIMARY KEY ("id");


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."services"
    ADD CONSTRAINT "services_pkey" PRIMARY KEY ("id");


--
-- Name: subscription_plans subscription_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."subscription_plans"
    ADD CONSTRAINT "subscription_plans_pkey" PRIMARY KEY ("id");


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_pkey" PRIMARY KEY ("id");


--
-- Name: tarot_readings tarot_readings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."tarot_readings"
    ADD CONSTRAINT "tarot_readings_pkey" PRIMARY KEY ("id");


--
-- Name: teacher_directory teacher_directory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."teacher_directory"
    ADD CONSTRAINT "teacher_directory_pkey" PRIMARY KEY ("id");


--
-- Name: teacher_directory teacher_directory_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."teacher_directory"
    ADD CONSTRAINT "teacher_directory_user_id_key" UNIQUE ("user_id");


--
-- Name: teacher_permissions teacher_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."teacher_permissions"
    ADD CONSTRAINT "teacher_permissions_pkey" PRIMARY KEY ("user_id");


--
-- Name: teacher_requests teacher_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."teacher_requests"
    ADD CONSTRAINT "teacher_requests_pkey" PRIMARY KEY ("id");


--
-- Name: user_certifications user_certifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."user_certifications"
    ADD CONSTRAINT "user_certifications_pkey" PRIMARY KEY ("user_id", "area");


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_pkey" PRIMARY KEY ("id");


--
-- Name: user_roles user_roles_user_id_role_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_user_id_role_key" UNIQUE ("user_id", "role");


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY "realtime"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id", "inserted_at");


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY "realtime"."subscription"
    ADD CONSTRAINT "pk_subscription" PRIMARY KEY ("id");


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY "realtime"."schema_migrations"
    ADD CONSTRAINT "schema_migrations_pkey" PRIMARY KEY ("version");


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."buckets_analytics"
    ADD CONSTRAINT "buckets_analytics_pkey" PRIMARY KEY ("id");


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."buckets"
    ADD CONSTRAINT "buckets_pkey" PRIMARY KEY ("id");


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."migrations"
    ADD CONSTRAINT "migrations_name_key" UNIQUE ("name");


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."migrations"
    ADD CONSTRAINT "migrations_pkey" PRIMARY KEY ("id");


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."objects"
    ADD CONSTRAINT "objects_pkey" PRIMARY KEY ("id");


--
-- Name: prefixes prefixes_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."prefixes"
    ADD CONSTRAINT "prefixes_pkey" PRIMARY KEY ("bucket_id", "level", "name");


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."s3_multipart_uploads_parts"
    ADD CONSTRAINT "s3_multipart_uploads_parts_pkey" PRIMARY KEY ("id");


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."s3_multipart_uploads"
    ADD CONSTRAINT "s3_multipart_uploads_pkey" PRIMARY KEY ("id");


--
-- Name: schema_migrations schema_migrations_idempotency_key_key; Type: CONSTRAINT; Schema: supabase_migrations; Owner: -
--

ALTER TABLE ONLY "supabase_migrations"."schema_migrations"
    ADD CONSTRAINT "schema_migrations_idempotency_key_key" UNIQUE ("idempotency_key");


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: -
--

ALTER TABLE ONLY "supabase_migrations"."schema_migrations"
    ADD CONSTRAINT "schema_migrations_pkey" PRIMARY KEY ("version");


--
-- Name: seed_files seed_files_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: -
--

ALTER TABLE ONLY "supabase_migrations"."seed_files"
    ADD CONSTRAINT "seed_files_pkey" PRIMARY KEY ("path");


--
-- Name: certificates_user_title_key; Type: INDEX; Schema: app; Owner: -
--

CREATE UNIQUE INDEX "certificates_user_title_key" ON "app"."certificates" USING "btree" ("user_id", "title");


--
-- Name: idx_certificates_user_title; Type: INDEX; Schema: app; Owner: -
--

CREATE UNIQUE INDEX "idx_certificates_user_title" ON "app"."certificates" USING "btree" ("user_id", "title");


--
-- Name: idx_courses_branch; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_courses_branch" ON "app"."courses" USING "btree" ("branch");


--
-- Name: idx_courses_created_by; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_courses_created_by" ON "app"."courses" USING "btree" ("created_by");


--
-- Name: idx_courses_is_free_intro; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_courses_is_free_intro" ON "app"."courses" USING "btree" ("is_free_intro");


--
-- Name: idx_drip_plans_course; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_drip_plans_course" ON "app"."drip_plans" USING "btree" ("course_id");


--
-- Name: idx_drip_rules_plan; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_drip_rules_plan" ON "app"."drip_rules" USING "btree" ("plan_id");


--
-- Name: idx_editor_styles_course; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_editor_styles_course" ON "app"."editor_styles" USING "btree" ("course_id");


--
-- Name: idx_enroll_course; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_enroll_course" ON "app"."enrollments" USING "btree" ("course_id");


--
-- Name: idx_enroll_user; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_enroll_user" ON "app"."enrollments" USING "btree" ("user_id");


--
-- Name: idx_guest_claim_email; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_guest_claim_email" ON "app"."guest_claim_tokens" USING "btree" ("buyer_email");


--
-- Name: idx_guest_claim_purchase; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_guest_claim_purchase" ON "app"."guest_claim_tokens" USING "btree" ("purchase_id");


--
-- Name: idx_lessons_module; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_lessons_module" ON "app"."lessons" USING "btree" ("module_id");


--
-- Name: idx_magic_links_course; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_magic_links_course" ON "app"."magic_links" USING "btree" ("course_id");


--
-- Name: idx_media_lesson; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_media_lesson" ON "app"."lesson_media" USING "btree" ("lesson_id");


--
-- Name: idx_meditations_teacher; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_meditations_teacher" ON "app"."meditations" USING "btree" ("teacher_id");


--
-- Name: idx_messages_channel; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_messages_channel" ON "app"."messages" USING "btree" ("channel");


--
-- Name: idx_messages_sender; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_messages_sender" ON "app"."messages" USING "btree" ("sender_id");


--
-- Name: idx_modules_course; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_modules_course" ON "app"."modules" USING "btree" ("course_id");


--
-- Name: idx_notif_jobs_due; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_notif_jobs_due" ON "app"."notification_jobs" USING "btree" ("status", "scheduled_at");


--
-- Name: idx_orders_service; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_orders_service" ON "app"."orders" USING "btree" ("service_id");


--
-- Name: idx_orders_status; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_orders_status" ON "app"."orders" USING "btree" ("status");


--
-- Name: idx_orders_user; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_orders_user" ON "app"."orders" USING "btree" ("user_id");


--
-- Name: idx_profiles_role; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_profiles_role" ON "app"."profiles" USING "btree" ("role");


--
-- Name: idx_purchases_course; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_purchases_course" ON "app"."purchases" USING "btree" ("course_id");


--
-- Name: idx_purchases_email; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_purchases_email" ON "app"."purchases" USING "btree" ("buyer_email");


--
-- Name: idx_purchases_order; Type: INDEX; Schema: app; Owner: -
--

CREATE UNIQUE INDEX "idx_purchases_order" ON "app"."purchases" USING "btree" ("order_id") WHERE ("order_id" IS NOT NULL);


--
-- Name: idx_purchases_user; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_purchases_user" ON "app"."purchases" USING "btree" ("user_id");


--
-- Name: idx_services_provider; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_services_provider" ON "app"."services" USING "btree" ("provider_id");


--
-- Name: idx_slots_teacher; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_slots_teacher" ON "app"."teacher_slots" USING "btree" ("teacher_id");


--
-- Name: uq_drip_rules; Type: INDEX; Schema: app; Owner: -
--

CREATE UNIQUE INDEX "uq_drip_rules" ON "app"."drip_rules" USING "btree" ("plan_id", "module_id", COALESCE("page_id", '00000000-0000-0000-0000-000000000000'::"uuid"));


--
-- Name: uq_notification_jobs_natural; Type: INDEX; Schema: app; Owner: -
--

CREATE UNIQUE INDEX "uq_notification_jobs_natural" ON "app"."notification_jobs" USING "btree" ("user_id", "course_id", "module_id", COALESCE("page_id", '00000000-0000-0000-0000-000000000000'::"uuid"), "scheduled_at");


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "audit_logs_instance_id_idx" ON "auth"."audit_log_entries" USING "btree" ("instance_id");


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "confirmation_token_idx" ON "auth"."users" USING "btree" ("confirmation_token") WHERE (("confirmation_token")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "email_change_token_current_idx" ON "auth"."users" USING "btree" ("email_change_token_current") WHERE (("email_change_token_current")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "email_change_token_new_idx" ON "auth"."users" USING "btree" ("email_change_token_new") WHERE (("email_change_token_new")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "factor_id_created_at_idx" ON "auth"."mfa_factors" USING "btree" ("user_id", "created_at");


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "flow_state_created_at_idx" ON "auth"."flow_state" USING "btree" ("created_at" DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "identities_email_idx" ON "auth"."identities" USING "btree" ("email" "text_pattern_ops");


--
-- Name: INDEX "identities_email_idx"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX "auth"."identities_email_idx" IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "identities_user_id_idx" ON "auth"."identities" USING "btree" ("user_id");


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "idx_auth_code" ON "auth"."flow_state" USING "btree" ("auth_code");


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "idx_user_id_auth_method" ON "auth"."flow_state" USING "btree" ("user_id", "authentication_method");


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "mfa_challenge_created_at_idx" ON "auth"."mfa_challenges" USING "btree" ("created_at" DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "mfa_factors_user_friendly_name_unique" ON "auth"."mfa_factors" USING "btree" ("friendly_name", "user_id") WHERE (TRIM(BOTH FROM "friendly_name") <> ''::"text");


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "mfa_factors_user_id_idx" ON "auth"."mfa_factors" USING "btree" ("user_id");


--
-- Name: oauth_clients_client_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "oauth_clients_client_id_idx" ON "auth"."oauth_clients" USING "btree" ("client_id");


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "oauth_clients_deleted_at_idx" ON "auth"."oauth_clients" USING "btree" ("deleted_at");


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "one_time_tokens_relates_to_hash_idx" ON "auth"."one_time_tokens" USING "hash" ("relates_to");


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "one_time_tokens_token_hash_hash_idx" ON "auth"."one_time_tokens" USING "hash" ("token_hash");


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "one_time_tokens_user_id_token_type_key" ON "auth"."one_time_tokens" USING "btree" ("user_id", "token_type");


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "reauthentication_token_idx" ON "auth"."users" USING "btree" ("reauthentication_token") WHERE (("reauthentication_token")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "recovery_token_idx" ON "auth"."users" USING "btree" ("recovery_token") WHERE (("recovery_token")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "refresh_tokens_instance_id_idx" ON "auth"."refresh_tokens" USING "btree" ("instance_id");


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "refresh_tokens_instance_id_user_id_idx" ON "auth"."refresh_tokens" USING "btree" ("instance_id", "user_id");


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "refresh_tokens_parent_idx" ON "auth"."refresh_tokens" USING "btree" ("parent");


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "refresh_tokens_session_id_revoked_idx" ON "auth"."refresh_tokens" USING "btree" ("session_id", "revoked");


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "refresh_tokens_updated_at_idx" ON "auth"."refresh_tokens" USING "btree" ("updated_at" DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "saml_providers_sso_provider_id_idx" ON "auth"."saml_providers" USING "btree" ("sso_provider_id");


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "saml_relay_states_created_at_idx" ON "auth"."saml_relay_states" USING "btree" ("created_at" DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "saml_relay_states_for_email_idx" ON "auth"."saml_relay_states" USING "btree" ("for_email");


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "saml_relay_states_sso_provider_id_idx" ON "auth"."saml_relay_states" USING "btree" ("sso_provider_id");


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "sessions_not_after_idx" ON "auth"."sessions" USING "btree" ("not_after" DESC);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "sessions_user_id_idx" ON "auth"."sessions" USING "btree" ("user_id");


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "sso_domains_domain_idx" ON "auth"."sso_domains" USING "btree" ("lower"("domain"));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "sso_domains_sso_provider_id_idx" ON "auth"."sso_domains" USING "btree" ("sso_provider_id");


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "sso_providers_resource_id_idx" ON "auth"."sso_providers" USING "btree" ("lower"("resource_id"));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "sso_providers_resource_id_pattern_idx" ON "auth"."sso_providers" USING "btree" ("resource_id" "text_pattern_ops");


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "unique_phone_factor_per_user" ON "auth"."mfa_factors" USING "btree" ("user_id", "phone");


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "user_id_created_at_idx" ON "auth"."sessions" USING "btree" ("user_id", "created_at");


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "users_email_partial_key" ON "auth"."users" USING "btree" ("email") WHERE ("is_sso_user" = false);


--
-- Name: INDEX "users_email_partial_key"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX "auth"."users_email_partial_key" IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "users_instance_id_email_idx" ON "auth"."users" USING "btree" ("instance_id", "lower"(("email")::"text"));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "users_instance_id_idx" ON "auth"."users" USING "btree" ("instance_id");


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "users_is_anonymous_idx" ON "auth"."users" USING "btree" ("is_anonymous");


--
-- Name: idx_attempts_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_attempts_user" ON "public"."quiz_attempts" USING "btree" ("user_id", "quiz_id");


--
-- Name: idx_availability_slots_teacher_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_availability_slots_teacher_id" ON "public"."availability_slots" USING "btree" ("teacher_id");


--
-- Name: idx_availability_slots_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_availability_slots_time" ON "public"."availability_slots" USING "btree" ("start_time", "end_time");


--
-- Name: idx_bookings_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_bookings_student_id" ON "public"."bookings" USING "btree" ("student_id");


--
-- Name: idx_bookings_teacher_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_bookings_teacher_id" ON "public"."bookings" USING "btree" ("teacher_id");


--
-- Name: idx_certificates_course; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_certificates_course" ON "public"."certificates" USING "btree" ("course_id");


--
-- Name: idx_certificates_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_certificates_user" ON "public"."certificates" USING "btree" ("user_id");


--
-- Name: idx_coupons_enabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_coupons_enabled" ON "public"."coupons" USING "btree" ("is_enabled");


--
-- Name: idx_coupons_expires; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_coupons_expires" ON "public"."coupons" USING "btree" ("expires_at");


--
-- Name: idx_course_enrollments_course_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_course_enrollments_course_id" ON "public"."course_enrollments" USING "btree" ("course_id");


--
-- Name: idx_course_enrollments_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_course_enrollments_student_id" ON "public"."course_enrollments" USING "btree" ("student_id");


--
-- Name: idx_course_modules_course; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_course_modules_course" ON "public"."course_modules" USING "btree" ("course_id");


--
-- Name: idx_course_quizzes_course; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_course_quizzes_course" ON "public"."course_quizzes" USING "btree" ("course_id");


--
-- Name: idx_courses_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_courses_published" ON "public"."courses" USING "btree" ("is_published");


--
-- Name: idx_courses_teacher_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_courses_teacher_id" ON "public"."courses" USING "btree" ("teacher_id");


--
-- Name: idx_messages_course_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_messages_course_id" ON "public"."messages" USING "btree" ("course_id");


--
-- Name: idx_messages_sender_recipient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_messages_sender_recipient" ON "public"."messages" USING "btree" ("sender_id", "recipient_id");


--
-- Name: idx_notifications_unread; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_notifications_unread" ON "public"."notifications" USING "btree" ("user_id", "is_read") WHERE ("is_read" = false);


--
-- Name: idx_notifications_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_notifications_user_id" ON "public"."notifications" USING "btree" ("user_id");


--
-- Name: idx_public_teacher_info_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_public_teacher_info_user_id" ON "public"."public_teacher_info" USING "btree" ("user_id");


--
-- Name: idx_quiz_attempts_quiz; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_quiz_attempts_quiz" ON "public"."quiz_attempts" USING "btree" ("quiz_id");


--
-- Name: idx_quiz_attempts_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_quiz_attempts_user" ON "public"."quiz_attempts" USING "btree" ("user_id");


--
-- Name: idx_quiz_questions_quiz; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_quiz_questions_quiz" ON "public"."quiz_questions" USING "btree" ("quiz_id");


--
-- Name: idx_subs_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_subs_status" ON "public"."subscriptions" USING "btree" ("status");


--
-- Name: idx_subs_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_subs_user" ON "public"."subscriptions" USING "btree" ("user_id");


--
-- Name: idx_tarot_readings_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_tarot_readings_status" ON "public"."tarot_readings" USING "btree" ("status");


--
-- Name: idx_tarot_readings_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_tarot_readings_student_id" ON "public"."tarot_readings" USING "btree" ("student_id");


--
-- Name: idx_tarot_readings_teacher_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_tarot_readings_teacher_id" ON "public"."tarot_readings" USING "btree" ("teacher_id");


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX "ix_realtime_subscription_entity" ON "realtime"."subscription" USING "btree" ("entity");


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX "messages_inserted_at_topic_index" ON ONLY "realtime"."messages" USING "btree" ("inserted_at" DESC, "topic") WHERE (("extension" = 'broadcast'::"text") AND ("private" IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: -
--

CREATE UNIQUE INDEX "subscription_subscription_id_entity_filters_key" ON "realtime"."subscription" USING "btree" ("subscription_id", "entity", "filters");


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX "bname" ON "storage"."buckets" USING "btree" ("name");


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX "bucketid_objname" ON "storage"."objects" USING "btree" ("bucket_id", "name");


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX "idx_multipart_uploads_list" ON "storage"."s3_multipart_uploads" USING "btree" ("bucket_id", "key", "created_at");


--
-- Name: idx_name_bucket_level_unique; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX "idx_name_bucket_level_unique" ON "storage"."objects" USING "btree" ("name" COLLATE "C", "bucket_id", "level");


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX "idx_objects_bucket_id_name" ON "storage"."objects" USING "btree" ("bucket_id", "name" COLLATE "C");


--
-- Name: idx_objects_lower_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX "idx_objects_lower_name" ON "storage"."objects" USING "btree" (("path_tokens"["level"]), "lower"("name") "text_pattern_ops", "bucket_id", "level");


--
-- Name: idx_prefixes_lower_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX "idx_prefixes_lower_name" ON "storage"."prefixes" USING "btree" ("bucket_id", "level", (("string_to_array"("name", '/'::"text"))["level"]), "lower"("name") "text_pattern_ops");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX "name_prefix_search" ON "storage"."objects" USING "btree" ("name" "text_pattern_ops");


--
-- Name: objects_bucket_id_level_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX "objects_bucket_id_level_idx" ON "storage"."objects" USING "btree" ("bucket_id", "level", "name" COLLATE "C");


--
-- Name: bookings trg_bookings_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_bookings_touch" BEFORE UPDATE ON "app"."bookings" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: certificates trg_certificates_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_certificates_touch" BEFORE UPDATE ON "app"."certificates" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: certifications trg_certifications_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_certifications_touch" BEFORE UPDATE ON "app"."certifications" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: courses trg_courses_set_owner; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_courses_set_owner" BEFORE INSERT ON "app"."courses" FOR EACH ROW EXECUTE FUNCTION "app"."_courses_set_owner"();


--
-- Name: courses trg_courses_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_courses_touch" BEFORE UPDATE ON "app"."courses" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: drip_plans trg_drip_plans_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_drip_plans_touch" BEFORE UPDATE ON "app"."drip_plans" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: drip_rules trg_drip_rules_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_drip_rules_touch" BEFORE UPDATE ON "app"."drip_rules" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: editor_styles trg_editor_styles_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_editor_styles_touch" BEFORE UPDATE ON "app"."editor_styles" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: enrollments trg_enroll_materialize; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_enroll_materialize" AFTER INSERT ON "app"."enrollments" FOR EACH ROW EXECUTE FUNCTION "app"."enrollments_materialize_trg_fn"();


--
-- Name: events trg_events_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_events_touch" BEFORE UPDATE ON "app"."events" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: lessons trg_lessons_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_lessons_touch" BEFORE UPDATE ON "app"."lessons" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: magic_links trg_magic_links_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_magic_links_touch" BEFORE UPDATE ON "app"."magic_links" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: meditations trg_meditations_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_meditations_touch" BEFORE UPDATE ON "app"."meditations" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: memberships trg_memberships_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_memberships_touch" BEFORE UPDATE ON "app"."memberships" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: messages trg_messages_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_messages_touch" BEFORE UPDATE ON "app"."messages" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: modules trg_modules_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_modules_touch" BEFORE UPDATE ON "app"."modules" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: notification_jobs trg_notification_jobs_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_notification_jobs_touch" BEFORE UPDATE ON "app"."notification_jobs" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: notification_templates trg_notification_templates_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_notification_templates_touch" BEFORE UPDATE ON "app"."notification_templates" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: orders trg_orders_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_orders_touch" BEFORE UPDATE ON "app"."orders" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: pro_progress trg_pro_progress_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_pro_progress_touch" BEFORE UPDATE ON "app"."pro_progress" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: pro_requirements trg_pro_requirements_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_pro_requirements_touch" BEFORE UPDATE ON "app"."pro_requirements" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: profiles trg_profiles_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_profiles_touch" BEFORE UPDATE ON "app"."profiles" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: services trg_services_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_services_touch" BEFORE UPDATE ON "app"."services" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: tarot_requests trg_tarot_requests_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_tarot_requests_touch" BEFORE UPDATE ON "app"."tarot_requests" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: tarot_requests trg_tarot_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_tarot_touch" BEFORE UPDATE ON "app"."tarot_requests" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: teacher_approvals trg_teacher_approvals_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_teacher_approvals_touch" BEFORE UPDATE ON "app"."teacher_approvals" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: -
--

CREATE TRIGGER "on_auth_user_created" AFTER INSERT ON "auth"."users" FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_user"();


--
-- Name: user_roles on_teacher_role_created; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "on_teacher_role_created" AFTER INSERT ON "public"."user_roles" FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_teacher"();


--
-- Name: course_modules trg_course_modules_created_by; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "trg_course_modules_created_by" BEFORE INSERT OR UPDATE ON "public"."course_modules" FOR EACH ROW EXECUTE FUNCTION "public"."_set_created_by"();


--
-- Name: course_modules trg_course_modules_set_created_by; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "trg_course_modules_set_created_by" BEFORE INSERT OR UPDATE ON "public"."course_modules" FOR EACH ROW EXECUTE FUNCTION "public"."_set_created_by"();


--
-- Name: courses trg_courses_created_by; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "trg_courses_created_by" BEFORE INSERT ON "public"."courses" FOR EACH ROW EXECUTE FUNCTION "public"."set_created_by"();


--
-- Name: services trg_services_owner; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "trg_services_owner" BEFORE INSERT ON "public"."services" FOR EACH ROW EXECUTE FUNCTION "public"."set_owner"();


--
-- Name: availability_slots update_availability_slots_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_availability_slots_updated_at" BEFORE UPDATE ON "public"."availability_slots" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: bookings update_bookings_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_bookings_updated_at" BEFORE UPDATE ON "public"."bookings" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: course_enrollments update_course_enrollments_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_course_enrollments_updated_at" BEFORE UPDATE ON "public"."course_enrollments" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: courses update_courses_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_courses_updated_at" BEFORE UPDATE ON "public"."courses" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: lessons update_lessons_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_lessons_updated_at" BEFORE UPDATE ON "public"."lessons" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: messages update_messages_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_messages_updated_at" BEFORE UPDATE ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: modules update_modules_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_modules_updated_at" BEFORE UPDATE ON "public"."modules" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: profiles update_profiles_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_profiles_updated_at" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: public_teacher_info update_public_teacher_info_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_public_teacher_info_updated_at" BEFORE UPDATE ON "public"."public_teacher_info" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: tarot_readings update_tarot_readings_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_tarot_readings_updated_at" BEFORE UPDATE ON "public"."tarot_readings" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: teacher_directory update_teacher_directory_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_teacher_directory_updated_at" BEFORE UPDATE ON "public"."teacher_directory" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: teacher_requests update_teacher_requests_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_teacher_requests_updated_at" BEFORE UPDATE ON "public"."teacher_requests" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: -
--

CREATE TRIGGER "tr_check_filters" BEFORE INSERT OR UPDATE ON "realtime"."subscription" FOR EACH ROW EXECUTE FUNCTION "realtime"."subscription_check_filters"();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER "enforce_bucket_name_length_trigger" BEFORE INSERT OR UPDATE OF "name" ON "storage"."buckets" FOR EACH ROW EXECUTE FUNCTION "storage"."enforce_bucket_name_length"();


--
-- Name: objects objects_delete_delete_prefix; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER "objects_delete_delete_prefix" AFTER DELETE ON "storage"."objects" FOR EACH ROW EXECUTE FUNCTION "storage"."delete_prefix_hierarchy_trigger"();


--
-- Name: objects objects_insert_create_prefix; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER "objects_insert_create_prefix" BEFORE INSERT ON "storage"."objects" FOR EACH ROW EXECUTE FUNCTION "storage"."objects_insert_prefix_trigger"();


--
-- Name: objects objects_update_create_prefix; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER "objects_update_create_prefix" BEFORE UPDATE ON "storage"."objects" FOR EACH ROW WHEN ((("new"."name" <> "old"."name") OR ("new"."bucket_id" <> "old"."bucket_id"))) EXECUTE FUNCTION "storage"."objects_update_prefix_trigger"();


--
-- Name: prefixes prefixes_create_hierarchy; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER "prefixes_create_hierarchy" BEFORE INSERT ON "storage"."prefixes" FOR EACH ROW WHEN (("pg_trigger_depth"() < 1)) EXECUTE FUNCTION "storage"."prefixes_insert_trigger"();


--
-- Name: prefixes prefixes_delete_hierarchy; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER "prefixes_delete_hierarchy" AFTER DELETE ON "storage"."prefixes" FOR EACH ROW EXECUTE FUNCTION "storage"."delete_prefix_hierarchy_trigger"();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER "update_objects_updated_at" BEFORE UPDATE ON "storage"."objects" FOR EACH ROW EXECUTE FUNCTION "storage"."update_updated_at_column"();


--
-- Name: bookings bookings_order_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."bookings"
    ADD CONSTRAINT "bookings_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "app"."orders"("id") ON DELETE SET NULL;


--
-- Name: bookings bookings_slot_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."bookings"
    ADD CONSTRAINT "bookings_slot_id_fkey" FOREIGN KEY ("slot_id") REFERENCES "app"."teacher_slots"("id") ON DELETE CASCADE;


--
-- Name: bookings bookings_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."bookings"
    ADD CONSTRAINT "bookings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: certificates certificates_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."certificates"
    ADD CONSTRAINT "certificates_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: certifications certifications_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."certifications"
    ADD CONSTRAINT "certifications_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE CASCADE;


--
-- Name: certifications certifications_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."certifications"
    ADD CONSTRAINT "certifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: courses courses_created_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."courses"
    ADD CONSTRAINT "courses_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "app"."profiles"("user_id") ON DELETE SET NULL;


--
-- Name: drip_plans drip_plans_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."drip_plans"
    ADD CONSTRAINT "drip_plans_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE CASCADE;


--
-- Name: drip_plans drip_plans_created_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."drip_plans"
    ADD CONSTRAINT "drip_plans_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: drip_rules drip_rules_created_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."drip_rules"
    ADD CONSTRAINT "drip_rules_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: drip_rules drip_rules_module_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."drip_rules"
    ADD CONSTRAINT "drip_rules_module_id_fkey" FOREIGN KEY ("module_id") REFERENCES "app"."modules"("id") ON DELETE CASCADE;


--
-- Name: drip_rules drip_rules_notify_template_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."drip_rules"
    ADD CONSTRAINT "drip_rules_notify_template_id_fkey" FOREIGN KEY ("notify_template_id") REFERENCES "app"."notification_templates"("id") ON DELETE SET NULL;


--
-- Name: drip_rules drip_rules_page_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."drip_rules"
    ADD CONSTRAINT "drip_rules_page_id_fkey" FOREIGN KEY ("page_id") REFERENCES "app"."lessons"("id") ON DELETE SET NULL;


--
-- Name: drip_rules drip_rules_plan_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."drip_rules"
    ADD CONSTRAINT "drip_rules_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "app"."drip_plans"("id") ON DELETE CASCADE;


--
-- Name: editor_styles editor_styles_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."editor_styles"
    ADD CONSTRAINT "editor_styles_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE CASCADE;


--
-- Name: editor_styles editor_styles_created_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."editor_styles"
    ADD CONSTRAINT "editor_styles_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: enrollments enrollments_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."enrollments"
    ADD CONSTRAINT "enrollments_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE CASCADE;


--
-- Name: enrollments enrollments_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."enrollments"
    ADD CONSTRAINT "enrollments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: events events_created_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."events"
    ADD CONSTRAINT "events_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "app"."profiles"("user_id") ON DELETE SET NULL;


--
-- Name: orders fk_orders_service_id; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."orders"
    ADD CONSTRAINT "fk_orders_service_id" FOREIGN KEY ("service_id") REFERENCES "app"."services"("id") ON DELETE SET NULL;


--
-- Name: guest_claim_tokens guest_claim_tokens_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."guest_claim_tokens"
    ADD CONSTRAINT "guest_claim_tokens_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE CASCADE;


--
-- Name: guest_claim_tokens guest_claim_tokens_purchase_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."guest_claim_tokens"
    ADD CONSTRAINT "guest_claim_tokens_purchase_id_fkey" FOREIGN KEY ("purchase_id") REFERENCES "app"."purchases"("id") ON DELETE CASCADE;


--
-- Name: lesson_media lesson_media_lesson_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."lesson_media"
    ADD CONSTRAINT "lesson_media_lesson_id_fkey" FOREIGN KEY ("lesson_id") REFERENCES "app"."lessons"("id") ON DELETE CASCADE;


--
-- Name: lessons lessons_module_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."lessons"
    ADD CONSTRAINT "lessons_module_id_fkey" FOREIGN KEY ("module_id") REFERENCES "app"."modules"("id") ON DELETE CASCADE;


--
-- Name: magic_links magic_links_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."magic_links"
    ADD CONSTRAINT "magic_links_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE CASCADE;


--
-- Name: magic_links magic_links_created_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."magic_links"
    ADD CONSTRAINT "magic_links_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: magic_links magic_links_style_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."magic_links"
    ADD CONSTRAINT "magic_links_style_id_fkey" FOREIGN KEY ("style_id") REFERENCES "app"."editor_styles"("id") ON DELETE SET NULL;


--
-- Name: meditations meditations_teacher_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."meditations"
    ADD CONSTRAINT "meditations_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: memberships memberships_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."memberships"
    ADD CONSTRAINT "memberships_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."messages"
    ADD CONSTRAINT "messages_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: modules modules_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."modules"
    ADD CONSTRAINT "modules_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE CASCADE;


--
-- Name: notification_jobs notification_jobs_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."notification_jobs"
    ADD CONSTRAINT "notification_jobs_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE CASCADE;


--
-- Name: notification_jobs notification_jobs_created_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."notification_jobs"
    ADD CONSTRAINT "notification_jobs_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: notification_jobs notification_jobs_module_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."notification_jobs"
    ADD CONSTRAINT "notification_jobs_module_id_fkey" FOREIGN KEY ("module_id") REFERENCES "app"."modules"("id") ON DELETE CASCADE;


--
-- Name: notification_jobs notification_jobs_page_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."notification_jobs"
    ADD CONSTRAINT "notification_jobs_page_id_fkey" FOREIGN KEY ("page_id") REFERENCES "app"."lessons"("id") ON DELETE SET NULL;


--
-- Name: notification_jobs notification_jobs_template_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."notification_jobs"
    ADD CONSTRAINT "notification_jobs_template_id_fkey" FOREIGN KEY ("template_id") REFERENCES "app"."notification_templates"("id") ON DELETE SET NULL;


--
-- Name: notification_jobs notification_jobs_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."notification_jobs"
    ADD CONSTRAINT "notification_jobs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: notification_templates notification_templates_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."notification_templates"
    ADD CONSTRAINT "notification_templates_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE CASCADE;


--
-- Name: notification_templates notification_templates_created_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."notification_templates"
    ADD CONSTRAINT "notification_templates_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: orders orders_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."orders"
    ADD CONSTRAINT "orders_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE SET NULL;


--
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."orders"
    ADD CONSTRAINT "orders_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: pro_progress pro_progress_requirement_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."pro_progress"
    ADD CONSTRAINT "pro_progress_requirement_id_fkey" FOREIGN KEY ("requirement_id") REFERENCES "app"."pro_requirements"("id") ON DELETE CASCADE;


--
-- Name: pro_progress pro_progress_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."pro_progress"
    ADD CONSTRAINT "pro_progress_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: profiles profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."profiles"
    ADD CONSTRAINT "profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: purchases purchases_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."purchases"
    ADD CONSTRAINT "purchases_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE CASCADE;


--
-- Name: purchases purchases_order_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."purchases"
    ADD CONSTRAINT "purchases_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "app"."orders"("id") ON DELETE SET NULL;


--
-- Name: purchases purchases_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."purchases"
    ADD CONSTRAINT "purchases_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE SET NULL;


--
-- Name: services services_provider_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."services"
    ADD CONSTRAINT "services_provider_id_fkey" FOREIGN KEY ("provider_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: tarot_requests tarot_requests_order_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."tarot_requests"
    ADD CONSTRAINT "tarot_requests_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "app"."orders"("id") ON DELETE SET NULL;


--
-- Name: tarot_requests tarot_requests_reader_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."tarot_requests"
    ADD CONSTRAINT "tarot_requests_reader_id_fkey" FOREIGN KEY ("reader_id") REFERENCES "app"."profiles"("user_id") ON DELETE SET NULL;


--
-- Name: tarot_requests tarot_requests_requester_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."tarot_requests"
    ADD CONSTRAINT "tarot_requests_requester_id_fkey" FOREIGN KEY ("requester_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: teacher_approvals teacher_approvals_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_approvals"
    ADD CONSTRAINT "teacher_approvals_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: teacher_directory teacher_directory_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_directory"
    ADD CONSTRAINT "teacher_directory_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: teacher_permissions teacher_permissions_profile_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_permissions"
    ADD CONSTRAINT "teacher_permissions_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: teacher_requests teacher_requests_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_requests"
    ADD CONSTRAINT "teacher_requests_reviewed_by_fkey" FOREIGN KEY ("reviewed_by") REFERENCES "app"."profiles"("user_id");


--
-- Name: teacher_requests teacher_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_requests"
    ADD CONSTRAINT "teacher_requests_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: teacher_slots teacher_slots_teacher_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_slots"
    ADD CONSTRAINT "teacher_slots_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."identities"
    ADD CONSTRAINT "identities_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_amr_claims"
    ADD CONSTRAINT "mfa_amr_claims_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "auth"."sessions"("id") ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_challenges"
    ADD CONSTRAINT "mfa_challenges_auth_factor_id_fkey" FOREIGN KEY ("factor_id") REFERENCES "auth"."mfa_factors"("id") ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_factors"
    ADD CONSTRAINT "mfa_factors_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."one_time_tokens"
    ADD CONSTRAINT "one_time_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "auth"."sessions"("id") ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."saml_providers"
    ADD CONSTRAINT "saml_providers_sso_provider_id_fkey" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers"("id") ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."saml_relay_states"
    ADD CONSTRAINT "saml_relay_states_flow_state_id_fkey" FOREIGN KEY ("flow_state_id") REFERENCES "auth"."flow_state"("id") ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."saml_relay_states"
    ADD CONSTRAINT "saml_relay_states_sso_provider_id_fkey" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers"("id") ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."sessions"
    ADD CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."sso_domains"
    ADD CONSTRAINT "sso_domains_sso_provider_id_fkey" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers"("id") ON DELETE CASCADE;


--
-- Name: admin_keys admin_keys_issued_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."admin_keys"
    ADD CONSTRAINT "admin_keys_issued_by_fkey" FOREIGN KEY ("issued_by") REFERENCES "auth"."users"("id");


--
-- Name: admin_keys admin_keys_redeemed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."admin_keys"
    ADD CONSTRAINT "admin_keys_redeemed_by_fkey" FOREIGN KEY ("redeemed_by") REFERENCES "auth"."users"("id");


--
-- Name: availability_slots availability_slots_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."availability_slots"
    ADD CONSTRAINT "availability_slots_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: bookings bookings_slot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_slot_id_fkey" FOREIGN KEY ("slot_id") REFERENCES "public"."availability_slots"("id") ON DELETE CASCADE;


--
-- Name: bookings bookings_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: bookings bookings_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: certificates certificates_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."certificates"
    ADD CONSTRAINT "certificates_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "public"."courses"("id") ON DELETE CASCADE;


--
-- Name: certificates certificates_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."certificates"
    ADD CONSTRAINT "certificates_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: coupons coupons_issued_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."coupons"
    ADD CONSTRAINT "coupons_issued_by_fkey" FOREIGN KEY ("issued_by") REFERENCES "auth"."users"("id");


--
-- Name: coupons coupons_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."coupons"
    ADD CONSTRAINT "coupons_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "public"."subscription_plans"("id") ON DELETE SET NULL;


--
-- Name: course_modules course_modules_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."course_modules"
    ADD CONSTRAINT "course_modules_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "public"."courses"("id") ON DELETE CASCADE;


--
-- Name: course_modules course_modules_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."course_modules"
    ADD CONSTRAINT "course_modules_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;


--
-- Name: course_quizzes course_quizzes_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."course_quizzes"
    ADD CONSTRAINT "course_quizzes_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "public"."courses"("id") ON DELETE CASCADE;


--
-- Name: course_quizzes course_quizzes_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."course_quizzes"
    ADD CONSTRAINT "course_quizzes_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;


--
-- Name: courses courses_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."courses"
    ADD CONSTRAINT "courses_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;


--
-- Name: courses courses_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."courses"
    ADD CONSTRAINT "courses_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: messages messages_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "public"."courses"("id") ON DELETE CASCADE;


--
-- Name: messages messages_parent_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_parent_message_id_fkey" FOREIGN KEY ("parent_message_id") REFERENCES "public"."messages"("id") ON DELETE CASCADE;


--
-- Name: messages messages_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_recipient_id_fkey" FOREIGN KEY ("recipient_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: profiles profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: quiz_attempts quiz_attempts_quiz_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."quiz_attempts"
    ADD CONSTRAINT "quiz_attempts_quiz_id_fkey" FOREIGN KEY ("quiz_id") REFERENCES "public"."course_quizzes"("id") ON DELETE CASCADE;


--
-- Name: quiz_attempts quiz_attempts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."quiz_attempts"
    ADD CONSTRAINT "quiz_attempts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: quiz_questions quiz_questions_quiz_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."quiz_questions"
    ADD CONSTRAINT "quiz_questions_quiz_id_fkey" FOREIGN KEY ("quiz_id") REFERENCES "public"."course_quizzes"("id") ON DELETE CASCADE;


--
-- Name: services services_owner_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."services"
    ADD CONSTRAINT "services_owner_fkey" FOREIGN KEY ("owner") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "public"."subscription_plans"("id") ON DELETE SET NULL;


--
-- Name: subscriptions subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: tarot_readings tarot_readings_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."tarot_readings"
    ADD CONSTRAINT "tarot_readings_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: tarot_readings tarot_readings_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."tarot_readings"
    ADD CONSTRAINT "tarot_readings_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: teacher_permissions teacher_permissions_granted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."teacher_permissions"
    ADD CONSTRAINT "teacher_permissions_granted_by_fkey" FOREIGN KEY ("granted_by") REFERENCES "auth"."users"("id");


--
-- Name: teacher_permissions teacher_permissions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."teacher_permissions"
    ADD CONSTRAINT "teacher_permissions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: user_certifications user_certifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."user_certifications"
    ADD CONSTRAINT "user_certifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."objects"
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");


--
-- Name: prefixes prefixes_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."prefixes"
    ADD CONSTRAINT "prefixes_bucketId_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."s3_multipart_uploads"
    ADD CONSTRAINT "s3_multipart_uploads_bucket_id_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."s3_multipart_uploads_parts"
    ADD CONSTRAINT "s3_multipart_uploads_parts_bucket_id_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."s3_multipart_uploads_parts"
    ADD CONSTRAINT "s3_multipart_uploads_parts_upload_id_fkey" FOREIGN KEY ("upload_id") REFERENCES "storage"."s3_multipart_uploads"("id") ON DELETE CASCADE;


--
-- Name: app_config; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."app_config" ENABLE ROW LEVEL SECURITY;

--
-- Name: bookings; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."bookings" ENABLE ROW LEVEL SECURITY;

--
-- Name: bookings bookings_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "bookings_delete" ON "app"."bookings" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: bookings bookings_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "bookings_insert" ON "app"."bookings" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: bookings bookings_owner_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "bookings_owner_insert" ON "app"."bookings" FOR INSERT WITH CHECK (("user_id" = "auth"."uid"()));


--
-- Name: bookings bookings_owner_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "bookings_owner_update" ON "app"."bookings" FOR UPDATE USING ((("user_id" = "auth"."uid"()) OR "app"."is_teacher"())) WITH CHECK ((("user_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: bookings bookings_read_own_or_teacher; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "bookings_read_own_or_teacher" ON "app"."bookings" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: bookings bookings_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "bookings_select" ON "app"."bookings" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: bookings bookings_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "bookings_update" ON "app"."bookings" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: certifications cert_read_own_or_teacher; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "cert_read_own_or_teacher" ON "app"."certifications" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: certifications cert_teacher_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "cert_teacher_insert" ON "app"."certifications" FOR INSERT WITH CHECK ("app"."is_teacher"());


--
-- Name: certificates; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."certificates" ENABLE ROW LEVEL SECURITY;

--
-- Name: certificates certificates_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "certificates_delete" ON "app"."certificates" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: certificates certificates_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "certificates_insert" ON "app"."certificates" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: certificates certificates_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "certificates_select" ON "app"."certificates" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: certificates certificates_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "certificates_update" ON "app"."certificates" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: certifications; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."certifications" ENABLE ROW LEVEL SECURITY;

--
-- Name: certifications certifications_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "certifications_delete" ON "app"."certifications" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: certifications certifications_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "certifications_insert" ON "app"."certifications" FOR INSERT WITH CHECK ((("created_by" = "auth"."uid"()) AND (EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "certifications"."course_id") AND ("c"."created_by" = "auth"."uid"()))))));


--
-- Name: certifications certifications_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "certifications_select" ON "app"."certifications" FOR SELECT USING ((("created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "certifications"."course_id") AND (COALESCE("c"."is_published", false) = true))))));


--
-- Name: certifications certifications_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "certifications_update" ON "app"."certifications" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: app_config cfg_public_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "cfg_public_read" ON "app"."app_config" FOR SELECT USING (true);


--
-- Name: courses; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."courses" ENABLE ROW LEVEL SECURITY;

--
-- Name: courses courses_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_delete" ON "app"."courses" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: courses courses_free_intro_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_free_intro_read" ON "app"."courses" FOR SELECT TO "authenticated", "anon" USING (("is_free_intro" = true));


--
-- Name: courses courses_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_insert" ON "app"."courses" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: courses courses_owner_manage; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_owner_manage" ON "app"."courses" TO "authenticated" USING ((("created_by" = "auth"."uid"()) OR "app"."is_admin"())) WITH CHECK ((("created_by" = "auth"."uid"()) OR "app"."is_admin"()));


--
-- Name: courses courses_owner_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_owner_read" ON "app"."courses" FOR SELECT TO "authenticated" USING (("created_by" = "auth"."uid"()));


--
-- Name: courses courses_owner_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_owner_update" ON "app"."courses" FOR UPDATE TO "authenticated" USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: courses courses_public_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_public_read" ON "app"."courses" FOR SELECT USING ((("is_published" = true) OR "app"."is_teacher"()));


--
-- Name: courses courses_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_select" ON "app"."courses" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: courses courses_select_or_publish; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_select_or_publish" ON "app"."courses" FOR SELECT USING ((("created_by" = "auth"."uid"()) OR (COALESCE("is_published", false) = true)));


--
-- Name: courses courses_teacher_write; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_teacher_write" ON "app"."courses" USING (("app"."is_teacher"() AND (("created_by" = "auth"."uid"()) OR "app"."is_admin"()))) WITH CHECK (("app"."is_teacher"() AND (("created_by" = "auth"."uid"()) OR "app"."is_admin"())));


--
-- Name: courses courses_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_update" ON "app"."courses" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: courses courses_write_own; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_write_own" ON "app"."courses" USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: drip_plans; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."drip_plans" ENABLE ROW LEVEL SECURITY;

--
-- Name: drip_plans drip_plans_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "drip_plans_delete" ON "app"."drip_plans" FOR DELETE USING ("app"."owns_course"("course_id"));


--
-- Name: drip_plans drip_plans_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "drip_plans_insert" ON "app"."drip_plans" FOR INSERT WITH CHECK ("app"."owns_course"("course_id"));


--
-- Name: drip_plans drip_plans_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "drip_plans_select" ON "app"."drip_plans" FOR SELECT USING ("app"."owns_course"("course_id"));


--
-- Name: drip_plans drip_plans_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "drip_plans_update" ON "app"."drip_plans" FOR UPDATE USING ("app"."owns_course"("course_id")) WITH CHECK ("app"."owns_course"("course_id"));


--
-- Name: drip_rules; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."drip_rules" ENABLE ROW LEVEL SECURITY;

--
-- Name: drip_rules drip_rules_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "drip_rules_delete" ON "app"."drip_rules" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "app"."drip_plans" "p"
  WHERE (("p"."id" = "drip_rules"."plan_id") AND "app"."owns_course"("p"."course_id")))));


--
-- Name: drip_rules drip_rules_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "drip_rules_insert" ON "app"."drip_rules" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "app"."drip_plans" "p"
  WHERE (("p"."id" = "drip_rules"."plan_id") AND "app"."owns_course"("p"."course_id")))));


--
-- Name: drip_rules drip_rules_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "drip_rules_select" ON "app"."drip_rules" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "app"."drip_plans" "p"
  WHERE (("p"."id" = "drip_rules"."plan_id") AND "app"."owns_course"("p"."course_id")))));


--
-- Name: drip_rules drip_rules_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "drip_rules_update" ON "app"."drip_rules" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "app"."drip_plans" "p"
  WHERE (("p"."id" = "drip_rules"."plan_id") AND "app"."owns_course"("p"."course_id"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "app"."drip_plans" "p"
  WHERE (("p"."id" = "drip_rules"."plan_id") AND "app"."owns_course"("p"."course_id")))));


--
-- Name: editor_styles; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."editor_styles" ENABLE ROW LEVEL SECURITY;

--
-- Name: editor_styles editor_styles_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "editor_styles_delete" ON "app"."editor_styles" FOR DELETE USING ("app"."owns_course"("course_id"));


--
-- Name: editor_styles editor_styles_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "editor_styles_insert" ON "app"."editor_styles" FOR INSERT WITH CHECK ("app"."owns_course"("course_id"));


--
-- Name: editor_styles editor_styles_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "editor_styles_select" ON "app"."editor_styles" FOR SELECT USING ("app"."owns_course"("course_id"));


--
-- Name: editor_styles editor_styles_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "editor_styles_update" ON "app"."editor_styles" FOR UPDATE USING ("app"."owns_course"("course_id")) WITH CHECK ("app"."owns_course"("course_id"));


--
-- Name: enrollments enroll_insert_self; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "enroll_insert_self" ON "app"."enrollments" FOR INSERT WITH CHECK (("user_id" = "auth"."uid"()));


--
-- Name: enrollments enroll_read_own_or_teacher; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "enroll_read_own_or_teacher" ON "app"."enrollments" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: enrollments; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."enrollments" ENABLE ROW LEVEL SECURITY;

--
-- Name: events; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."events" ENABLE ROW LEVEL SECURITY;

--
-- Name: events events_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "events_delete" ON "app"."events" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: events events_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "events_insert" ON "app"."events" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: events events_public_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "events_public_read" ON "app"."events" FOR SELECT USING ((("is_published" = true) OR "app"."is_teacher"()));


--
-- Name: events events_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "events_select" ON "app"."events" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: events events_teacher_write; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "events_teacher_write" ON "app"."events" USING ("app"."is_teacher"()) WITH CHECK ("app"."is_teacher"());


--
-- Name: events events_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "events_update" ON "app"."events" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: guest_claim_tokens; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."guest_claim_tokens" ENABLE ROW LEVEL SECURITY;

--
-- Name: lesson_media; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."lesson_media" ENABLE ROW LEVEL SECURITY;

--
-- Name: lessons; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."lessons" ENABLE ROW LEVEL SECURITY;

--
-- Name: lessons lessons_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "lessons_delete" ON "app"."lessons" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: lessons lessons_free_intro_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "lessons_free_intro_read" ON "app"."lessons" FOR SELECT TO "authenticated", "anon" USING ((EXISTS ( SELECT 1
   FROM ("app"."modules" "m"
     JOIN "app"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("m"."id" = "lessons"."module_id") AND ("c"."is_free_intro" = true)))));


--
-- Name: lessons lessons_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "lessons_insert" ON "app"."lessons" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: lessons lessons_owner_manage; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "lessons_owner_manage" ON "app"."lessons" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("app"."modules" "m"
     JOIN "app"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("m"."id" = "lessons"."module_id") AND (("c"."created_by" = "auth"."uid"()) OR "app"."is_admin"()))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM ("app"."modules" "m"
     JOIN "app"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("m"."id" = "lessons"."module_id") AND (("c"."created_by" = "auth"."uid"()) OR "app"."is_admin"())))));


--
-- Name: lessons lessons_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "lessons_read" ON "app"."lessons" FOR SELECT USING (("app"."is_teacher"() OR (EXISTS ( SELECT 1
   FROM ("app"."modules" "m"
     JOIN "app"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("m"."id" = "lessons"."module_id") AND ("c"."is_published" = true) AND (("lessons"."is_intro" = true) OR "app"."can_access_course"("auth"."uid"(), "c"."id")))))));


--
-- Name: lessons lessons_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "lessons_select" ON "app"."lessons" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: lessons lessons_teacher_write; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "lessons_teacher_write" ON "app"."lessons" USING (("app"."is_teacher"() AND (EXISTS ( SELECT 1
   FROM ("app"."modules" "m"
     JOIN "app"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("m"."id" = "lessons"."module_id") AND (("c"."created_by" = "auth"."uid"()) OR "app"."is_admin"())))))) WITH CHECK (("app"."is_teacher"() AND (EXISTS ( SELECT 1
   FROM ("app"."modules" "m"
     JOIN "app"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("m"."id" = "lessons"."module_id") AND (("c"."created_by" = "auth"."uid"()) OR "app"."is_admin"()))))));


--
-- Name: lessons lessons_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "lessons_update" ON "app"."lessons" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: magic_links; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."magic_links" ENABLE ROW LEVEL SECURITY;

--
-- Name: magic_links magic_links_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "magic_links_delete" ON "app"."magic_links" FOR DELETE USING ("app"."owns_course"("course_id"));


--
-- Name: magic_links magic_links_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "magic_links_insert" ON "app"."magic_links" FOR INSERT WITH CHECK ("app"."owns_course"("course_id"));


--
-- Name: magic_links magic_links_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "magic_links_select" ON "app"."magic_links" FOR SELECT USING ("app"."owns_course"("course_id"));


--
-- Name: magic_links magic_links_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "magic_links_update" ON "app"."magic_links" FOR UPDATE USING ("app"."owns_course"("course_id")) WITH CHECK ("app"."owns_course"("course_id"));


--
-- Name: meditations med_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "med_read" ON "app"."meditations" FOR SELECT USING ((("is_public" = true) OR ("teacher_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: meditations med_write_owner; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "med_write_owner" ON "app"."meditations" USING ((("teacher_id" = "auth"."uid"()) OR "app"."is_teacher"())) WITH CHECK ((("teacher_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: lesson_media media_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "media_read" ON "app"."lesson_media" FOR SELECT USING (("app"."is_teacher"() OR (EXISTS ( SELECT 1
   FROM (("app"."lessons" "l"
     JOIN "app"."modules" "m" ON (("m"."id" = "l"."module_id")))
     JOIN "app"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("l"."id" = "lesson_media"."lesson_id") AND ("c"."is_published" = true) AND (("l"."is_intro" = true) OR "app"."can_access_course"("auth"."uid"(), "c"."id")))))));


--
-- Name: lesson_media media_teacher_write; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "media_teacher_write" ON "app"."lesson_media" USING (("app"."is_teacher"() AND (EXISTS ( SELECT 1
   FROM (("app"."lessons" "l"
     JOIN "app"."modules" "m" ON (("m"."id" = "l"."module_id")))
     JOIN "app"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("l"."id" = "lesson_media"."lesson_id") AND (("c"."created_by" = "auth"."uid"()) OR "app"."is_admin"())))))) WITH CHECK (("app"."is_teacher"() AND (EXISTS ( SELECT 1
   FROM (("app"."lessons" "l"
     JOIN "app"."modules" "m" ON (("m"."id" = "l"."module_id")))
     JOIN "app"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("l"."id" = "lesson_media"."lesson_id") AND (("c"."created_by" = "auth"."uid"()) OR "app"."is_admin"()))))));


--
-- Name: meditations; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."meditations" ENABLE ROW LEVEL SECURITY;

--
-- Name: meditations meditations_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "meditations_delete" ON "app"."meditations" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: meditations meditations_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "meditations_insert" ON "app"."meditations" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: meditations meditations_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "meditations_select" ON "app"."meditations" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: meditations meditations_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "meditations_update" ON "app"."meditations" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: memberships memb_admin_write; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "memb_admin_write" ON "app"."memberships" USING ("app"."is_admin"()) WITH CHECK ("app"."is_admin"());


--
-- Name: memberships memb_read_own_or_admin; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "memb_read_own_or_admin" ON "app"."memberships" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR "app"."is_admin"()));


--
-- Name: memberships; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."memberships" ENABLE ROW LEVEL SECURITY;

--
-- Name: memberships memberships_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "memberships_delete" ON "app"."memberships" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: memberships memberships_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "memberships_insert" ON "app"."memberships" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: memberships memberships_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "memberships_select" ON "app"."memberships" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: memberships memberships_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "memberships_update" ON "app"."memberships" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: messages; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."messages" ENABLE ROW LEVEL SECURITY;

--
-- Name: messages messages_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "messages_delete" ON "app"."messages" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: messages messages_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "messages_insert" ON "app"."messages" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: messages messages_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "messages_read" ON "app"."messages" FOR SELECT USING ("app"."can_read_channel"("channel"));


--
-- Name: messages messages_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "messages_select" ON "app"."messages" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: messages messages_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "messages_update" ON "app"."messages" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: modules; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."modules" ENABLE ROW LEVEL SECURITY;

--
-- Name: modules modules_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "modules_delete" ON "app"."modules" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: modules modules_free_intro_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "modules_free_intro_read" ON "app"."modules" FOR SELECT TO "authenticated", "anon" USING ((EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "modules"."course_id") AND ("c"."is_free_intro" = true)))));


--
-- Name: modules modules_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "modules_insert" ON "app"."modules" FOR INSERT WITH CHECK ((("created_by" = "auth"."uid"()) AND (EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "modules"."course_id") AND ("c"."created_by" = "auth"."uid"()))))));


--
-- Name: modules modules_owner_manage; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "modules_owner_manage" ON "app"."modules" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "modules"."course_id") AND (("c"."created_by" = "auth"."uid"()) OR "app"."is_admin"()))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "modules"."course_id") AND (("c"."created_by" = "auth"."uid"()) OR "app"."is_admin"())))));


--
-- Name: modules modules_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "modules_read" ON "app"."modules" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "modules"."course_id") AND ("c"."is_published" OR "app"."is_teacher"())))));


--
-- Name: modules modules_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "modules_select" ON "app"."modules" FOR SELECT USING ((("created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "modules"."course_id") AND (COALESCE("c"."is_published", false) = true))))));


--
-- Name: modules modules_teacher_write; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "modules_teacher_write" ON "app"."modules" USING (("app"."is_teacher"() AND (EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "modules"."course_id") AND (("c"."created_by" = "auth"."uid"()) OR "app"."is_admin"())))))) WITH CHECK (("app"."is_teacher"() AND (EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "modules"."course_id") AND (("c"."created_by" = "auth"."uid"()) OR "app"."is_admin"()))))));


--
-- Name: modules modules_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "modules_update" ON "app"."modules" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: notification_jobs notif_jobs_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "notif_jobs_delete" ON "app"."notification_jobs" FOR DELETE USING ("app"."owns_course"("course_id"));


--
-- Name: notification_jobs notif_jobs_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "notif_jobs_insert" ON "app"."notification_jobs" FOR INSERT WITH CHECK ("app"."owns_course"("course_id"));


--
-- Name: notification_jobs notif_jobs_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "notif_jobs_select" ON "app"."notification_jobs" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR "app"."owns_course"("course_id")));


--
-- Name: notification_jobs notif_jobs_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "notif_jobs_update" ON "app"."notification_jobs" FOR UPDATE USING ("app"."owns_course"("course_id"));


--
-- Name: notification_templates notif_tpl_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "notif_tpl_delete" ON "app"."notification_templates" FOR DELETE USING ("app"."owns_course"("course_id"));


--
-- Name: notification_templates notif_tpl_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "notif_tpl_insert" ON "app"."notification_templates" FOR INSERT WITH CHECK ("app"."owns_course"("course_id"));


--
-- Name: notification_templates notif_tpl_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "notif_tpl_select" ON "app"."notification_templates" FOR SELECT USING ("app"."owns_course"("course_id"));


--
-- Name: notification_templates notif_tpl_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "notif_tpl_update" ON "app"."notification_templates" FOR UPDATE USING ("app"."owns_course"("course_id")) WITH CHECK ("app"."owns_course"("course_id"));


--
-- Name: notification_jobs; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."notification_jobs" ENABLE ROW LEVEL SECURITY;

--
-- Name: notification_templates; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."notification_templates" ENABLE ROW LEVEL SECURITY;

--
-- Name: orders; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."orders" ENABLE ROW LEVEL SECURITY;

--
-- Name: orders orders_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "orders_delete" ON "app"."orders" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: orders orders_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "orders_insert" ON "app"."orders" FOR INSERT WITH CHECK ((("created_by" = "auth"."uid"()) AND (EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "orders"."course_id") AND ("c"."created_by" = "auth"."uid"()))))));


--
-- Name: orders orders_insert_self; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "orders_insert_self" ON "app"."orders" FOR INSERT WITH CHECK (("user_id" = "auth"."uid"()));


--
-- Name: orders orders_read_own; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "orders_read_own" ON "app"."orders" FOR SELECT USING (("user_id" = "auth"."uid"()));


--
-- Name: orders orders_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "orders_select" ON "app"."orders" FOR SELECT USING ((("created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "orders"."course_id") AND (COALESCE("c"."is_published", false) = true))))));


--
-- Name: orders orders_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "orders_update" ON "app"."orders" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: orders orders_update_service; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "orders_update_service" ON "app"."orders" FOR UPDATE USING ("app"."is_admin"());


--
-- Name: pro_progress; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."pro_progress" ENABLE ROW LEVEL SECURITY;

--
-- Name: pro_progress pro_progress_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "pro_progress_delete" ON "app"."pro_progress" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: pro_progress pro_progress_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "pro_progress_insert" ON "app"."pro_progress" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: pro_progress pro_progress_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "pro_progress_select" ON "app"."pro_progress" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: pro_progress pro_progress_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "pro_progress_update" ON "app"."pro_progress" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: pro_requirements; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."pro_requirements" ENABLE ROW LEVEL SECURITY;

--
-- Name: pro_requirements pro_requirements_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "pro_requirements_delete" ON "app"."pro_requirements" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: pro_requirements pro_requirements_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "pro_requirements_insert" ON "app"."pro_requirements" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: pro_requirements pro_requirements_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "pro_requirements_select" ON "app"."pro_requirements" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: pro_requirements pro_requirements_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "pro_requirements_update" ON "app"."pro_requirements" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: profiles; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."profiles" ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles profiles_admin_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "profiles_admin_update" ON "app"."profiles" FOR UPDATE USING ("app"."is_admin"()) WITH CHECK ("app"."is_admin"());


--
-- Name: profiles profiles_insert_self; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "profiles_insert_self" ON "app"."profiles" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));


--
-- Name: profiles profiles_read_own_or_admin; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "profiles_read_own_or_admin" ON "app"."profiles" FOR SELECT USING ((("auth"."uid"() = "user_id") OR "app"."is_teacher"()));


--
-- Name: profiles profiles_update_own; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "profiles_update_own" ON "app"."profiles" FOR UPDATE USING (("auth"."uid"() = "user_id"));


--
-- Name: purchases; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."purchases" ENABLE ROW LEVEL SECURITY;

--
-- Name: purchases purchases_owner_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "purchases_owner_select" ON "app"."purchases" FOR SELECT USING (("auth"."uid"() = "user_id"));


--
-- Name: services; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."services" ENABLE ROW LEVEL SECURITY;

--
-- Name: services services_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "services_delete" ON "app"."services" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: services services_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "services_insert" ON "app"."services" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: services services_owner_write; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "services_owner_write" ON "app"."services" USING ((("provider_id" = "auth"."uid"()) OR "app"."is_teacher"())) WITH CHECK ((("provider_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: services services_public_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "services_public_read" ON "app"."services" FOR SELECT USING ((("is_active" = true) OR "app"."is_teacher"()));


--
-- Name: services services_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "services_select" ON "app"."services" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: services services_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "services_update" ON "app"."services" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: teacher_slots slots_read_teacher_or_public_future; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "slots_read_teacher_or_public_future" ON "app"."teacher_slots" FOR SELECT USING (("app"."is_teacher"() OR (("is_booked" = false) AND ("starts_at" > "now"()))));


--
-- Name: teacher_slots slots_teacher_write; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "slots_teacher_write" ON "app"."teacher_slots" USING ((("teacher_id" = "auth"."uid"()) OR "app"."is_teacher"())) WITH CHECK ((("teacher_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: tarot_requests tarot_insert_requester; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tarot_insert_requester" ON "app"."tarot_requests" FOR INSERT WITH CHECK (("requester_id" = "auth"."uid"()));


--
-- Name: tarot_requests tarot_read_parties; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tarot_read_parties" ON "app"."tarot_requests" FOR SELECT USING ((("requester_id" = "auth"."uid"()) OR ("reader_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: tarot_requests; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."tarot_requests" ENABLE ROW LEVEL SECURITY;

--
-- Name: tarot_requests tarot_requests_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tarot_requests_delete" ON "app"."tarot_requests" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: tarot_requests tarot_requests_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tarot_requests_insert" ON "app"."tarot_requests" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: tarot_requests tarot_requests_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tarot_requests_select" ON "app"."tarot_requests" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: tarot_requests tarot_requests_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tarot_requests_update" ON "app"."tarot_requests" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: tarot_requests tarot_update_parties; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tarot_update_parties" ON "app"."tarot_requests" FOR UPDATE USING ((("requester_id" = "auth"."uid"()) OR ("reader_id" = "auth"."uid"()) OR "app"."is_teacher"())) WITH CHECK ((("requester_id" = "auth"."uid"()) OR ("reader_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: teacher_directory tdir_admin_write; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tdir_admin_write" ON "app"."teacher_directory" USING ("app"."is_admin"()) WITH CHECK ("app"."is_admin"());


--
-- Name: teacher_directory tdir_public_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tdir_public_read" ON "app"."teacher_directory" FOR SELECT USING (true);


--
-- Name: teacher_approvals; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."teacher_approvals" ENABLE ROW LEVEL SECURITY;

--
-- Name: teacher_approvals teacher_approvals_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "teacher_approvals_delete" ON "app"."teacher_approvals" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: teacher_approvals teacher_approvals_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "teacher_approvals_insert" ON "app"."teacher_approvals" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: teacher_approvals teacher_approvals_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "teacher_approvals_select" ON "app"."teacher_approvals" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: teacher_approvals teacher_approvals_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "teacher_approvals_update" ON "app"."teacher_approvals" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: teacher_directory; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."teacher_directory" ENABLE ROW LEVEL SECURITY;

--
-- Name: teacher_permissions; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."teacher_permissions" ENABLE ROW LEVEL SECURITY;

--
-- Name: teacher_requests; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."teacher_requests" ENABLE ROW LEVEL SECURITY;

--
-- Name: teacher_slots; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."teacher_slots" ENABLE ROW LEVEL SECURITY;

--
-- Name: teacher_permissions tp_delete_own; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tp_delete_own" ON "app"."teacher_permissions" FOR DELETE TO "authenticated" USING (("profile_id" = ( SELECT "auth"."uid"() AS "uid")));


--
-- Name: teacher_permissions tp_insert_own; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tp_insert_own" ON "app"."teacher_permissions" FOR INSERT TO "authenticated" WITH CHECK (("profile_id" = ( SELECT "auth"."uid"() AS "uid")));


--
-- Name: teacher_permissions tp_select_own; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tp_select_own" ON "app"."teacher_permissions" FOR SELECT TO "authenticated" USING (("profile_id" = ( SELECT "auth"."uid"() AS "uid")));


--
-- Name: teacher_permissions tp_update_own; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tp_update_own" ON "app"."teacher_permissions" FOR UPDATE TO "authenticated" USING (("profile_id" = ( SELECT "auth"."uid"() AS "uid"))) WITH CHECK (("profile_id" = ( SELECT "auth"."uid"() AS "uid")));


--
-- Name: teacher_requests treq_admin_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "treq_admin_update" ON "app"."teacher_requests" FOR UPDATE USING ("app"."is_admin"()) WITH CHECK ("app"."is_admin"());


--
-- Name: teacher_requests treq_owner_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "treq_owner_insert" ON "app"."teacher_requests" FOR INSERT WITH CHECK (("user_id" = "auth"."uid"()));


--
-- Name: teacher_requests treq_read_owner_or_admin; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "treq_read_owner_or_admin" ON "app"."teacher_requests" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."audit_log_entries" ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."flow_state" ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."identities" ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."instances" ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."mfa_amr_claims" ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."mfa_challenges" ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."mfa_factors" ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."one_time_tokens" ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."refresh_tokens" ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."saml_providers" ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."saml_relay_states" ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."schema_migrations" ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."sessions" ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."sso_domains" ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."sso_providers" ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."users" ENABLE ROW LEVEL SECURITY;

--
-- Name: bookings Admins can manage all bookings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all bookings" ON "public"."bookings" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: courses Admins can manage all courses; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all courses" ON "public"."courses" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: course_enrollments Admins can manage all enrollments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all enrollments" ON "public"."course_enrollments" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: lesson_media Admins can manage all lesson media; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all lesson media" ON "public"."lesson_media" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: lessons Admins can manage all lessons; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all lessons" ON "public"."lessons" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: modules Admins can manage all modules; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all modules" ON "public"."modules" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: public_teacher_info Admins can manage all public teacher info; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all public teacher info" ON "public"."public_teacher_info" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: user_roles Admins can manage all roles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all roles" ON "public"."user_roles" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: teacher_directory Admins can manage all teacher directory entries; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all teacher directory entries" ON "public"."teacher_directory" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: teacher_requests Admins can manage all teacher requests; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all teacher requests" ON "public"."teacher_requests" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: tarot_readings Admins can view all readings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all readings" ON "public"."tarot_readings" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: availability_slots Admins can view all slots; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all slots" ON "public"."availability_slots" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: lessons Anyone can view free preview lessons; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view free preview lessons" ON "public"."lessons" FOR SELECT USING ((("free_preview" = true) AND (EXISTS ( SELECT 1
   FROM ("public"."modules" "m"
     JOIN "public"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("m"."id" = "lessons"."module_id") AND ("c"."is_published" = true))))));


--
-- Name: public_teacher_info Anyone can view public teacher info; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view public teacher info" ON "public"."public_teacher_info" FOR SELECT USING (true);


--
-- Name: modules Anyone can view published course modules; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view published course modules" ON "public"."modules" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."courses"
  WHERE (("courses"."id" = "modules"."course_id") AND ("courses"."is_published" = true)))));


--
-- Name: teacher_directory Anyone can view teacher directory; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view teacher directory" ON "public"."teacher_directory" FOR SELECT USING (true);


--
-- Name: lessons Enrolled students can view lessons; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enrolled students can view lessons" ON "public"."lessons" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM (("public"."modules" "m"
     JOIN "public"."courses" "c" ON (("c"."id" = "m"."course_id")))
     JOIN "public"."course_enrollments" "ce" ON (("ce"."course_id" = "c"."id")))
  WHERE (("m"."id" = "lessons"."module_id") AND ("ce"."student_id" = "auth"."uid"()) AND ("ce"."status" = 'active'::"text")))));


--
-- Name: courses Everyone can view published courses; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Everyone can view published courses" ON "public"."courses" FOR SELECT USING ((("is_published" = true) OR ("auth"."uid"() = "teacher_id")));


--
-- Name: bookings Students can create bookings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Students can create bookings" ON "public"."bookings" FOR INSERT WITH CHECK (("auth"."uid"() = "student_id"));


--
-- Name: tarot_readings Students can create readings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Students can create readings" ON "public"."tarot_readings" FOR INSERT WITH CHECK (("auth"."uid"() = "student_id"));


--
-- Name: course_enrollments Students can enroll themselves; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Students can enroll themselves" ON "public"."course_enrollments" FOR INSERT WITH CHECK (("auth"."uid"() = "student_id"));


--
-- Name: bookings Students can update their bookings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Students can update their bookings" ON "public"."bookings" FOR UPDATE USING (("auth"."uid"() = "student_id"));


--
-- Name: availability_slots Students can view available slots; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Students can view available slots" ON "public"."availability_slots" FOR SELECT USING (("auth"."uid"() IS NOT NULL));


--
-- Name: bookings Students can view their bookings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Students can view their bookings" ON "public"."bookings" FOR SELECT USING (("auth"."uid"() = "student_id"));


--
-- Name: course_enrollments Students can view their enrollments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Students can view their enrollments" ON "public"."course_enrollments" FOR SELECT USING (("auth"."uid"() = "student_id"));


--
-- Name: tarot_readings Students can view their own readings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Students can view their own readings" ON "public"."tarot_readings" FOR SELECT USING (("auth"."uid"() = "student_id"));


--
-- Name: public_teacher_info Teachers can insert their own public info; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can insert their own public info" ON "public"."public_teacher_info" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));


--
-- Name: course_enrollments Teachers can manage enrollments in their courses; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can manage enrollments in their courses" ON "public"."course_enrollments" USING ((EXISTS ( SELECT 1
   FROM "public"."courses"
  WHERE (("courses"."id" = "course_enrollments"."course_id") AND ("courses"."teacher_id" = "auth"."uid"())))));


--
-- Name: lesson_media Teachers can manage media for their lessons; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can manage media for their lessons" ON "public"."lesson_media" USING ((EXISTS ( SELECT 1
   FROM (("public"."lessons" "l"
     JOIN "public"."modules" "m" ON (("m"."id" = "l"."module_id")))
     JOIN "public"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("l"."id" = "lesson_media"."lesson_id") AND ("c"."teacher_id" = "auth"."uid"())))));


--
-- Name: courses Teachers can manage their courses; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can manage their courses" ON "public"."courses" USING (("auth"."uid"() = "teacher_id"));


--
-- Name: lessons Teachers can manage their own course lessons; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can manage their own course lessons" ON "public"."lessons" USING ((EXISTS ( SELECT 1
   FROM ("public"."modules" "m"
     JOIN "public"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("m"."id" = "lessons"."module_id") AND ("c"."teacher_id" = "auth"."uid"())))));


--
-- Name: modules Teachers can manage their own course modules; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can manage their own course modules" ON "public"."modules" USING ((EXISTS ( SELECT 1
   FROM "public"."courses"
  WHERE (("courses"."id" = "modules"."course_id") AND ("courses"."teacher_id" = "auth"."uid"())))));


--
-- Name: teacher_directory Teachers can manage their own directory entry; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can manage their own directory entry" ON "public"."teacher_directory" USING (("auth"."uid"() = "user_id"));


--
-- Name: availability_slots Teachers can manage their slots; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can manage their slots" ON "public"."availability_slots" USING (("auth"."uid"() = "teacher_id"));


--
-- Name: tarot_readings Teachers can update assigned readings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can update assigned readings" ON "public"."tarot_readings" FOR UPDATE USING (("auth"."uid"() = "teacher_id"));


--
-- Name: bookings Teachers can update their bookings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can update their bookings" ON "public"."bookings" FOR UPDATE USING (("auth"."uid"() = "teacher_id"));


--
-- Name: public_teacher_info Teachers can update their own public info; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can update their own public info" ON "public"."public_teacher_info" FOR UPDATE USING (("auth"."uid"() = "user_id"));


--
-- Name: tarot_readings Teachers can view assigned readings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can view assigned readings" ON "public"."tarot_readings" FOR SELECT USING (("auth"."uid"() = "teacher_id"));


--
-- Name: course_enrollments Teachers can view enrollments in their courses; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can view enrollments in their courses" ON "public"."course_enrollments" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."courses"
  WHERE (("courses"."id" = "course_enrollments"."course_id") AND ("courses"."teacher_id" = "auth"."uid"())))));


--
-- Name: bookings Teachers can view their bookings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can view their bookings" ON "public"."bookings" FOR SELECT USING (("auth"."uid"() = "teacher_id"));


--
-- Name: teacher_requests Users can create their own teacher requests; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can create their own teacher requests" ON "public"."teacher_requests" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));


--
-- Name: profiles Users can insert their own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can insert their own profile" ON "public"."profiles" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));


--
-- Name: profiles Users can only view their own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can only view their own profile" ON "public"."profiles" FOR SELECT USING (("auth"."uid"() = "user_id"));


--
-- Name: messages Users can send messages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can send messages" ON "public"."messages" FOR INSERT WITH CHECK (("auth"."uid"() = "sender_id"));


--
-- Name: messages Users can update their messages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their messages" ON "public"."messages" FOR UPDATE USING (("auth"."uid"() = "sender_id"));


--
-- Name: notifications Users can update their notifications; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their notifications" ON "public"."notifications" FOR UPDATE USING (("auth"."uid"() = "user_id"));


--
-- Name: profiles Users can update their own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their own profile" ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "user_id"));


--
-- Name: lesson_media Users can view public media; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view public media" ON "public"."lesson_media" FOR SELECT USING (("is_public" = true));


--
-- Name: messages Users can view their messages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their messages" ON "public"."messages" FOR SELECT USING ((("auth"."uid"() = "sender_id") OR ("auth"."uid"() = "recipient_id") OR (("course_id" IS NOT NULL) AND ((EXISTS ( SELECT 1
   FROM "public"."course_enrollments"
  WHERE (("course_enrollments"."course_id" = "messages"."course_id") AND ("course_enrollments"."student_id" = "auth"."uid"()) AND ("course_enrollments"."status" = 'active'::"text")))) OR (EXISTS ( SELECT 1
   FROM "public"."courses"
  WHERE (("courses"."id" = "messages"."course_id") AND ("courses"."teacher_id" = "auth"."uid"()))))))));


--
-- Name: notifications Users can view their notifications; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their notifications" ON "public"."notifications" FOR SELECT USING (("auth"."uid"() = "user_id"));


--
-- Name: user_roles Users can view their own roles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own roles" ON "public"."user_roles" FOR SELECT USING (("auth"."uid"() = "user_id"));


--
-- Name: teacher_requests Users can view their own teacher requests; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own teacher requests" ON "public"."teacher_requests" FOR SELECT USING (("auth"."uid"() = "user_id"));


--
-- Name: admin_keys; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."admin_keys" ENABLE ROW LEVEL SECURITY;

--
-- Name: availability_slots; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."availability_slots" ENABLE ROW LEVEL SECURITY;

--
-- Name: bookings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."bookings" ENABLE ROW LEVEL SECURITY;

--
-- Name: certificates cert insert teacher; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cert insert teacher" ON "public"."certificates" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."teacher_permissions"
  WHERE ("teacher_permissions"."user_id" = "auth"."uid"()))));


--
-- Name: certificates cert read own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cert read own" ON "public"."certificates" FOR SELECT USING (("user_id" = "auth"."uid"()));


--
-- Name: user_certifications cert read own/admin; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cert read own/admin" ON "public"."user_certifications" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text"))))));


--
-- Name: user_certifications cert write own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cert write own" ON "public"."user_certifications" USING (("user_id" = "auth"."uid"())) WITH CHECK (("user_id" = "auth"."uid"()));


--
-- Name: certificates cert_select_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cert_select_own" ON "public"."certificates" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));


--
-- Name: certificates cert_teacher_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cert_teacher_insert" ON "public"."certificates" FOR INSERT TO "authenticated" WITH CHECK ("public"."user_is_teacher"());


--
-- Name: certificates; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."certificates" ENABLE ROW LEVEL SECURITY;

--
-- Name: course_modules cm read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cm read" ON "public"."course_modules" FOR SELECT USING (true);


--
-- Name: course_modules cm write teacher; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cm write teacher" ON "public"."course_modules" USING ((EXISTS ( SELECT 1
   FROM "public"."teacher_permissions"
  WHERE ("teacher_permissions"."user_id" = "auth"."uid"())))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."teacher_permissions"
  WHERE ("teacher_permissions"."user_id" = "auth"."uid"()))));


--
-- Name: course_modules cm_select_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cm_select_all" ON "public"."course_modules" FOR SELECT USING (true);


--
-- Name: course_modules cm_teacher_write; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cm_teacher_write" ON "public"."course_modules" TO "authenticated" USING ("public"."user_is_teacher"()) WITH CHECK ("public"."user_is_teacher"());


--
-- Name: coupons; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."coupons" ENABLE ROW LEVEL SECURITY;

--
-- Name: coupons coupons admin delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "coupons admin delete" ON "public"."coupons" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text")))));


--
-- Name: coupons coupons admin insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "coupons admin insert" ON "public"."coupons" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text")))));


--
-- Name: coupons coupons admin select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "coupons admin select" ON "public"."coupons" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text")))));


--
-- Name: coupons coupons admin update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "coupons admin update" ON "public"."coupons" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text"))))) WITH CHECK (true);


--
-- Name: course_enrollments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."course_enrollments" ENABLE ROW LEVEL SECURITY;

--
-- Name: course_modules; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."course_modules" ENABLE ROW LEVEL SECURITY;

--
-- Name: course_quizzes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."course_quizzes" ENABLE ROW LEVEL SECURITY;

--
-- Name: courses; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."courses" ENABLE ROW LEVEL SECURITY;

--
-- Name: courses courses delete own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "courses delete own" ON "public"."courses" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: courses courses insert teacher; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "courses insert teacher" ON "public"."courses" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."teacher_permissions" "t"
  WHERE ("t"."user_id" = "auth"."uid"()))));


--
-- Name: courses courses read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "courses read" ON "public"."courses" FOR SELECT USING (true);


--
-- Name: courses courses update own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "courses update own" ON "public"."courses" FOR UPDATE USING (("created_by" = "auth"."uid"()));


--
-- Name: course_quizzes cq_select_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cq_select_all" ON "public"."course_quizzes" FOR SELECT USING (true);


--
-- Name: course_quizzes cq_teacher_write; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cq_teacher_write" ON "public"."course_quizzes" TO "authenticated" USING ("public"."user_is_teacher"()) WITH CHECK ("public"."user_is_teacher"());


--
-- Name: admin_keys keys admin insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "keys admin insert" ON "public"."admin_keys" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text")))));


--
-- Name: admin_keys keys admin select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "keys admin select" ON "public"."admin_keys" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text")))));


--
-- Name: admin_keys keys admin update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "keys admin update" ON "public"."admin_keys" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text"))))) WITH CHECK (true);


--
-- Name: lesson_media; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."lesson_media" ENABLE ROW LEVEL SECURITY;

--
-- Name: lessons; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."lessons" ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."messages" ENABLE ROW LEVEL SECURITY;

--
-- Name: modules; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."modules" ENABLE ROW LEVEL SECURITY;

--
-- Name: notifications; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;

--
-- Name: subscription_plans plans read all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "plans read all" ON "public"."subscription_plans" FOR SELECT USING (true);


--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles profiles read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "profiles read" ON "public"."profiles" FOR SELECT USING (true);


--
-- Name: profiles profiles update own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "profiles update own" ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "id")) WITH CHECK (("auth"."uid"() = "id"));


--
-- Name: public_teacher_info; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."public_teacher_info" ENABLE ROW LEVEL SECURITY;

--
-- Name: quiz_attempts qa insert self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "qa insert self" ON "public"."quiz_attempts" FOR INSERT WITH CHECK (("user_id" = "auth"."uid"()));


--
-- Name: quiz_attempts qa read own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "qa read own" ON "public"."quiz_attempts" FOR SELECT USING (("user_id" = "auth"."uid"()));


--
-- Name: quiz_attempts qa_insert_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "qa_insert_own" ON "public"."quiz_attempts" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));


--
-- Name: quiz_attempts qa_select_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "qa_select_own" ON "public"."quiz_attempts" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));


--
-- Name: quiz_questions qq read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "qq read" ON "public"."quiz_questions" FOR SELECT USING (true);


--
-- Name: quiz_questions qq write teacher; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "qq write teacher" ON "public"."quiz_questions" USING ((EXISTS ( SELECT 1
   FROM "public"."teacher_permissions"
  WHERE ("teacher_permissions"."user_id" = "auth"."uid"())))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."teacher_permissions"
  WHERE ("teacher_permissions"."user_id" = "auth"."uid"()))));


--
-- Name: quiz_questions qq_select_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "qq_select_all" ON "public"."quiz_questions" FOR SELECT USING (true);


--
-- Name: quiz_questions qq_teacher_write; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "qq_teacher_write" ON "public"."quiz_questions" TO "authenticated" USING ("public"."user_is_teacher"()) WITH CHECK ("public"."user_is_teacher"());


--
-- Name: course_quizzes quiz read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "quiz read" ON "public"."course_quizzes" FOR SELECT USING (true);


--
-- Name: course_quizzes quiz write teacher; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "quiz write teacher" ON "public"."course_quizzes" USING ((EXISTS ( SELECT 1
   FROM "public"."teacher_permissions"
  WHERE ("teacher_permissions"."user_id" = "auth"."uid"())))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."teacher_permissions"
  WHERE ("teacher_permissions"."user_id" = "auth"."uid"()))));


--
-- Name: quiz_attempts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."quiz_attempts" ENABLE ROW LEVEL SECURITY;

--
-- Name: quiz_questions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."quiz_questions" ENABLE ROW LEVEL SECURITY;

--
-- Name: services; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."services" ENABLE ROW LEVEL SECURITY;

--
-- Name: services services read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "services read" ON "public"."services" FOR SELECT USING (true);


--
-- Name: services services write own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "services write own" ON "public"."services" USING (("owner" = "auth"."uid"())) WITH CHECK (("owner" = "auth"."uid"()));


--
-- Name: subscriptions subs nobody delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "subs nobody delete" ON "public"."subscriptions" FOR DELETE USING (false);


--
-- Name: subscriptions subs nobody insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "subs nobody insert" ON "public"."subscriptions" FOR INSERT WITH CHECK (false);


--
-- Name: subscriptions subs nobody update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "subs nobody update" ON "public"."subscriptions" FOR UPDATE USING (false) WITH CHECK (false);


--
-- Name: subscriptions subs read own/admin; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "subs read own/admin" ON "public"."subscriptions" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text"))))));


--
-- Name: subscription_plans; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."subscription_plans" ENABLE ROW LEVEL SECURITY;

--
-- Name: subscriptions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."subscriptions" ENABLE ROW LEVEL SECURITY;

--
-- Name: tarot_readings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."tarot_readings" ENABLE ROW LEVEL SECURITY;

--
-- Name: teacher_permissions teacher admin delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "teacher admin delete" ON "public"."teacher_permissions" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text")))));


--
-- Name: teacher_permissions teacher admin insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "teacher admin insert" ON "public"."teacher_permissions" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text")))));


--
-- Name: teacher_permissions teacher read own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "teacher read own" ON "public"."teacher_permissions" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text"))))));


--
-- Name: teacher_directory; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."teacher_directory" ENABLE ROW LEVEL SECURITY;

--
-- Name: teacher_permissions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."teacher_permissions" ENABLE ROW LEVEL SECURITY;

--
-- Name: teacher_requests; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."teacher_requests" ENABLE ROW LEVEL SECURITY;

--
-- Name: user_certifications; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."user_certifications" ENABLE ROW LEVEL SECURITY;

--
-- Name: user_roles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."user_roles" ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: -
--

ALTER TABLE "realtime"."messages" ENABLE ROW LEVEL SECURITY;

--
-- Name: objects Authenticated users can upload to their own folder in public-me; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "Authenticated users can upload to their own folder in public-me" ON "storage"."objects" FOR INSERT WITH CHECK ((("bucket_id" = 'public-media'::"text") AND (("auth"."uid"())::"text" = ("storage"."foldername"("name"))[1])));


--
-- Name: objects Public media is readable by everyone; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "Public media is readable by everyone" ON "storage"."objects" FOR SELECT USING (("bucket_id" = 'public-media'::"text"));


--
-- Name: objects SELECT 1r7zrx6_0; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "SELECT 1r7zrx6_0" ON "storage"."objects" FOR SELECT USING (("bucket_id" = 'media'::"text"));


--
-- Name: objects Users can delete their own files in public-media; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "Users can delete their own files in public-media" ON "storage"."objects" FOR DELETE USING ((("bucket_id" = 'public-media'::"text") AND (("auth"."uid"())::"text" = ("storage"."foldername"("name"))[1])));


--
-- Name: objects Users can update their own files in public-media; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "Users can update their own files in public-media" ON "storage"."objects" FOR UPDATE USING ((("bucket_id" = 'public-media'::"text") AND (("auth"."uid"())::"text" = ("storage"."foldername"("name"))[1])));


--
-- Name: objects avatars public read; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "avatars public read" ON "storage"."objects" FOR SELECT TO "authenticated", "anon" USING (("bucket_id" = 'avatars'::"text"));


--
-- Name: objects avatars user delete; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "avatars user delete" ON "storage"."objects" FOR DELETE TO "authenticated" USING ((("bucket_id" = 'avatars'::"text") AND ("owner" = "auth"."uid"())));


--
-- Name: objects avatars user insert; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "avatars user insert" ON "storage"."objects" FOR INSERT TO "authenticated" WITH CHECK ((("bucket_id" = 'avatars'::"text") AND ("owner" = "auth"."uid"())));


--
-- Name: objects avatars user update; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "avatars user update" ON "storage"."objects" FOR UPDATE TO "authenticated" USING ((("bucket_id" = 'avatars'::"text") AND ("owner" = "auth"."uid"())));


--
-- Name: objects avatars_read; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "avatars_read" ON "storage"."objects" FOR SELECT USING (("bucket_id" = 'avatars'::"text"));


--
-- Name: objects avatars_write; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "avatars_write" ON "storage"."objects" USING ((("bucket_id" = 'avatars'::"text") AND ("split_part"("name", '/'::"text", 1) = ("auth"."uid"())::"text"))) WITH CHECK ((("bucket_id" = 'avatars'::"text") AND ("split_part"("name", '/'::"text", 1) = ("auth"."uid"())::"text")));


--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE "storage"."buckets" ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE "storage"."buckets_analytics" ENABLE ROW LEVEL SECURITY;

--
-- Name: objects course-media read; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "course-media read" ON "storage"."objects" FOR SELECT USING (("bucket_id" = 'course-media'::"text"));


--
-- Name: objects course-media teacher write; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "course-media teacher write" ON "storage"."objects" USING ((("bucket_id" = 'course-media'::"text") AND (EXISTS ( SELECT 1
   FROM "public"."teacher_permissions"
  WHERE ("teacher_permissions"."user_id" = "auth"."uid"()))))) WITH CHECK ((("bucket_id" = 'course-media'::"text") AND (EXISTS ( SELECT 1
   FROM "public"."teacher_permissions"
  WHERE ("teacher_permissions"."user_id" = "auth"."uid"())))));


--
-- Name: objects course_media_public_read; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "course_media_public_read" ON "storage"."objects" FOR SELECT USING (("bucket_id" = 'course-media'::"text"));


--
-- Name: objects course_media_read; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "course_media_read" ON "storage"."objects" FOR SELECT USING ((("bucket_id" = 'course-media'::"text") AND (EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE ((("c"."id")::"text" = "split_part"("objects"."name", '/'::"text", 1)) AND (("c"."is_published" = true) OR ("c"."created_by" = "auth"."uid"())))))));


--
-- Name: objects course_media_teacher_write; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "course_media_teacher_write" ON "storage"."objects" TO "authenticated" USING ((("bucket_id" = 'course-media'::"text") AND "public"."user_is_teacher"())) WITH CHECK ((("bucket_id" = 'course-media'::"text") AND "public"."user_is_teacher"()));


--
-- Name: objects course_media_write; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "course_media_write" ON "storage"."objects" FOR INSERT WITH CHECK ((("bucket_id" = 'course-media'::"text") AND (EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE ((("c"."id")::"text" = "split_part"("objects"."name", '/'::"text", 1)) AND ("c"."created_by" = "auth"."uid"()))))));


--
-- Name: objects media_teacher_update; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "media_teacher_update" ON "storage"."objects" FOR UPDATE USING ((("bucket_id" = 'media'::"text") AND "app"."is_teacher"())) WITH CHECK ((("bucket_id" = 'media'::"text") AND "app"."is_teacher"()));


--
-- Name: objects media_teacher_write; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "media_teacher_write" ON "storage"."objects" FOR INSERT WITH CHECK ((("bucket_id" = 'media'::"text") AND "app"."is_teacher"()));


--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE "storage"."migrations" ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE "storage"."objects" ENABLE ROW LEVEL SECURITY;

--
-- Name: prefixes; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE "storage"."prefixes" ENABLE ROW LEVEL SECURITY;

--
-- Name: objects public read media; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "public read media" ON "storage"."objects" FOR SELECT TO "authenticated", "anon" USING (("bucket_id" = 'media'::"text"));


--
-- Name: objects public-assets admin write; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "public-assets admin write" ON "storage"."objects" USING ((("bucket_id" = 'public-assets'::"text") AND (EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text")))))) WITH CHECK ((("bucket_id" = 'public-assets'::"text") AND (EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text"))))));


--
-- Name: objects public-assets read; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "public-assets read" ON "storage"."objects" FOR SELECT USING (("bucket_id" = 'public-assets'::"text"));


--
-- Name: objects public_assets_read; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "public_assets_read" ON "storage"."objects" FOR SELECT USING (("bucket_id" = 'public-assets'::"text"));


--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE "storage"."s3_multipart_uploads" ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE "storage"."s3_multipart_uploads_parts" ENABLE ROW LEVEL SECURITY;

--
-- Name: objects update to authenticated 1prfdz4_0; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "update to authenticated 1prfdz4_0" ON "storage"."objects" FOR UPDATE TO "authenticated" USING ((("bucket_id" = 'media'::"text") AND "app"."is_teacher_uid"("auth"."uid"())));


--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION "supabase_realtime" WITH (publish = 'insert, update, delete, truncate');


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER "issue_graphql_placeholder" ON "sql_drop"
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION "extensions"."set_graphql_placeholder"();


--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER "issue_pg_cron_access" ON "ddl_command_end"
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION "extensions"."grant_pg_cron_access"();


--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER "issue_pg_graphql_access" ON "ddl_command_end"
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION "extensions"."grant_pg_graphql_access"();


--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER "issue_pg_net_access" ON "ddl_command_end"
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION "extensions"."grant_pg_net_access"();


--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER "pgrst_ddl_watch" ON "ddl_command_end"
   EXECUTE FUNCTION "extensions"."pgrst_ddl_watch"();


--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER "pgrst_drop_watch" ON "sql_drop"
   EXECUTE FUNCTION "extensions"."pgrst_drop_watch"();


--
-- PostgreSQL database dump complete
--

\unrestrict cdlzQCxDBpGicOhH3GqnsdIkodSbiHPSijOzQ4U4g3mZICk9BRz3fZcmszKDzAO

