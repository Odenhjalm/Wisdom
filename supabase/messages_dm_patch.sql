-- Extend app.messages to support direct messages (dm:<uid1>:<uid2>)
-- Safe to run after init_projectapp.sql

-- Relax channel format to include dm:<uuid>:<uuid>
alter table app.messages drop constraint if exists messages_channel_format;
alter table app.messages add constraint messages_channel_format
  check (
    channel ~ '^(global|course:[0-9a-fA-F-]{36}|event:[0-9a-fA-F-]{36}|dm:[0-9a-fA-F-]{36}:[0-9a-fA-F-]{36})$'
  );

-- Update channel permission helpers to include dm
create or replace function app.can_read_channel(p_channel text)
returns boolean language sql stable as $$
  with kind as (
    select case
      when p_channel = 'global' then 'global'
      when left(p_channel,7) = 'course:' then 'course'
      when left(p_channel,6) = 'event:' then 'event'
      when left(p_channel,3) = 'dm:' then 'dm'
      else 'other'
    end as k
  )
  select
    (exists(select 1 from kind where k='global') and auth.uid() is not null)
    or
    (exists(select 1 from kind where k='course')
     and (
       app.is_teacher()
       or exists (
         select 1 from app.enrollments e
         where e.user_id = auth.uid()
           and e.course_id = (substring(p_channel from 8)::uuid)
       )
     ))
    or
    (exists(select 1 from kind where k='event')
     and (
       app.is_teacher()
       or exists (
         select 1 from app.events ev
         where ev.id = (substring(p_channel from 7)::uuid)
           and (ev.is_published = true or ev.created_by = auth.uid())
       )
     ))
    or
    (exists(select 1 from kind where k='dm') and (
      split_part(p_channel, ':', 2)::uuid = auth.uid()
      or split_part(p_channel, ':', 3)::uuid = auth.uid()
    ));
$$;

create or replace function app.can_post_channel(p_channel text, p_sender uuid)
returns boolean language sql stable as $$
  with kind as (
    select case
      when p_channel = 'global' then 'global'
      when left(p_channel,7) = 'course:' then 'course'
      when left(p_channel,6) = 'event:' then 'event'
      when left(p_channel,3) = 'dm:' then 'dm'
      else 'other'
    end as k
  )
  select
    ((exists(select 1 from kind where k='global') and p_sender = auth.uid()))
    or
    ((exists(select 1 from kind where k='course')
      and (
        app.is_teacher()
        or exists (
          select 1 from app.enrollments e
          where e.user_id = p_sender
            and e.course_id = (substring(p_channel from 8)::uuid)
        )
      )
      and p_sender = auth.uid()))
    or
    ((exists(select 1 from kind where k='event')
      and (
        app.is_teacher()
        or exists (
          select 1 from app.events ev
          where ev.id = (substring(p_channel from 7)::uuid)
            and ev.created_by = p_sender
        )
      ) and p_sender = auth.uid()))
    or
    ((exists(select 1 from kind where k='dm')
      and p_sender = auth.uid()
      and (
        split_part(p_channel, ':', 2)::uuid = p_sender
        or split_part(p_channel, ':', 3)::uuid = p_sender
      )));
$$;

