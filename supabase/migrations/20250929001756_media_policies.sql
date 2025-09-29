alter table storage.objects enable row level security;

drop policy
if exists media_read   on storage.objects;
drop policy
if exists media_write  on storage.objects;
drop policy
if exists media_update on storage.objects;
drop policy
if exists media_delete on storage.objects;

create policy media_read
on storage.objects for
select
    to public
using
(bucket_id = 'media');

create policy media_write
on storage.objects for
insert
to authenticated
with check (
bucket_id
=
'media'
and public.user_is_teacher
());

create policy media_update
on storage.objects for
update
to authenticated
using (bucket_id = 'media' and public.user_is_teacher())
with check
(bucket_id = 'media' and public.user_is_teacher
());

create policy media_delete
on storage.objects for
delete
to authenticated
using (bucket_id = 'media' and public.user_is_teacher());
