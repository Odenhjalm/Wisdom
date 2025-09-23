-- Refresh app.ensure_profile to avoid auth.users dependency (idempotent)

begin;

create or replace function app.ensure_profile(
  p_email text default null,
  p_display_name text default null
) returns app.profiles
language plpgsql
security definer
set search_path = app, public
as $$
declare
  v_user uuid := auth.uid();
  v_row app.profiles;
  v_claim jsonb := auth.jwt();
  v_mail text;
  v_name text;
begin
  if v_user is null then
    raise exception 'Not authenticated';
  end if;

  if v_claim ? 'email' then
    v_mail := v_claim ->> 'email';
  elsif v_claim ? 'user' and (v_claim -> 'user') ? 'email' then
    v_mail := v_claim -> 'user' ->> 'email';
  end if;

  v_mail := nullif(coalesce(p_email, v_mail), '');
  v_name := coalesce(
    p_display_name,
    case
      when v_mail is not null and position('@' in v_mail) > 0
        then split_part(v_mail, '@', 1)
      else null
    end,
    'Användare'
  );

  insert into app.profiles(user_id, email, display_name)
  values (v_user, v_mail, v_name)
  on conflict (user_id)
  do update set
    email = excluded.email,
    display_name = coalesce(excluded.display_name, app.profiles.display_name),
    updated_at = now()
  returning * into v_row;

  return v_row;
end;
$$;

grant execute on function app.ensure_profile(text, text) to anon, authenticated;

commit;
