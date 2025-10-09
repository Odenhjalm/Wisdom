-- Ensure app.app_config exists with default row.

begin;

create table if not exists app.app_config (
  id integer primary key default 1,
  free_course_limit integer not null default 5,
  platform_fee_pct numeric not null default 10
);

insert into app.app_config(id)
select 1
where not exists (select 1 from app.app_config where id = 1);

commit;
