-- Add video_url to app.courses (idempotent)

begin;

alter table if exists app.courses
  add column if not exists video_url text;

-- Migrate legacy intro_video_url data if column exists
DO $$
BEGIN
  IF exists (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'app'
      AND table_name = 'courses'
      AND column_name = 'intro_video_url'
  ) THEN
    UPDATE app.courses
    SET video_url = COALESCE(video_url, intro_video_url)
    WHERE intro_video_url IS NOT NULL
      AND (video_url IS NULL OR video_url = '');
  END IF;
END$$;

commit;
