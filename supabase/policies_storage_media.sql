-- Media bucket policies (idempotent)

begin;

insert into storage.buckets (id, name, public)
values ('media', 'media', true)
on conflict (id) do nothing;

drop policy if exists "public read media" on storage.objects;
create policy "public read media" on storage.objects
  for select
  to anon, authenticated
  using (bucket_id = 'media');

drop policy if exists "media teacher insert" on storage.objects;
create policy "media teacher insert" on storage.objects
  for insert
  to authenticated
  with check (bucket_id = 'media' and app.is_teacher());

drop policy if exists "media teacher update" on storage.objects;
create policy "media teacher update" on storage.objects
  for update
  to authenticated
  using (bucket_id = 'media' and app.is_teacher())
  with check (bucket_id = 'media' and app.is_teacher());

drop policy if exists "media teacher delete" on storage.objects;
create policy "media teacher delete" on storage.objects
  for delete
  to authenticated
  using (bucket_id = 'media' and app.is_teacher());

commit;
