-- Dummy data seed for Supabase.
-- Run in: Supabase Dashboard → SQL Editor, or via psql.
-- Safe to re-run: uses INSERT ... ON CONFLICT DO UPDATE.

-- ── Clean (optional) ─────────────────────────────────────────────────────────
-- Uncomment these two lines to wipe existing rows first:
-- DELETE FROM public.measurements;
-- DELETE FROM public.babies;

-- ── Babies ────────────────────────────────────────────────────────────────────
-- 5 newborns, 0–7 days old as of 2026-05-17.

INSERT INTO public.babies (baby_id, baby_name, baby_dob, baby_weight, is_archived, created_at, updated_at)
VALUES
  (1, 'Aisha Putri',    '2026-05-17 02:30:00+00', 3.25, false, now(), now()),
  (2, 'Bima Saputra',   '2026-05-15 14:10:00+00', 3.80, false, now(), now()),
  (3, 'Citra Dewi',     '2026-05-13 08:45:00+00', 2.95, false, now(), now()),
  (4, 'Danu Pratama',   '2026-05-11 21:00:00+00', 4.10, false, now(), now()),
  (5, 'Elsa Rahayu',    '2026-05-10 06:20:00+00', 3.55, true,  now(), now())
ON CONFLICT (baby_id) DO UPDATE SET
  baby_name   = EXCLUDED.baby_name,
  baby_dob    = EXCLUDED.baby_dob,
  baby_weight = EXCLUDED.baby_weight,
  is_archived = EXCLUDED.is_archived,
  updated_at  = now();

-- ── Measurements ─────────────────────────────────────────────────────────────
-- Readings follow a rough physiological curve: bilirubin rises to ~12 mg/dL
-- around 72 h then gradually falls.  Each baby has 6 readings spread across
-- their first 7 days.

INSERT INTO public.measurements
  (measurement_id, baby_id, captured_at, received_at, age_hours, bilirubin_mgdl,
   has_image, encrypted_image_ref, device_id, model_version)
VALUES

  -- Baby 1 · Aisha Putri (DOB 2026-05-17 02:30, ~0 days old)
  ('m-aisha-01', 1, '2026-05-17 06:30:00+00', '2026-05-17 06:30:08+00',  4.0,  1.20, false, null, 'Biligun-001', 'v1.0.0'),
  ('m-aisha-02', 1, '2026-05-17 10:30:00+00', '2026-05-17 10:30:05+00',  8.0,  2.50, false, null, 'Biligun-001', 'v1.0.0'),

  -- Baby 2 · Bima Saputra (DOB 2026-05-15 14:10, ~2 days old)
  ('m-bima-01',  2, '2026-05-15 22:10:00+00', '2026-05-15 22:10:03+00',  8.0,  3.40, false, null, 'Biligun-001', 'v1.0.0'),
  ('m-bima-02',  2, '2026-05-16 14:10:00+00', '2026-05-16 14:10:07+00', 24.0,  6.80, false, null, 'Biligun-002', 'v1.0.0'),
  ('m-bima-03',  2, '2026-05-17 02:10:00+00', '2026-05-17 02:10:04+00', 36.0,  9.20, false, null, 'Biligun-002', 'v1.0.0'),
  ('m-bima-04',  2, '2026-05-17 14:10:00+00', '2026-05-17 14:10:06+00', 48.0, 11.50, false, null, 'Biligun-001', 'v1.0.0'),

  -- Baby 3 · Citra Dewi (DOB 2026-05-13 08:45, ~4 days old — near peak)
  ('m-citra-01', 3, '2026-05-13 20:45:00+00', '2026-05-13 20:45:09+00', 12.0,  5.10, false, null, 'Biligun-003', 'v1.0.0'),
  ('m-citra-02', 3, '2026-05-14 08:45:00+00', '2026-05-14 08:45:02+00', 24.0,  7.80, false, null, 'Biligun-003', 'v1.0.0'),
  ('m-citra-03', 3, '2026-05-14 20:45:00+00', '2026-05-14 20:45:05+00', 36.0, 10.30, false, null, 'Biligun-003', 'v1.0.0'),
  ('m-citra-04', 3, '2026-05-15 08:45:00+00', '2026-05-15 08:45:08+00', 48.0, 12.60, false, null, 'Biligun-002', 'v1.0.0'),
  ('m-citra-05', 3, '2026-05-15 20:45:00+00', '2026-05-15 20:45:03+00', 60.0, 13.40, false, null, 'Biligun-002', 'v1.0.0'),
  ('m-citra-06', 3, '2026-05-16 08:45:00+00', '2026-05-16 08:45:06+00', 72.0, 13.80, false, null, 'Biligun-003', 'v1.0.0'),

  -- Baby 4 · Danu Pratama (DOB 2026-05-11 21:00, ~6 days old — declining phase)
  ('m-danu-01',  4, '2026-05-12 09:00:00+00', '2026-05-12 09:00:04+00', 12.0,  4.90, false, null, 'Biligun-001', 'v1.0.0'),
  ('m-danu-02',  4, '2026-05-12 21:00:00+00', '2026-05-12 21:00:07+00', 24.0,  7.60, false, null, 'Biligun-001', 'v1.0.0'),
  ('m-danu-03',  4, '2026-05-13 21:00:00+00', '2026-05-13 21:00:05+00', 48.0, 11.90, false, null, 'Biligun-002', 'v1.0.0'),
  ('m-danu-04',  4, '2026-05-14 21:00:00+00', '2026-05-14 21:00:03+00', 72.0, 13.70, false, null, 'Biligun-002', 'v1.0.0'),
  ('m-danu-05',  4, '2026-05-15 21:00:00+00', '2026-05-15 21:00:09+00', 96.0, 11.20, false, null, 'Biligun-001', 'v1.0.0'),
  ('m-danu-06',  4, '2026-05-16 21:00:00+00', '2026-05-16 21:00:02+00',120.0,  8.50, false, null, 'Biligun-001', 'v1.0.0'),

  -- Baby 5 · Elsa Rahayu (DOB 2026-05-10 06:20, ~7 days old — archived, low values)
  ('m-elsa-01',  5, '2026-05-10 18:20:00+00', '2026-05-10 18:20:06+00', 12.0,  4.20, false, null, 'Biligun-003', 'v1.0.0'),
  ('m-elsa-02',  5, '2026-05-11 06:20:00+00', '2026-05-11 06:20:04+00', 24.0,  6.90, false, null, 'Biligun-003', 'v1.0.0'),
  ('m-elsa-03',  5, '2026-05-11 18:20:00+00', '2026-05-11 18:20:08+00', 36.0,  9.50, false, null, 'Biligun-003', 'v1.0.0'),
  ('m-elsa-04',  5, '2026-05-12 06:20:00+00', '2026-05-12 06:20:03+00', 48.0, 12.10, false, null, 'Biligun-002', 'v1.0.0'),
  ('m-elsa-05',  5, '2026-05-13 06:20:00+00', '2026-05-13 06:20:07+00', 72.0, 13.50, false, null, 'Biligun-002', 'v1.0.0'),
  ('m-elsa-06',  5, '2026-05-14 06:20:00+00', '2026-05-14 06:20:05+00', 96.0, 10.80, false, null, 'Biligun-003', 'v1.0.0')

ON CONFLICT (measurement_id) DO UPDATE SET
  bilirubin_mgdl      = EXCLUDED.bilirubin_mgdl,
  age_hours           = EXCLUDED.age_hours,
  captured_at         = EXCLUDED.captured_at,
  received_at         = EXCLUDED.received_at,
  device_id           = EXCLUDED.device_id,
  model_version       = EXCLUDED.model_version;
