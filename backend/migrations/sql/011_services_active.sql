begin;

alter table app.services
  add column if not exists active boolean not null default true;

commit;
