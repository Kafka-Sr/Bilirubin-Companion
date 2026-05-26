-- Replaces the parent_access.parent_id FK so it points to public.user_profiles
-- instead of auth.users, enabling the PostgREST user_profiles(full_name) join.
-- Idempotent: safe to run regardless of whether the change was already applied.

ALTER TABLE public.parent_access
  DROP CONSTRAINT IF EXISTS parent_access_parent_id_fkey;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_schema = 'public'
      AND table_name        = 'parent_access'
      AND constraint_name   = 'parent_access_parent_profile_fkey'
  ) THEN
    ALTER TABLE public.parent_access
      ADD CONSTRAINT parent_access_parent_profile_fkey
        FOREIGN KEY (parent_id) REFERENCES public.user_profiles(user_id);
  END IF;
END $$;
