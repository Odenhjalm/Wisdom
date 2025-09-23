-- Introduce app.teacher_permissions and compatibility view (idempotent)

begin;

create table if not exists app.teacher_permissions (
  profile_id uuid primary key references app.profiles(user_id) on delete cascade,
  can_edit_courses boolean not null default false,
  can_publish boolean not null default false,
  granted_by uuid null,
  granted_at timestamptz null
);

-- Backfill from legacy public.teacher_permissions (user_id column)
DO $$
BEGIN
  IF to_regclass('public.teacher_permissions') IS NOT NULL THEN
    INSERT INTO app.teacher_permissions (profile_id, can_edit_courses, can_publish, granted_by, granted_at)
    SELECT
      tp.user_id,
      COALESCE(tp.can_edit_courses, true),
      true,
      tp.granted_by,
      COALESCE(tp.created_at, tp.granted_at, now())
    FROM public.teacher_permissions tp
    ON CONFLICT (profile_id) DO UPDATE
      SET can_edit_courses = EXCLUDED.can_edit_courses,
          can_publish = true,
          granted_by = COALESCE(EXCLUDED.granted_by, app.teacher_permissions.granted_by),
          granted_at = COALESCE(EXCLUDED.granted_at, app.teacher_permissions.granted_at);
  END IF;
END$$;

-- Ensure all teachers/admins in profiles have permissions
INSERT INTO app.teacher_permissions (profile_id, can_edit_courses, can_publish, granted_by, granted_at)
SELECT
  p.user_id,
  true,
  true,
  null,
  now()
FROM app.profiles p
WHERE p.role IN ('teacher', 'admin')
ON CONFLICT (profile_id) DO UPDATE
  SET can_edit_courses = true,
      can_publish = true,
      granted_at = COALESCE(app.teacher_permissions.granted_at, EXCLUDED.granted_at);

-- Compatibility view for legacy queries
DROP VIEW IF EXISTS public.teacher_permissions_compat;
CREATE VIEW public.teacher_permissions_compat AS
SELECT
  tp.profile_id,
  tp.profile_id AS user_id,
  tp.can_edit_courses,
  tp.can_publish,
  tp.granted_by,
  tp.granted_at
FROM app.teacher_permissions tp;

GRANT SELECT ON public.teacher_permissions_compat TO anon, authenticated;

commit;
