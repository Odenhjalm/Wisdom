-- Migration: add requires_cert flag to app.services
-- Idempotent.

begin;

alter table app.services
  add column if not exists requires_cert boolean not null default false;

commit;
