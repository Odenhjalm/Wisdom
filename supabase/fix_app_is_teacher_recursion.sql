-- Break recursive RLS lookups by hardening app role helpers (idempotent)

begin;

create or replace function app.is_admin()
returns boolean
language plpgsql
stable
security definer
set search_path = app, public
as $$
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

create or replace function app.is_teacher()
returns boolean
language plpgsql
stable
security definer
set search_path = app, public
as $$
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

  if to_regclass('app.profiles') is not null then
    v_old_rowsec := coalesce(current_setting('row_security', true), 'on');
    perform set_config('row_security', 'off', true);
    begin
      if exists (
        select 1
        from app.profiles p
        where p.user_id = auth.uid()
          and (p.role_v2 = 'teacher' or coalesce(p.is_admin, false) = true)
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

create or replace function app.current_role()
returns app.role_type
language plpgsql
stable
security definer
set search_path = app, public
as $$
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
      else
        return 'user';
      end if;
    end if;
  end if;

  return 'user';
end;
$$;

commit;
