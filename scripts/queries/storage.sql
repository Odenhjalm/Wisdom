-- Buckets (id, public, file_size_limit, allowed_mime_types...)
select
    b.id as bucket_id,
    b.public as is_public,
    b.file_size_limit,
    b.allowed_mime_types
from storage.buckets b
order by b.id;

-- Policys på storage.objects (med samma format som rls.sql)
select
    schemaname,
    tablename,
    policyname,
    cmd,
    roles,
    permissive,
    coalesce(qual,'') as using_expr,
    coalesce(with_check,'') as with_check_expr
from pg_policies
where schemaname = 'storage' and tablename = 'objects'
order by policyname, cmd;
