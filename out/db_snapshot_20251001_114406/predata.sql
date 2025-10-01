--
-- PostgreSQL database dump
--

\restrict salLJyVEY6MHu1xMpk65wLNXXee93YkfupbwyZufSBT1zfFxFIWXtslAWiABYjy

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
-- PostgreSQL database dump complete
--

\unrestrict salLJyVEY6MHu1xMpk65wLNXXee93YkfupbwyZufSBT1zfFxFIWXtslAWiABYjy

