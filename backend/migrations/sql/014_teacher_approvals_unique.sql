begin;

alter table app.teacher_approvals
  add constraint teacher_approvals_user_key unique (user_id);

commit;
