-- =====================================================================
-- Visdom • Gate teacher approval on verified certificates (idempotent)
-- Schema: app
-- Replaces/creates RPC approve_teacher to require >=1 verified certificate.
-- =====================================================================

begin;

create or replace function app.approve_teacher(p_user uuid)
returns void language plpgsql security definer as $$
declare v_cnt int;
begin
  if p_user is null then
    raise exception 'User is required';
  end if;
  select count(*) into v_cnt from app.certificates c where c.user_id = p_user and c.verified = true;
  if coalesce(v_cnt,0) < 1 then
    raise exception 'User requires at least one verified certificate to become teacher';
  end if;
  update app.profiles set role = 'teacher', updated_at = now() where user_id = p_user;
end; $$;

create or replace function app.reject_teacher(p_user uuid)
returns void language plpgsql security definer as $$
begin
  update app.profiles set role = 'user', updated_at = now() where user_id = p_user;
end; $$;

grant execute on function app.approve_teacher(uuid) to authenticated;
grant execute on function app.reject_teacher(uuid) to authenticated;

commit;

