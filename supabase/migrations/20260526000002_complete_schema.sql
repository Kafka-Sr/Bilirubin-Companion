-- ============================================================
-- Schema corrections to match the canonical database design:
--   1. devices   — drop transport column, make hospital_id nullable,
--                  drop unique(hospital_id, display_name)
--   2. measurements — make bilirubin_mgdl nullable,
--                     remove ON DELETE CASCADE from baby_id FK
--   3. parent_access     — remove ON DELETE CASCADE from baby_id FK
--   4. transfer_requests — remove ON DELETE CASCADE from baby_id FK
-- ============================================================

-- ── devices ─────────────────────────────────────────────────────────────────

-- Dropping transport drops the CHECK constraint automatically.
ALTER TABLE public.devices DROP COLUMN IF EXISTS transport;

ALTER TABLE public.devices DROP CONSTRAINT IF EXISTS devices_hospital_name_unique;

-- hospital_id: NOT NULL → nullable
ALTER TABLE public.devices ALTER COLUMN hospital_id DROP NOT NULL;

-- ── measurements ─────────────────────────────────────────────────────────────

-- bilirubin_mgdl: NOT NULL → nullable
ALTER TABLE public.measurements ALTER COLUMN bilirubin_mgdl DROP NOT NULL;

-- Recreate baby_id FK without ON DELETE CASCADE
ALTER TABLE public.measurements
  DROP CONSTRAINT IF EXISTS measurements_baby_id_fkey;

ALTER TABLE public.measurements
  ADD CONSTRAINT measurements_baby_id_fkey
    FOREIGN KEY (baby_id) REFERENCES public.babies(baby_id);

-- ── parent_access ─────────────────────────────────────────────────────────────

ALTER TABLE public.parent_access
  DROP CONSTRAINT IF EXISTS parent_access_baby_id_fkey;

ALTER TABLE public.parent_access
  ADD CONSTRAINT parent_access_baby_id_fkey
    FOREIGN KEY (baby_id) REFERENCES public.babies(baby_id);

-- ── transfer_requests ─────────────────────────────────────────────────────────

ALTER TABLE public.transfer_requests
  DROP CONSTRAINT IF EXISTS transfer_requests_baby_id_fkey;

ALTER TABLE public.transfer_requests
  ADD CONSTRAINT transfer_requests_baby_id_fkey
    FOREIGN KEY (baby_id) REFERENCES public.babies(baby_id);
