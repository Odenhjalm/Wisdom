begin;

alter table app.certificates
  add column if not exists title text,
  add column if not exists status text not null default 'pending',
  add column if not exists notes text,
  add column if not exists evidence_url text,
  add column if not exists metadata jsonb not null default '{}'::jsonb,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

commit;
