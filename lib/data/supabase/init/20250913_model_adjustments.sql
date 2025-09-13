-- =====================================================================
-- Visdom • Model Adjustments (idempotent)
-- Adds courses.branch and orders.platform_fee_cents
-- =====================================================================

begin;

-- courses.branch (taxonomy/area)
alter table app.courses add column if not exists branch text;

-- orders.platform_fee_cents (for platform fee accounting)
alter table app.orders add column if not exists platform_fee_cents integer not null default 0;

commit;

