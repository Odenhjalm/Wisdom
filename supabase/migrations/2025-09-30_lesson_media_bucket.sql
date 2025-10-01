begin;

alter table app.lesson_media add column if not exists storage_bucket text;

update app.lesson_media
set storage_bucket = coalesce(storage_bucket, 'course-media')
where storage_bucket is null;

commit;
