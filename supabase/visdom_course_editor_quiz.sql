-- Visdom course editor + quiz schema (idempotent)
-- Tables, RLS, triggers, storage policies and RPC for grading

begin;

create extension if not exists pgcrypto;
create extension if not exists "uuid-ossp";

-- Helper to identify teachers (prefers JWT role, falls back to teacher_permissions)
create or replace function public.is_teacher()
returns boolean language sql stable as $$
  select coalesce((auth.jwt() -> 'app_metadata' ->> 'role') in ('teacher','admin'), false)
$$;

-- Compat helper now defers to app.is_teacher()
create or replace function public.user_is_teacher()
returns boolean
language sql
stable
as $$
  select app.is_teacher();
$$;

-- =======================
-- Tables
-- =======================

create table if not exists public.course_modules (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  position int not null default 0,
  type text not null check (type in ('text','video','audio','image','quiz')),
  title text,
  body text,
  media_url text,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(course_id, position)
);
create index if not exists idx_course_modules_course on public.course_modules(course_id);

create table if not exists public.course_quizzes (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  title text not null,
  pass_score int not null default 80,
  created_by uuid,
  created_at timestamptz not null default now()
);
create index if not exists idx_course_quizzes_course on public.course_quizzes(course_id);

create table if not exists public.quiz_questions (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid not null references public.course_quizzes(id) on delete cascade,
  position int not null default 0,
  kind text not null check (kind in ('single','multi','boolean')),
  prompt text not null,
  options jsonb,
  correct jsonb not null,
  created_at timestamptz not null default now(),
  unique(quiz_id, position)
);
create index if not exists idx_quiz_questions_quiz on public.quiz_questions(quiz_id);

create table if not exists public.quiz_attempts (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid not null references public.course_quizzes(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  answers jsonb not null,
  score int not null,
  passed boolean not null,
  submitted_at timestamptz not null default now()
);
create index if not exists idx_quiz_attempts_quiz on public.quiz_attempts(quiz_id);
create index if not exists idx_quiz_attempts_user on public.quiz_attempts(user_id);

create table if not exists public.certificates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  course_id uuid not null references public.courses(id) on delete cascade,
  issued_at timestamptz not null default now(),
  unique(user_id, course_id)
);
create index if not exists idx_certificates_user on public.certificates(user_id);
create index if not exists idx_certificates_course on public.certificates(course_id);

-- =======================
-- Trigger: set created_by and updated_at on course_modules
-- =======================

create or replace function public._set_created_by()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'INSERT' then
    if new.created_by is null then
      new.created_by := auth.uid();
    end if;
    new.updated_at := now();
  elsif tg_op = 'UPDATE' then
    new.updated_at := now();
  end if;
  return new;
end;
$$;

drop trigger if exists trg_course_modules_set_created_by on public.course_modules;
create trigger trg_course_modules_set_created_by
before insert or update on public.course_modules
for each row execute function public._set_created_by();

-- =======================
-- RLS policies
-- =======================

alter table public.course_modules enable row level security;
alter table public.course_quizzes enable row level security;
alter table public.quiz_questions enable row level security;
alter table public.quiz_attempts enable row level security;
alter table public.certificates enable row level security;

-- course_modules
drop policy if exists "cm_select_all" on public.course_modules;
create policy "cm_select_all" on public.course_modules for select using (true);

drop policy if exists "cm_teacher_write" on public.course_modules;
create policy "cm_teacher_write" on public.course_modules for all
to authenticated
using (public.user_is_teacher())
with check (public.user_is_teacher());

-- course_quizzes
drop policy if exists "cq_select_all" on public.course_quizzes;
create policy "cq_select_all" on public.course_quizzes for select using (true);

drop policy if exists "cq_teacher_write" on public.course_quizzes;
create policy "cq_teacher_write" on public.course_quizzes for all
to authenticated
using (public.user_is_teacher())
with check (public.user_is_teacher());

-- quiz_questions
drop policy if exists "qq_select_all" on public.quiz_questions;
create policy "qq_select_all" on public.quiz_questions for select using (true);

drop policy if exists "qq_teacher_write" on public.quiz_questions;
create policy "qq_teacher_write" on public.quiz_questions for all
to authenticated
using (public.user_is_teacher())
with check (public.user_is_teacher());

-- quiz_attempts (only owner can see/insert)
drop policy if exists "qa_select_own" on public.quiz_attempts;
create policy "qa_select_own" on public.quiz_attempts for select
to authenticated using (auth.uid() = user_id);

drop policy if exists "qa_insert_own" on public.quiz_attempts;
create policy "qa_insert_own" on public.quiz_attempts for insert
to authenticated with check (auth.uid() = user_id);

-- certificates (only owner can read, only teachers can issue)
drop policy if exists "cert_select_own" on public.certificates;
create policy "cert_select_own" on public.certificates for select
to authenticated using (auth.uid() = user_id);

drop policy if exists "cert_teacher_insert" on public.certificates;
create policy "cert_teacher_insert" on public.certificates for insert
to authenticated with check (public.user_is_teacher());

-- =======================
-- RPC: Grade quiz and issue certificate
-- =======================

create or replace function public.grade_quiz_and_issue_certificate(p_quiz uuid, p_answers jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  qz record;
  total int := 0;
  correct_count int := 0;
  pct int := 0;
  passed boolean := false;
  qs record;
  ans jsonb;
  norm_answer text;
  norm_correct text;
begin
  if uid is null then
    return jsonb_build_object('ok', false, 'reason', 'not_authenticated');
  end if;

  select * into qz from public.course_quizzes where id = p_quiz;
  if qz is null then
    return jsonb_build_object('ok', false, 'reason', 'quiz_not_found');
  end if;

  for qs in select * from public.quiz_questions where quiz_id = p_quiz order by position loop
    total := total + 1;
    -- fetch provided answer for this question id
    ans := coalesce(p_answers -> qs.id::text, 'null'::jsonb);

    if qs.kind = 'single' then
      norm_answer := coalesce(ans::text, '');
      norm_correct := coalesce(qs.correct::text, '');
      if norm_answer = norm_correct then
        correct_count := correct_count + 1;
      end if;
    elsif qs.kind = 'multi' then
      -- sort arrays and compare as comma-joined string
      norm_answer := coalesce((
        select string_agg(x, ',' order by x)
        from (
          select jsonb_array_elements_text(ans)
        ) s(x)
      ), '');

      norm_correct := coalesce((
        select string_agg(x, ',' order by x)
        from (
          select jsonb_array_elements_text(qs.correct)
        ) s(x)
      ), '');

      if norm_answer = norm_correct then
        correct_count := correct_count + 1;
      end if;
    elsif qs.kind = 'boolean' then
      norm_answer := lower(coalesce(ans::text, ''));
      norm_correct := lower(coalesce(qs.correct::text, ''));
      if norm_answer = norm_correct then
        correct_count := correct_count + 1;
      end if;
    else
      -- unknown kind -> treat as wrong
    end if;
  end loop;

  if total > 0 then
    pct := round((correct_count::numeric * 100.0) / total)::int;
  else
    pct := 0;
  end if;
  passed := (pct >= qz.pass_score);

  insert into public.quiz_attempts(quiz_id, user_id, answers, score, passed)
  values (p_quiz, uid, p_answers, pct, passed);

  if passed then
    insert into public.certificates(user_id, course_id, issued_at)
    values (uid, qz.course_id, now())
    on conflict (user_id, course_id) do update set issued_at = greatest(public.certificates.issued_at, excluded.issued_at);
  end if;

  return jsonb_build_object(
    'ok', true,
    'score', pct,
    'passed', passed,
    'total', total,
    'correct', correct_count
  );
end;
$$;

revoke all on function public.grade_quiz_and_issue_certificate(uuid, jsonb) from public;
grant execute on function public.grade_quiz_and_issue_certificate(uuid, jsonb) to authenticated;

-- =======================
-- Storage: course-media bucket and policies
-- =======================

insert into storage.buckets(id, name, public)
values ('course-media', 'course-media', true)
on conflict (id) do nothing;

drop policy if exists "course_media_public_read" on storage.objects;
create policy "course_media_public_read" on storage.objects
for select to public
using (bucket_id = 'course-media');

drop policy if exists "course_media_teacher_write" on storage.objects;
create policy "course_media_teacher_write" on storage.objects
for all to authenticated
using (bucket_id = 'course-media' and public.user_is_teacher())
with check (bucket_id = 'course-media' and public.user_is_teacher());

commit;
