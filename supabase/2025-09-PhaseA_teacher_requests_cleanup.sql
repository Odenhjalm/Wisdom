-- Phase A: Legacy compatibility for teacher requests

begin;

-- Replace direct table usage with view backed by certificates/approvals
create or replace view app.teacher_requests_legacy as
select
  c.user_id,
  null::uuid as id,
  c.notes as message,
  case c.status
    when 'verified' then 'approved'
    when 'rejected' then 'rejected'
    else 'pending'
  end as status,
  ta.approved_by,
  ta.approved_at,
  c.created_at,
  c.updated_at
from app.certificates c
left join app.teacher_approvals ta on ta.user_id = c.user_id
where c.title = 'Läraransökan';

comment on view app.teacher_requests_legacy is
  'Legacy view for teacher requests backed by certificates + approvals.';

commit;
