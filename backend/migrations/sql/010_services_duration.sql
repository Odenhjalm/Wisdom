begin;

alter table app.services
  add column if not exists duration_min integer;

update app.services
set duration_min = duration_minutes
where duration_min is null;

alter table app.services
  drop column if exists duration_minutes;

commit;
