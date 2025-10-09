-- 002_seed_dev.sql
-- Deterministic seed data to make local development convenient.
-- Idempotent: all inserts use stable UUIDs and ON CONFLICT guards.

begin;

-- ---------------------------------------------------------------------------
-- Seed users (teacher + student)
-- ---------------------------------------------------------------------------
insert into auth.users (id, email, encrypted_password, full_name, is_verified, created_at, updated_at)
values
  (
    '11111111-1111-4111-8111-111111111111',
    'teacher@wisdom.local',
    crypt('password123', gen_salt('bf')),
    'Teacher Wisdom',
    true,
    now(),
    now()
  ),
  (
    '22222222-2222-4222-8222-222222222222',
    'student@wisdom.local',
    crypt('password123', gen_salt('bf')),
    'Student Soul',
    true,
    now(),
    now()
  )
on conflict (id) do update
set
  email = excluded.email,
  encrypted_password = excluded.encrypted_password,
  full_name = excluded.full_name,
  is_verified = excluded.is_verified,
  updated_at = now();

-- ---------------------------------------------------------------------------
-- Profiles
-- ---------------------------------------------------------------------------
insert into app.profiles (user_id, email, display_name, role, role_v2, bio, photo_url, is_admin)
values
  (
    '11111111-1111-4111-8111-111111111111',
    'teacher@wisdom.local',
    'Coach Aurora',
    'teacher',
    'teacher',
    'Certified mindfulness coach focusing on everyday wisdom.',
    null,
    true
  ),
  (
    '22222222-2222-4222-8222-222222222222',
    'student@wisdom.local',
    'Seeker Nova',
    'student',
    'user',
    'Curious student exploring SoulWisdom practices.',
    null,
    false
  )
on conflict (user_id) do update
set
  display_name = excluded.display_name,
  role = excluded.role,
  role_v2 = excluded.role_v2,
  bio = excluded.bio,
  photo_url = excluded.photo_url,
  is_admin = excluded.is_admin,
  updated_at = now();

-- ---------------------------------------------------------------------------
-- Courses, modules, lessons
-- ---------------------------------------------------------------------------
insert into app.courses (id, slug, title, description, cover_url, video_url, branch, is_free_intro, price_cents, currency, is_published, created_by)
values (
  '33333333-3333-4333-8333-333333333333',
  'foundations-of-soulwisdom',
  'Foundations of SoulWisdom',
  'Kickstart your practice with core breathing and journaling rituals.',
  'https://assets.wisdom.local/course-cover.png',
  null,
  'mindfulness',
  true,
  0,
  'sek',
  true,
  '11111111-1111-4111-8111-111111111111'
)
on conflict (id) do update
set
  slug = excluded.slug,
  title = excluded.title,
  description = excluded.description,
  cover_url = excluded.cover_url,
  branch = excluded.branch,
  is_free_intro = excluded.is_free_intro,
  price_cents = excluded.price_cents,
  currency = excluded.currency,
  is_published = excluded.is_published,
  created_by = excluded.created_by,
  updated_at = now();

insert into app.modules (id, course_id, title, summary, position)
values (
  '44444444-4444-4444-8444-444444444444',
  '33333333-3333-4333-8333-333333333333',
  'Grounding Practices',
  'Breathwork and morning check-ins to reset your nervous system.',
  0
)
on conflict (id) do update
set
  course_id = excluded.course_id,
  title = excluded.title,
  summary = excluded.summary,
  position = excluded.position,
  updated_at = now();

insert into app.lessons (id, module_id, title, content_markdown, video_url, duration_seconds, is_intro, position)
values (
  '55555555-5555-4555-8555-555555555555',
  '44444444-4444-4444-8444-444444444444',
  'Five-minute Centering Breath',
  '# Centering Breath\n\nFind a comfortable seat and follow the guided rhythm.',
  null,
  300,
  true,
  0
)
on conflict (id) do update
set
  module_id = excluded.module_id,
  title = excluded.title,
  content_markdown = excluded.content_markdown,
  video_url = excluded.video_url,
  duration_seconds = excluded.duration_seconds,
  is_intro = excluded.is_intro,
  position = excluded.position,
  updated_at = now();

-- ---------------------------------------------------------------------------
-- Services marketplace
-- ---------------------------------------------------------------------------
insert into app.services (id, provider_id, title, description, status, price_cents, currency, duration_min, requires_certification, certified_area)
values (
  '66666666-6666-4666-8666-666666666666',
  '11111111-1111-4111-8111-111111111111',
  '1:1 Integration Coaching',
  'Personalized session to integrate insights from your daily practice.',
  'active',
  12000,
  'sek',
  60,
  false,
  null
)
on conflict (id) do update
set
  provider_id = excluded.provider_id,
  title = excluded.title,
  description = excluded.description,
  status = excluded.status,
  price_cents = excluded.price_cents,
  currency = excluded.currency,
  duration_min = excluded.duration_min,
  requires_certification = excluded.requires_certification,
  certified_area = excluded.certified_area,
  updated_at = now();

-- ---------------------------------------------------------------------------
-- Orders and payments (Stripe simulation)
-- ---------------------------------------------------------------------------
insert into app.orders (id, user_id, service_id, amount_cents, currency, status, stripe_checkout_id, stripe_payment_intent, metadata, created_at, updated_at)
values (
  '77777777-7777-4777-8777-777777777777',
  '22222222-2222-4222-8222-222222222222',
  '66666666-6666-4666-8666-666666666666',
  12000,
  'sek',
  'paid',
  'cs_test_seed',
  'pi_test_seed',
  jsonb_build_object('seed', true),
  now(),
  now()
)
on conflict (id) do update
set
  user_id = excluded.user_id,
  service_id = excluded.service_id,
  amount_cents = excluded.amount_cents,
  currency = excluded.currency,
  status = excluded.status,
  stripe_checkout_id = excluded.stripe_checkout_id,
  stripe_payment_intent = excluded.stripe_payment_intent,
  metadata = excluded.metadata,
  updated_at = now();

insert into app.payments (id, order_id, provider, provider_reference, status, amount_cents, currency, metadata, raw_payload)
values (
  '88888888-8888-4888-8888-888888888888',
  '77777777-7777-4777-8777-777777777777',
  'stripe',
  'evt_test_seed',
  'paid',
  12000,
  'sek',
  jsonb_build_object('integration_test', true),
  jsonb_build_object('stripe_event', 'checkout.session.completed')
)
on conflict (id) do update
set
  order_id = excluded.order_id,
  provider = excluded.provider,
  provider_reference = excluded.provider_reference,
  status = excluded.status,
  amount_cents = excluded.amount_cents,
  currency = excluded.currency,
  metadata = excluded.metadata,
  raw_payload = excluded.raw_payload,
  updated_at = now();

insert into app.service_reviews (id, service_id, order_id, reviewer_id, rating, comment, visibility, created_at)
values (
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '66666666-6666-4666-8666-666666666666',
  '77777777-7777-4777-8777-777777777777',
  '22222222-2222-4222-8222-222222222222',
  5,
  'A grounding experience that left me energized and clear.',
  'public',
  now()
)
on conflict (id) do update
set
  service_id = excluded.service_id,
  order_id = excluded.order_id,
  reviewer_id = excluded.reviewer_id,
  rating = excluded.rating,
  comment = excluded.comment,
  visibility = excluded.visibility,
  created_at = excluded.created_at;

-- ---------------------------------------------------------------------------
-- Enrollment & activity feed
-- ---------------------------------------------------------------------------
insert into app.enrollments (id, user_id, course_id, status, source, created_at)
values (
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '22222222-2222-4222-8222-222222222222',
  '33333333-3333-4333-8333-333333333333',
  'active',
  'free_intro',
  now()
)
on conflict (id) do update
set
  user_id = excluded.user_id,
  course_id = excluded.course_id,
  status = excluded.status,
  source = excluded.source,
  created_at = excluded.created_at;

insert into app.activities (id, activity_type, actor_id, subject_table, subject_id, summary, metadata, occurred_at, created_at)
values (
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  'order_paid',
  '22222222-2222-4222-8222-222222222222',
  'orders',
  '77777777-7777-4777-8777-777777777777',
  'Seeker Nova booked "1:1 Integration Coaching".',
  jsonb_build_object('seed', true),
  now(),
  now()
)
on conflict (id) do update
set
  activity_type = excluded.activity_type,
  actor_id = excluded.actor_id,
  subject_table = excluded.subject_table,
  subject_id = excluded.subject_id,
  summary = excluded.summary,
  metadata = excluded.metadata,
  occurred_at = excluded.occurred_at,
  created_at = excluded.created_at;

-- ---------------------------------------------------------------------------
-- Seminars & attendees (LiveKit scaffolding)
-- ---------------------------------------------------------------------------
insert into app.seminars (id, host_id, title, description, status, scheduled_at, duration_minutes, livekit_room, livekit_metadata)
values (
  '99999999-9999-4999-8999-999999999999',
  '11111111-1111-4111-8111-111111111111',
  'Morning Presence Circle',
  'Live group practice to sync breath, intention and gratitude.',
  'scheduled',
  now() + interval '3 days',
  45,
  'wisdom-morning-presence',
  jsonb_build_object('seed', true)
)
on conflict (id) do update
set
  host_id = excluded.host_id,
  title = excluded.title,
  description = excluded.description,
  status = excluded.status,
  scheduled_at = excluded.scheduled_at,
  duration_minutes = excluded.duration_minutes,
  livekit_room = excluded.livekit_room,
  livekit_metadata = excluded.livekit_metadata,
  updated_at = now();

insert into app.seminar_attendees (seminar_id, user_id, role, joined_at, created_at)
values (
  '99999999-9999-4999-8999-999999999999',
  '22222222-2222-4222-8222-222222222222',
  'participant',
  null,
  now()
)
on conflict (seminar_id, user_id) do update
set
  role = excluded.role,
  joined_at = excluded.joined_at,
  created_at = excluded.created_at;

-- ---------------------------------------------------------------------------
-- Teacher payout method
-- ---------------------------------------------------------------------------
insert into app.teacher_payout_methods (id, teacher_id, provider, reference, details, is_default)
values (
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '11111111-1111-4111-8111-111111111111',
  'stripe_connect',
  'acct_seed_teacher',
  jsonb_build_object('account_id', 'acct_seed_teacher'),
  true
)
on conflict (id) do update
set
  teacher_id = excluded.teacher_id,
  provider = excluded.provider,
  reference = excluded.reference,
  details = excluded.details,
  is_default = excluded.is_default,
  updated_at = now();

commit;
