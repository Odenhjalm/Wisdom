-- Phase A: Introduce blueprint role schema (idempotent)

begin;

-- Ensure new enum exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE t.typname = 'user_role' AND n.nspname = 'app'
  ) THEN
    CREATE TYPE app.user_role AS ENUM ('user','professional','teacher');
  END IF;
END$$;

-- Extend profiles for admin flag
ALTER TABLE app.profiles
  ADD COLUMN IF NOT EXISTS is_admin boolean NOT NULL DEFAULT false;

-- Temporary column for new role
ALTER TABLE app.profiles
  ADD COLUMN IF NOT EXISTS role_v2 app.user_role NOT NULL DEFAULT 'user';

-- Map legacy roles into role_v2 + admin flag
UPDATE app.profiles SET role_v2 = 'user'
WHERE role_v2 = 'user' AND role::text = 'user';

UPDATE app.profiles SET role_v2 = 'professional'
WHERE role::text = 'member';

UPDATE app.profiles SET role_v2 = 'teacher'
WHERE role::text = 'teacher';

UPDATE app.profiles SET role_v2 = 'teacher', is_admin = true
WHERE role::text = 'admin';

-- Create progression tables
CREATE TABLE IF NOT EXISTS app.pro_requirements (
  id serial PRIMARY KEY,
  code text UNIQUE NOT NULL,
  title text NOT NULL
);

INSERT INTO app.pro_requirements (code, title) VALUES
  ('STEP1','Grundutbildning'),
  ('STEP2','Fördjupning'),
  ('STEP3','Praktik')
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS app.pro_progress (
  user_id uuid REFERENCES app.profiles(user_id) ON DELETE CASCADE,
  requirement_id int REFERENCES app.pro_requirements(id) ON DELETE CASCADE,
  completed_at timestamptz DEFAULT now(),
  PRIMARY KEY (user_id, requirement_id)
);

CREATE TABLE IF NOT EXISTS app.certificates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES app.profiles(user_id) ON DELETE CASCADE,
  title text NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  evidence_url text,
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS app.teacher_approvals (
  user_id uuid PRIMARY KEY REFERENCES app.profiles(user_id) ON DELETE CASCADE,
  approved_by uuid,
  approved_at timestamptz
);

-- Grant professionals automatically when requirements met
CREATE OR REPLACE FUNCTION app.grant_professional_if_ready(p_user uuid)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE
  req_count int;
  done_count int;
BEGIN
  SELECT COUNT(*) INTO req_count FROM app.pro_requirements;
  SELECT COUNT(*) INTO done_count FROM app.pro_progress WHERE user_id = p_user;

  IF done_count >= req_count AND req_count > 0 THEN
    UPDATE app.profiles
      SET role_v2 = CASE WHEN role_v2 = 'teacher' THEN role_v2 ELSE 'professional' END,
          updated_at = now()
    WHERE user_id = p_user;
  END IF;
END;
$$;

commit;
