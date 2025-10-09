begin;

alter table app.messages
  add column if not exists channel text,
  add column if not exists content text;

update app.messages
set content = coalesce(content, body);

alter table app.messages
  drop column if exists body;

create index if not exists idx_messages_channel on app.messages(channel);

commit;
