-- =====================================================================
-- Visdom • Enforce Free Intro Quota via RPC (idempotent)
-- Schema: app
-- Adds RPC enroll_free_intro(p_course_id) that validates free limit.
-- =====================================================================

begin;

create or replace function app.enroll_free_intro(p_course_id uuid)
returns void language plpgsql security definer as $$
declare
  v_user uuid := auth.uid();
  v_is_intro boolean := false;
  v_limit int := 5;
  v_used int := 0;
  v_already boolean := false;
begin
  if v_user is null then
    raise exception 'Not authenticated';
  end if;

  select is_free_intro into v_is_intro from app.courses where id = p_course_id;
  if coalesce(v_is_intro, false) = false then
    raise exception 'Course is not marked as free intro';
  end if;

  select coalesce(free_course_limit, 5) into v_limit from app.app_config where id = 1;

  select exists(
    select 1 from app.enrollments e where e.user_id = v_user and e.course_id = p_course_id
  ) into v_already;

  if not v_already then
    select app.free_consumed_count(v_user) into v_used;
    if v_used >= v_limit then
      raise exception 'Free intro limit reached (%).', v_limit;
    end if;
  end if;

  insert into app.enrollments(user_id, course_id, source)
  values (v_user, p_course_id, 'free_intro')
  on conflict (user_id, course_id) do update set source = excluded.source;
end; $$;

grant execute on function app.enroll_free_intro(uuid) to authenticated;

commit;

