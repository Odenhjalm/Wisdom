begin;

alter table app.meditations
  add column if not exists teacher_id uuid references app.profiles(user_id) on delete cascade,
  add column if not exists audio_path text,
  add column if not exists is_public boolean not null default false;

update app.meditations
set teacher_id = coalesce(teacher_id, created_by);

commit;
