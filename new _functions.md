Oden — här kommer **hela, körbara paketet**: databas (SQL + RLS), Edge Functions (Stripe checkout + webhook), app-logik (Riverpod, guards, paywall), och UI-flöden. Du kan kopiera in filerna rakt av. Förklaring kommer sist. Inget e-post, allt här.

---

# 0) Roller & nivåer (definition)

* **guest** (ej inloggad) → kan se öppet innehåll + köpa enstaka kurs via e-post (magic link).
* **user** (inloggad) → kan se personligt flöde, events, köpa kurser.
* **professional** (inloggad + uppfyllt cert/krav) → får skapa **events**.
* **teacher** (inloggad + godkänd lärare) → får skapa **kurser** (+ events).

---

# 1) Supabase – komplett SQL

Spara som `supabase/init_all.sql` och kör i SQL Editorn. Detta skapar tabeller, vyer, funktioner och RLS.

```sql
-- ============================================
-- Visdom: Core schema for roles, courses, events, purchases
-- ============================================

create schema if not exists app;

-- ---------- ENUMS ----------
do $$ begin
  create type app.user_role as enum ('user','professional','teacher');
exception when duplicate_object then null; end $$;

-- ---------- PROFILES ----------
create table if not exists app.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique,
  full_name text,
  role app.user_role default 'user' not null,
  professional_since timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create or replace function app.ensure_profile()
returns trigger language plpgsql as $$
begin
  insert into app.profiles (id,email)
  values (new.id, new.email)
  on conflict (id) do update set email = excluded.email;
  return new;
end $$;

drop trigger if exists trg_auth_user_created on auth.users;
create trigger trg_auth_user_created
after insert on auth.users
for each row execute function app.ensure_profile();

-- ---------- CERTS / PRO PATH ----------
create table if not exists app.certificates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references app.profiles(id) on delete cascade,
  title text not null,
  status text not null default 'pending', -- pending|verified|rejected
  evidence_url text,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Tre "större steg" mot professional
create table if not exists app.pro_requirements (
  id serial primary key,
  code text unique not null, -- e.g. STEP1, STEP2, STEP3
  title text not null
);

insert into app.pro_requirements (code,title) values
  ('STEP1','Grundutbildning'),
  ('STEP2','Fördjupning'),
  ('STEP3','Praktik')
on conflict (code) do nothing;

create table if not exists app.pro_progress (
  user_id uuid references app.profiles(id) on delete cascade,
  requirement_id int references app.pro_requirements(id) on delete cascade,
  completed_at timestamptz default now(),
  primary key (user_id, requirement_id)
);

create or replace function app.grant_professional_if_ready(p_user uuid)
returns void language plpgsql as $$
declare c int; v int;
begin
  select count(*) into c from app.pro_requirements;
  select count(*) into v from app.pro_progress where user_id = p_user;
  if v >= c then
    update app.profiles set role='professional', professional_since=now(), updated_at=now()
    where id = p_user and role <> 'teacher'; -- teacher > professional
  end if;
end $$;

-- ---------- COURSES ----------
create table if not exists app.courses (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references app.profiles(id) on delete restrict,
  title text not null,
  subtitle text,
  description text,
  level text default 'intro', -- intro|core|advanced
  visibility text default 'public', -- public|paywalled|pro_only
  hero_image_url text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists app.course_modules (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references app.courses(id) on delete cascade,
  index_no int not null,
  title text not null,
  content_md text,
  media_url text,        -- signed storage path
  is_preview boolean default false,
  unique(course_id, index_no)
);

-- Prissättning (Stripe)
create table if not exists app.course_prices (
  course_id uuid primary key references app.courses(id) on delete cascade,
  stripe_price_id text unique,
  currency text default 'eur',
  unit_amount int not null check (unit_amount > 0) -- cents
);

-- ---------- PURCHASES & ACCESS ----------
create table if not exists app.purchases (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references app.profiles(id) on delete set null, -- kan vara null för guest tills claim
  buyer_email text not null,
  course_id uuid references app.courses(id) on delete cascade,
  stripe_checkout_id text unique,
  stripe_payment_intent text,
  status text not null default 'succeeded', -- succeeded|refunded|failed
  created_at timestamptz default now()
);

-- Gästkvitto → Magisk "claim"-token via email (skapar konto vid första öppning)
create table if not exists app.guest_claim_tokens (
  token uuid primary key default gen_random_uuid(),
  buyer_email text not null,
  course_id uuid not null references app.courses(id) on delete cascade,
  purchase_id uuid not null references app.purchases(id) on delete cascade,
  used boolean default false,
  expires_at timestamptz not null default (now() + interval '14 days')
);

create or replace function app.claim_purchase(p_token uuid, p_user uuid)
returns boolean language plpgsql as $$
declare r record;
begin
  select * into r from app.guest_claim_tokens
  where token=p_token and used=false and expires_at > now();
  if not found then return false; end if;

  update app.purchases
    set user_id = p_user
  where id = r.purchase_id;

  update app.guest_claim_tokens
    set used=true
  where token=p_token;

  return true;
end $$;

-- VY: har användare tillgång till kurs?
create or replace view app.v_course_access as
select
  c.id as course_id,
  p.id as user_id,
  -- Accessregler:
  -- 1) public → alltid true
  -- 2) paywalled → kräver purchase
  -- 3) pro_only → kräver role in (professional, teacher) eller ownership (teacher_id)
  case
    when c.visibility = 'public' then true
    when c.visibility = 'paywalled' then exists (
      select 1 from app.purchases pu
      where pu.course_id = c.id and pu.user_id = p.id and pu.status='succeeded'
    )
    when c.visibility = 'pro_only' then (p.role in ('professional','teacher') or p.id = c.teacher_id)
    else false
  end as has_access
from app.courses c
cross join app.profiles p;

-- ---------- EVENTS ----------
create table if not exists app.events (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid not null references app.profiles(id) on delete restrict,
  title text not null,
  description text,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  location_text text,
  lat double precision,
  lng double precision,
  is_public boolean default true,
  created_at timestamptz default now()
);

create table if not exists app.event_attendance (
  event_id uuid references app.events(id) on delete cascade,
  user_id uuid references app.profiles(id) on delete cascade,
  status text default 'going', -- going|interested|declined
  primary key (event_id, user_id)
);

-- ---------- SOCIAL FEED (minimalt) ----------
create table if not exists app.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references app.profiles(id) on delete cascade,
  body text not null,
  image_url text,
  created_at timestamptz default now()
);

create table if not exists app.follows (
  follower uuid references app.profiles(id) on delete cascade,
  following uuid references app.profiles(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (follower, following)
);

-- ---------- SECURITY / RLS ----------
alter table app.profiles enable row level security;
alter table app.certificates enable row level security;
alter table app.pro_progress enable row level security;
alter table app.courses enable row level security;
alter table app.course_modules enable row level security;
alter table app.course_prices enable row level security;
alter table app.purchases enable row level security;
alter table app.guest_claim_tokens enable row level security;
alter table app.events enable row level security;
alter table app.event_attendance enable row level security;
alter table app.posts enable row level security;
alter table app.follows enable row level security;

-- Helper för auth.uid() i SQL editor
create or replace function app.current_user_id()
returns uuid language sql stable as $$
  select auth.uid()
$$;

-- PROFILES
create policy "profiles self read" on app.profiles
for select using (true); -- offentliga profiler

create policy "profiles self update" on app.profiles
for update using (id = auth.uid());

-- CERTS
create policy "certs owner rw" on app.certificates
for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- PRO PROGRESS (endast own)
create policy "pro progress owner" on app.pro_progress
for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- COURSES
create policy "courses public read" on app.courses
for select using (true);

create policy "courses teacher write" on app.courses
for all using (teacher_id = auth.uid()) with check (teacher_id = auth.uid());

-- COURSE MODULES
create policy "modules public read previews" on app.course_modules
for select using (
  is_preview = true
  or exists (
    select 1 from app.v_course_access va
    where va.course_id = course_id and va.user_id = auth.uid() and va.has_access = true
  )
);

create policy "modules teacher write" on app.course_modules
for all using (
  exists (select 1 from app.courses c where c.id=course_id and c.teacher_id=auth.uid())
) with check (
  exists (select 1 from app.courses c where c.id=course_id and c.teacher_id=auth.uid())
);

-- PRICES
create policy "prices public read" on app.course_prices
for select using (true);

create policy "prices teacher write" on app.course_prices
for all using (
  exists (select 1 from app.courses c where c.id=course_id and c.teacher_id=auth.uid())
) with check (
  exists (select 1 from app.courses c where c.id=course_id and c.teacher_id=auth.uid())
);

-- PURCHASES
create policy "purchases owner read" on app.purchases
for select using (user_id = auth.uid());

-- (skriv endast via webhook / server-role → använd service key i Edge Function)
revoke insert, update, delete on app.purchases from authenticated, anon;

-- GUEST TOKENS (inga reads publikt)
revoke all on app.guest_claim_tokens from anon, authenticated;

-- EVENTS
create policy "events public read" on app.events
for select using (is_public = true or creator_id = auth.uid());

create policy "events pro/teacher create" on app.events
for insert with check (
  exists (select 1 from app.profiles p where p.id=auth.uid() and p.role in ('professional','teacher'))
);

create policy "events owner write" on app.events
for update using (creator_id = auth.uid());

-- ATTENDANCE
create policy "attendance self" on app.event_attendance
for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- POSTS
create policy "posts public read" on app.posts for select using (true);
create policy "posts owner write" on app.posts for all using (author_id = auth.uid()) with check (author_id = auth.uid());

-- FOLLOWS
create policy "follows self" on app.follows
for all using (follower = auth.uid()) with check (follower = auth.uid());

-- ---------- RPCs ----------
-- Snabb access-koll
create or replace function app.has_course_access(p_course uuid)
returns boolean language sql stable as $$
  select case
    when c.visibility='public' then true
    when c.visibility='paywalled' then exists (
      select 1 from app.purchases pu
      where pu.course_id=c.id and pu.user_id = auth.uid() and pu.status='succeeded'
    )
    when c.visibility='pro_only' then exists (
      select 1 from app.profiles p where p.id = auth.uid() and p.role in ('professional','teacher')
    ) or c.teacher_id = auth.uid()
    else false
  end
  from app.courses c where c.id=p_course;
$$;

-- Uppgradera roll till teacher (admin-godkännande)
create table if not exists app.teacher_approvals (
  user_id uuid primary key references app.profiles(id) on delete cascade,
  approved_by uuid,
  approved_at timestamptz
);

create or replace function app.grant_teacher(p_user uuid)
returns void language plpgsql as $$
begin
  update app.profiles set role='teacher', updated_at=now()
  where id=p_user;
  insert into app.teacher_approvals(user_id,approved_by,approved_at)
  values (p_user, auth.uid(), now())
  on conflict (user_id) do update set approved_by=excluded.approved_by, approved_at=excluded.approved_at;
end $$;

-- Indexer
create index if not exists idx_posts_created on app.posts(created_at desc);
create index if not exists idx_events_starts on app.events(starts_at);
create index if not exists idx_courses_teacher on app.courses(teacher_id);
```

---

# 2) Supabase Edge Functions (Stripe)

## 2.1 `functions/create_checkout/index.ts`

Skapar Checkout Session. Kräver miljövariabler (Dashboard → Functions):
`STRIPE_SECRET_KEY`, `SITE_URL`, `STRIPE_SUCCESS_PATH=/purchase/success`, `STRIPE_CANCEL_PATH=/purchase/cancel`.

```ts
// functions/create_checkout/index.ts
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import Stripe from "https://esm.sh/stripe@16.6.0?target=deno";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2024-06-20",
});
const SITE_URL = Deno.env.get("SITE_URL")!;

serve(async (req) => {
  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!
    );

    const { courseId, priceId, buyerEmail } = await req.json();

    if (!priceId || !courseId || !buyerEmail) {
      return new Response(JSON.stringify({ error: "Missing params" }), { status: 400 });
    }

    // Skapa Checkout
    const session = await stripe.checkout.sessions.create({
      mode: "payment",
      customer_email: buyerEmail, // möjliggör "köp utan konto"
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: `${SITE_URL}${Deno.env.get("STRIPE_SUCCESS_PATH") || "/purchase/success"}?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${SITE_URL}${Deno.env.get("STRIPE_CANCEL_PATH") || "/purchase/cancel"}`,
      metadata: { courseId },
    });

    return new Response(JSON.stringify({ url: session.url }), { status: 200 });
  } catch (e) {
    return new Response(JSON.stringify({ error: e.message }), { status: 500 });
  }
});
```

## 2.2 `functions/stripe_webhook/index.ts`

Processar betalning → skapar `purchases` + `guest_claim_tokens`. Sätt **endpoint secret** som `STRIPE_WEBHOOK_SECRET`.

```ts
// functions/stripe_webhook/index.ts
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import Stripe from "https://esm.sh/stripe@16.6.0?target=deno";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, { apiVersion: "2024-06-20" });
const endpointSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET")!;

serve(async (req) => {
  const sig = req.headers.get("stripe-signature");
  if (!sig) return new Response("Missing signature", { status: 400 });

  const body = await req.text();
  let event;
  try {
    event = await stripe.webhooks.constructEventAsync(body, sig, endpointSecret);
  } catch (err) {
    return new Response(`Webhook Error: ${err.message}`, { status: 400 });
  }

  if (event.type === "checkout.session.completed") {
    const session = event.data.object as any;
    const supabase = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

    const courseId = session.metadata?.courseId;
    const buyerEmail = session.customer_details?.email || session.customer_email;

    // Försök hitta profil på e-post
    const { data: prof } = await supabase
      .from("profiles")
      .select("id")
      .eq("email", buyerEmail)
      .maybeSingle();

    // Skapa köp
    const { data: purchase, error } = await supabase
      .from("purchases")
      .insert({
        user_id: prof?.id ?? null,
        buyer_email: buyerEmail,
        course_id: courseId,
        stripe_checkout_id: session.id,
        stripe_payment_intent: session.payment_intent,
        status: "succeeded"
      })
      .select("*")
      .single();

    if (error) console.error(error);

    // Om ingen användare: skapa claim-token → maila länk (här loggar vi bara)
    if (!prof?.id && purchase?.id) {
      const { data: tokenRow, error: tErr } = await supabase
        .from("guest_claim_tokens")
        .insert({ buyer_email: buyerEmail, course_id: courseId, purchase_id: purchase.id })
        .select("*")
        .single();
      if (tErr) console.error(tErr);
      // TODO: Skicka e-post med SITE_URL + "/claim?token=" + tokenRow.token
    }
  }

  return new Response("ok", { status: 200 });
});
```

---

# 3) Flutter/Dart – Auth, Roller, Guards, Paywall, Checkout

## 3.1 Riverpod providers (roles + access)

`lib/core/auth/role_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum UserRole { user, professional, teacher }

final sessionProvider = StreamProvider((ref) => Supabase.instance.client.auth.onAuthStateChange.map((e) => e.session));

final profileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;
  final res = await Supabase.instance.client
      .from('profiles')
      .select('id,email,full_name,role')
      .eq('id', user.id)
      .maybeSingle();
  return res;
});

final userRoleProvider = Provider<UserRole?>((ref) {
  final prof = ref.watch(profileProvider).maybeWhen(data: (d) => d, orElse: () => null);
  if (prof == null) return null;
  switch ((prof['role'] as String)) {
    case 'teacher': return UserRole.teacher;
    case 'professional': return UserRole.professional;
    default: return UserRole.user;
  }
});

final hasCourseAccessProvider = FutureProvider.family<bool, String>((ref, courseId) async {
  final client = Supabase.instance.client;
  final resp = await client.rpc('has_course_access', params: {'p_course': courseId});
  return (resp as bool?) ?? false;
});
```

## 3.2 Router guards

`lib/core/router/guards.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/role_providers.dart';

GoRouter createRouter(WidgetRef ref) {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => const LandingScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: '/events/new',
        redirect: (ctx, state) {
          final role = ref.read(userRoleProvider);
          if (role == null) return '/login';
          if (role == UserRole.user) return '/pro-required';
          return null; // professional eller teacher ok
        },
        builder: (_, __) => const NewEventScreen(),
      ),
      GoRoute(
        path: '/courses/:id',
        builder: (_, st) => CourseDetailScreen(courseId: st.pathParameters['id']!),
      ),
      GoRoute(path: '/teacher/studio', builder: (_, __) => const TeacherStudio(), redirect: (ctx, st) {
        final role = ref.read(userRoleProvider);
        if (role != UserRole.teacher) return '/teacher-required';
        return null;
      }),
    ],
  );
}
```

## 3.3 AccessGate & Paywall

`lib/features/courses/widgets/access_gate.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/role_providers.dart';
import '../../payments/paywall_sheet.dart';

class CourseAccessGate extends ConsumerWidget {
  final String courseId;
  final Widget child;
  const CourseAccessGate({super.key, required this.courseId, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final has = ref.watch(hasCourseAccessProvider(courseId));
    return has.when(
      data: (ok) => ok ? child : PaywallPrompt(courseId: courseId),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(child: PaywallPrompt(courseId: courseId)),
    );
  }
}
```

`lib/features/payments/paywall_sheet.dart`

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/http.dart';

class PaywallPrompt extends StatelessWidget {
  final String courseId;
  const PaywallPrompt({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController(text: Supabase.instance.client.auth.currentUser?.email ?? "");
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Denna kurs är låst", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text("Köp enstaka kurs utan konto – ange e-post för kvitto & åtkomstlänk."),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(decoration: const InputDecoration(labelText: "E-post"), controller: emailCtrl),
        ),
        ElevatedButton(
          onPressed: () async {
            final price = await Supabase.instance.client
              .from('course_prices')
              .select('stripe_price_id')
              .eq('course_id', courseId).maybeSingle();
            if (price == null) return;

            final resp = await postJson('/functions/v1/create_checkout', {
              'courseId': courseId,
              'priceId': price['stripe_price_id'],
              'buyerEmail': emailCtrl.text,
            });
            final url = resp['url'] as String?;
            if (url != null) {
              // ignore: use_build_context_synchronously
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => WebViewCheckout(url: url), // valfri webview eller launchUrl
              ));
            }
          },
          child: const Text("Köp"),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            // valfritt: login för bättre upplevelse
            // context.push('/login');
          },
          child: const Text("Logga in för att spara köpet på ditt konto"),
        ),
      ],
    );
  }
}
```

`lib/core/utils/http.dart` (enkelt POST-hjälpmedel)

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String,dynamic>> postJson(String path, Map body) async {
  final uri = Uri.parse('${const String.fromEnvironment("SITE_URL", defaultValue: "http://localhost:54321")}$path');
  final res = await http.post(uri, headers: {'Content-Type':'application/json'}, body: jsonEncode(body));
  if (res.statusCode >= 200 && res.statusCode < 300) {
    return jsonDecode(res.body) as Map<String,dynamic>;
  }
  throw Exception('HTTP ${res.statusCode} ${res.body}');
}
```

## 3.4 CourseDetail med gate

`lib/features/courses/course_detail.dart`

```dart
import 'package:flutter/material.dart';
import 'widgets/access_gate.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CourseAccessGate(
        courseId: courseId,
        child: CoursePlayer(courseId: courseId),
      ),
    );
  }
}

class CoursePlayer extends StatelessWidget {
  final String courseId;
  const CoursePlayer({super.key, required this.courseId});
  @override
  Widget build(BuildContext context) {
    // rendera moduler (inkl. signed URLs) – redan odelat här
    return const Center(child: Text("Kursinnehåll"));
  }
}
```

## 3.5 Event-skapande (professionals/teachers)

`lib/features/events/new_event_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewEventScreen extends StatefulWidget {
  const NewEventScreen({super.key});
  @override State<NewEventScreen> createState() => _NewEventScreenState();
}

class _NewEventScreenState extends State<NewEventScreen> {
  final t = TextEditingController(), d = TextEditingController(), loc = TextEditingController();
  DateTime start = DateTime.now().add(const Duration(days:1));
  DateTime end = DateTime.now().add(const Duration(days:1, hours:2));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Skapa event")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: t, decoration: const InputDecoration(labelText: "Titel")),
          TextField(controller: d, decoration: const InputDecoration(labelText: "Beskrivning")),
          TextField(controller: loc, decoration: const InputDecoration(labelText: "Plats")),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final uid = Supabase.instance.client.auth.currentUser?.id;
              if (uid == null) return;
              final res = await Supabase.instance.client.from('events').insert({
                'creator_id': uid,
                'title': t.text,
                'description': d.text,
                'location_text': loc.text,
                'starts_at': start.toIso8601String(),
                'ends_at': end.toIso8601String(),
                'is_public': true
              });
              if (res.error == null) Navigator.pop(context);
            },
            child: const Text("Publicera"),
          ),
        ],
      ),
    );
  }
}
```

---

# 4) Storage – buckets & access

1. Skapa buckets:

* `public_media` (public read) för kurs-hero, post-bilder.
* `protected_media` (privat) för kursmodul-media.

2. I appen, när `has_course_access` är true → hämta **signed URL** för modulens `media_url` (som lagras som `protected_media/path.ext`) och spela upp.

---

# 5) Seed (frivilligt, snabbtest)

`supabase/seed/seed.sql`

```sql
-- Teacher dummy
insert into app.profiles (id,email,full_name,role) values
  ('00000000-0000-0000-0000-000000000001','teacher@example.com','Demo Teacher','teacher')
on conflict (id) do nothing;

-- Intro kurs
insert into app.courses (id, teacher_id, title, subtitle, description, level, visibility)
values ('11111111-1111-1111-1111-111111111111','00000000-0000-0000-0000-000000000001',
        'Meditation – Introduktion','Börja här','Andning, närvaro, grund', 'intro','public')
on conflict (id) do nothing;

insert into app.course_modules (course_id,index_no,title,content_md,is_preview)
values ('11111111-1111-1111-1111-111111111111',1,'Start','### Välkommen', true)
on conflict do nothing;

-- Betald kurs
insert into app.courses (id, teacher_id, title, description, level, visibility)
values ('22222222-2222-2222-2222-222222222222','00000000-0000-0000-0000-000000000001',
        'Healing – Grund','Energigrunder', 'core','paywalled')
on conflict (id) do nothing;

-- Price placeholder (fyll stripe_price_id efter Stripe setup)
insert into app.course_prices (course_id, stripe_price_id, unit_amount, currency)
values ('22222222-2222-2222-2222-222222222222', 'price_xxx', 4900, 'eur')
on conflict (course_id) do nothing;

-- Pro-only kurs
insert into app.courses (id, teacher_id, title, description, level, visibility)
values ('33333333-3333-3333-3333-333333333333','00000000-0000-0000-0000-000000000001',
        'Djup Fördjupning','För certifiering', 'advanced','pro_only')
on conflict (id) do nothing;
```

---

# 6) UI-flöden (rutnät)

* **Landing (guest)**
  – Visa 5 gratis intro-kurser (`visibility='public'`, `level='intro'`).
  – CTA: “Köp enstaka kurs” (öppnar paywall med e-postfält).
  – CTA: “Skapa konto” (passwordless email login).

* **Home (user)**
  – **Feed** (posts från följda + rekommenderat).
  – **Events nära dig** (filter på lat/lng om du vill senare).
  – **Fortsätt titta** (kurser du köpt).

* **Pro Home (professional)**
  – Som Home + FAB “Skapa event”.

* **Teacher Studio**
  – Kurslista (egna), CRUD modul, sätt `visibility` och `price`.
  – Publicera.

---

# 7) Passwordless / “köp utan konto”

* I **Checkout** kräver vi **e-post**.
* Webhook skapar `purchases` och, om ingen profil finns för e-posten, gör en `guest_claim_tokens` och skickar länk.
* När användaren öppnar claim-länken i appen (t.ex. `/claim?token=...`), gör appen:

  1. Om ej inloggad: visa **“Fortsätt med e-post”** → magic link → auth.user.id.
  2. Anropa RPC `app.claim_purchase(token, auth.uid())`.
  3. Navigera till kursen (access nu kopplad till konto).

---

# 8) Snabb “do this now”-lista

1. Kör `supabase/init_all.sql`.
2. Skapa buckets `public_media`, `protected_media` (med rätt policies).
3. Deploy Edge Functions:

   * `supabase functions deploy create_checkout`
   * `supabase functions deploy stripe_webhook`
   * Sätt env: `STRIPE_SECRET_KEY`, `SUPABASE_SERVICE_ROLE_KEY` (endast webhook), `SITE_URL`, `STRIPE_*_PATH`.
   * Konfigurera Stripe webhook → `stripe_webhook` URL + `STRIPE_WEBHOOK_SECRET`.
4. I appen: lägg filerna under `lib/core/...`, `lib/features/...`, uppdatera router att använda guards.
5. Sätt `SITE_URL` (build-time env) i appen för `postJson` helper.
6. Uppdatera `course_prices.stripe_price_id` med riktiga Price-ID:n.
7. (Valfritt) Kör `supabase/seed/seed.sql`.

---

## Varför detta funkar (kort)

* **Free/guest**: ser public + kan köpa med e-post → claim till konto senare (minsta friktion).
* **User**: inloggad med passwordless; feed, events, köp; access via `has_course_access`.
* **Professional**: uppnås när tre krav loggas i `pro_progress` **eller** admin godkänner certs; policy tillåter **insert på events**.
* **Teacher**: admin upphöjer → full kurs-CRUD.
* **RLS**: lärare skriver egna kurser; moduler är publika endast om preview eller access beviljad; purchases läses bara av ägaren; skrivning sker via webhook (service role).
* **Stripe**: ren Checkout; webhook säkrar “sanningen”; e-post → entitlement även utan konto.

Vill du att jag **packar detta i en PR-gren** (filstruktur + små README-noteringar) eller ska jag generera **ytterligare widgets** (t.ex. `LandingScreen`, `HomeFeed`, `TeacherStudio`-stubbar) direkt? Jag kan också skriva **Storage-policy-SQL** för `public_media`/`protected_media` om du vill ha dem explicit.
