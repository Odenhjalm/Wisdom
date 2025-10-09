-- Align app.posts schema with JSON-based content storage.

begin;

alter table app.posts
  add column if not exists content text,
  add column if not exists media_paths jsonb not null default '[]'::jsonb;

update app.posts
set content = coalesce(content, body)
where content is null;

alter table app.posts
  drop column if exists title,
  drop column if exists body,
  drop column if exists visibility,
  drop column if exists updated_at;

commit;
