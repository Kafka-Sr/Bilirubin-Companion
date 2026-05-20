-- Migration: 20260516_000002_simple_schema
-- Replaces the auth-era composite-PK tables with a single-hospital schema.
-- Apply this in the Supabase dashboard → SQL Editor.

-- Drop auth-era tables (safe to rerun — IF EXISTS guards).
DROP TABLE IF EXISTS public.measurements;
DROP TABLE IF EXISTS public.babies;

-- ── Babies ────────────────────────────────────────────────────────────────────

CREATE TABLE public.babies (
  baby_id     bigint PRIMARY KEY,   -- synced from SQLite autoincrement
  baby_name   text    NOT NULL,
  baby_dob    timestamptz NOT NULL,
  baby_weight numeric NOT NULL,
  is_archived boolean NOT NULL DEFAULT false,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

-- ── Measurements ──────────────────────────────────────────────────────────────

CREATE TABLE public.measurements (
  measurement_id      text PRIMARY KEY,
  baby_id             bigint REFERENCES public.babies(baby_id),
  captured_at         timestamptz NOT NULL,
  received_at         timestamptz NOT NULL,  -- serves as created_at
  age_hours           numeric NOT NULL,
  bilirubin_mgdl      numeric NOT NULL,
  has_image           boolean NOT NULL DEFAULT false,
  encrypted_image_ref text,
  device_id           text,
  model_version       text
);

-- ── Row Level Security ────────────────────────────────────────────────────────
-- Permissive anon access for single-hospital use.
-- Tighten these policies when auth is added.

ALTER TABLE public.babies      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.measurements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "anon_all" ON public.babies
  FOR ALL TO anon USING (true) WITH CHECK (true);

CREATE POLICY "anon_all" ON public.measurements
  FOR ALL TO anon USING (true) WITH CHECK (true);
