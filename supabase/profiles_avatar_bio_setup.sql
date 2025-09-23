-- Ensure app.profiles has photo_url and bio; set storage policy for avatars

begin;

alter table if exists app.profiles
  add column if not exists photo_url text;

alter table if exists app.profiles
  add column if not exists bio text;

-- Public read policy for avatars bucket
 drop policy if exists "public read avatars" on storage.objects;
 create policy "public read avatars" on storage.objects
   for select
   to anon, authenticated
   using (bucket_id = 'avatars');

-- Optional: allow authenticated users to upload/update their own avatar objects
 drop policy if exists "avatars self insert" on storage.objects;
 create policy "avatars self insert" on storage.objects
   for insert
   to authenticated
   with check (bucket_id = 'avatars' and owner = auth.uid());

 drop policy if exists "avatars self update" on storage.objects;
 create policy "avatars self update" on storage.objects
   for update
   to authenticated
   using (bucket_id = 'avatars' and owner = auth.uid())
   with check (bucket_id = 'avatars' and owner = auth.uid());

commit;
