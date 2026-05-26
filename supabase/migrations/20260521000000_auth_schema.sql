-- ============================================================
-- DROP EXISTING TABLES
-- ============================================================

DROP TABLE IF EXISTS public.audit_events        CASCADE;
DROP TABLE IF EXISTS public.measurements        CASCADE;
DROP TABLE IF EXISTS public.parent_access       CASCADE;
DROP TABLE IF EXISTS public.transfer_requests   CASCADE;
DROP TABLE IF EXISTS public.babies              CASCADE;
DROP TABLE IF EXISTS public.devices             CASCADE;
DROP TABLE IF EXISTS public.user_profiles       CASCADE;
DROP TABLE IF EXISTS public.hospitals           CASCADE;

-- ============================================================
-- TABLES
-- ============================================================

CREATE TABLE public.hospitals (
  hospital_id   uuid        NOT NULL DEFAULT gen_random_uuid(),
  hospital_name text        NOT NULL,
  hospital_code text        NOT NULL,
  created_at    timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT hospitals_pkey             PRIMARY KEY (hospital_id),
  CONSTRAINT hospitals_code_key         UNIQUE (hospital_code)
);

CREATE TABLE public.user_profiles (
  user_id     uuid        NOT NULL,
  hospital_id uuid        NOT NULL,
  role        text        NOT NULL,
  full_name   text        NOT NULL,
  is_active   boolean     NOT NULL DEFAULT true,
  created_at  timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT user_profiles_pkey              PRIMARY KEY (user_id),
  CONSTRAINT user_profiles_role_check        CHECK (role = ANY (ARRAY['admin','staff','parent'])),
  CONSTRAINT user_profiles_user_id_fkey      FOREIGN KEY (user_id)     REFERENCES auth.users(id),
  CONSTRAINT user_profiles_hospital_id_fkey  FOREIGN KEY (hospital_id) REFERENCES public.hospitals(hospital_id)
);

CREATE TABLE public.babies (
  baby_id     uuid        NOT NULL DEFAULT gen_random_uuid(),
  hospital_id uuid        NOT NULL,
  baby_name   text        NOT NULL,
  baby_dob    timestamptz NOT NULL,
  baby_weight numeric     NOT NULL,
  is_archived boolean     NOT NULL DEFAULT false,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT babies_pkey              PRIMARY KEY (baby_id),
  CONSTRAINT babies_hospital_id_fkey  FOREIGN KEY (hospital_id) REFERENCES public.hospitals(hospital_id)
);

CREATE TABLE public.measurements (
  measurement_id      uuid        NOT NULL,
  baby_id             uuid        NOT NULL,
  device_id           uuid,
  captured_at         timestamptz NOT NULL,
  received_at         timestamptz NOT NULL,
  age_hours           numeric     NOT NULL,
  bilirubin_mgdl      numeric     NOT NULL,
  has_image           boolean     NOT NULL DEFAULT false,
  encrypted_image_ref text,
  model_version       text,
  CONSTRAINT measurements_pkey          PRIMARY KEY (measurement_id),
  CONSTRAINT measurements_baby_id_fkey  FOREIGN KEY (baby_id) REFERENCES public.babies(baby_id) ON DELETE CASCADE
);

CREATE TABLE public.devices (
  device_id    uuid        NOT NULL,
  hospital_id  uuid        NOT NULL,
  display_name text        NOT NULL,
  paired_at    timestamptz NOT NULL DEFAULT now(),
  transport    text        NOT NULL,
  ssid         text,
  last_seen_at timestamptz,
  CONSTRAINT devices_pkey                    PRIMARY KEY (device_id),
  CONSTRAINT devices_transport_check         CHECK (transport = ANY (ARRAY['hotspot','ble'])),
  CONSTRAINT devices_hospital_id_fkey        FOREIGN KEY (hospital_id) REFERENCES public.hospitals(hospital_id),
  CONSTRAINT devices_hospital_name_unique    UNIQUE (hospital_id, display_name)
);

CREATE TABLE public.parent_access (
  parent_id   uuid        NOT NULL,
  baby_id     uuid        NOT NULL,
  hospital_id uuid        NOT NULL,
  granted_by  uuid,
  linked_at   timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT parent_access_pkey                PRIMARY KEY (parent_id, baby_id),
  CONSTRAINT parent_access_parent_profile_fkey FOREIGN KEY (parent_id) REFERENCES public.user_profiles(user_id),
  CONSTRAINT parent_access_baby_id_fkey        FOREIGN KEY (baby_id)   REFERENCES public.babies(baby_id) ON DELETE CASCADE,
  CONSTRAINT parent_access_hospital_id_fkey  FOREIGN KEY (hospital_id) REFERENCES public.hospitals(hospital_id),
  CONSTRAINT parent_access_granted_by_fkey   FOREIGN KEY (granted_by)  REFERENCES auth.users(id)
);

CREATE TABLE public.transfer_requests (
  transfer_id      uuid        NOT NULL DEFAULT gen_random_uuid(),
  baby_id          uuid        NOT NULL,
  from_hospital_id uuid        NOT NULL,
  to_hospital_id   uuid        NOT NULL,
  initiated_by     uuid        NOT NULL,
  initiated_at     timestamptz NOT NULL DEFAULT now(),
  resolved_by      uuid,
  resolved_at      timestamptz,
  status           text        NOT NULL DEFAULT 'pending',
  notes            text,
  CONSTRAINT transfer_requests_pkey                  PRIMARY KEY (transfer_id),
  CONSTRAINT transfer_requests_status_check          CHECK (status = ANY (ARRAY['pending','accepted','rejected','cancelled'])),
  CONSTRAINT transfer_requests_baby_id_fkey          FOREIGN KEY (baby_id)          REFERENCES public.babies(baby_id) ON DELETE CASCADE,
  CONSTRAINT transfer_requests_from_hospital_id_fkey FOREIGN KEY (from_hospital_id) REFERENCES public.hospitals(hospital_id),
  CONSTRAINT transfer_requests_to_hospital_id_fkey   FOREIGN KEY (to_hospital_id)   REFERENCES public.hospitals(hospital_id),
  CONSTRAINT transfer_requests_initiated_by_fkey     FOREIGN KEY (initiated_by)     REFERENCES auth.users(id),
  CONSTRAINT transfer_requests_resolved_by_fkey      FOREIGN KEY (resolved_by)      REFERENCES auth.users(id)
);

CREATE TABLE public.audit_events (
  audit_event_id uuid        NOT NULL,
  hospital_id    uuid        REFERENCES public.hospitals(hospital_id),
  created_at     timestamptz NOT NULL DEFAULT now(),
  event_type     text        NOT NULL,
  baby_id        uuid,
  measurement_id uuid,
  device_id      uuid,
  details_json   text,
  CONSTRAINT audit_events_pkey PRIMARY KEY (audit_event_id)
);

-- ============================================================
-- ENABLE ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE public.hospitals          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.babies             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.measurements       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.devices            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parent_access      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transfer_requests  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_events       ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

CREATE OR REPLACE FUNCTION public.current_user_hospital_id()
RETURNS uuid
LANGUAGE sql STABLE SECURITY DEFINER
AS $$
  SELECT hospital_id FROM public.user_profiles
  WHERE user_id = auth.uid() AND is_active = true;
$$;

CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS text
LANGUAGE sql STABLE SECURITY DEFINER
AS $$
  SELECT role FROM public.user_profiles
  WHERE user_id = auth.uid() AND is_active = true;
$$;

-- ============================================================
-- RLS POLICIES: hospitals
-- ============================================================

CREATE POLICY hospitals_select ON public.hospitals
  FOR SELECT TO authenticated
  USING (hospital_id = public.current_user_hospital_id());

CREATE POLICY hospitals_update ON public.hospitals
  FOR UPDATE TO authenticated
  USING (
    hospital_id = public.current_user_hospital_id()
    AND public.current_user_role() = 'admin'
  );

-- ============================================================
-- RLS POLICIES: user_profiles
-- ============================================================

CREATE POLICY user_profiles_select ON public.user_profiles
  FOR SELECT TO authenticated
  USING (
    user_id = auth.uid()
    OR (
      hospital_id = public.current_user_hospital_id()
      AND public.current_user_role() = 'admin'
    )
  );

CREATE POLICY user_profiles_insert ON public.user_profiles
  FOR INSERT TO authenticated
  WITH CHECK (
    user_id = auth.uid()
    OR (
      hospital_id = public.current_user_hospital_id()
      AND public.current_user_role() = 'admin'
    )
  );

-- Own profile updates (e.g. name change)
CREATE POLICY user_profiles_update_self ON public.user_profiles
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid());

-- Admin toggling is_active on other users in the same hospital
CREATE POLICY user_profiles_admin_update ON public.user_profiles
  FOR UPDATE TO authenticated
  USING (
    hospital_id = public.current_user_hospital_id()
    AND public.current_user_role() = 'admin'
    AND user_id <> auth.uid()
  );

CREATE POLICY user_profiles_delete ON public.user_profiles
  FOR DELETE TO authenticated
  USING (
    hospital_id = public.current_user_hospital_id()
    AND public.current_user_role() = 'admin'
  );

-- ============================================================
-- RLS POLICIES: babies
-- ============================================================

CREATE POLICY babies_select_staff ON public.babies
  FOR SELECT TO authenticated
  USING (
    hospital_id = public.current_user_hospital_id()
    AND public.current_user_role() IN ('admin', 'staff')
  );

CREATE POLICY babies_select_parent ON public.babies
  FOR SELECT TO authenticated
  USING (
    public.current_user_role() = 'parent'
    AND EXISTS (
      SELECT 1 FROM public.parent_access
      WHERE parent_access.parent_id = auth.uid()
      AND   parent_access.baby_id   = babies.baby_id
    )
  );

CREATE POLICY babies_insert ON public.babies
  FOR INSERT TO authenticated
  WITH CHECK (
    hospital_id = public.current_user_hospital_id()
    AND public.current_user_role() IN ('admin', 'staff')
  );

CREATE POLICY babies_update ON public.babies
  FOR UPDATE TO authenticated
  USING (
    hospital_id = public.current_user_hospital_id()
    AND public.current_user_role() IN ('admin', 'staff')
  );

CREATE POLICY babies_delete ON public.babies
  FOR DELETE TO authenticated
  USING (
    hospital_id = public.current_user_hospital_id()
    AND public.current_user_role() IN ('admin', 'staff')
  );

-- ============================================================
-- RLS POLICIES: measurements
-- ============================================================

CREATE POLICY measurements_select_staff ON public.measurements
  FOR SELECT TO authenticated
  USING (
    public.current_user_role() IN ('admin', 'staff')
    AND EXISTS (
      SELECT 1 FROM public.babies
      WHERE babies.baby_id     = measurements.baby_id
      AND   babies.hospital_id = public.current_user_hospital_id()
    )
  );

CREATE POLICY measurements_select_parent ON public.measurements
  FOR SELECT TO authenticated
  USING (
    public.current_user_role() = 'parent'
    AND EXISTS (
      SELECT 1 FROM public.parent_access
      WHERE parent_access.parent_id = auth.uid()
      AND   parent_access.baby_id   = measurements.baby_id
    )
  );

CREATE POLICY measurements_insert ON public.measurements
  FOR INSERT TO authenticated
  WITH CHECK (
    public.current_user_role() IN ('admin', 'staff')
    AND EXISTS (
      SELECT 1 FROM public.babies
      WHERE babies.baby_id     = measurements.baby_id
      AND   babies.hospital_id = public.current_user_hospital_id()
    )
  );

CREATE POLICY measurements_update ON public.measurements
  FOR UPDATE TO authenticated
  USING (
    public.current_user_role() IN ('admin', 'staff')
    AND EXISTS (
      SELECT 1 FROM public.babies
      WHERE babies.baby_id     = measurements.baby_id
      AND   babies.hospital_id = public.current_user_hospital_id()
    )
  );

CREATE POLICY measurements_delete ON public.measurements
  FOR DELETE TO authenticated
  USING (
    public.current_user_role() IN ('admin', 'staff')
    AND EXISTS (
      SELECT 1 FROM public.babies
      WHERE babies.baby_id     = measurements.baby_id
      AND   babies.hospital_id = public.current_user_hospital_id()
    )
  );

-- ============================================================
-- RLS POLICIES: devices
-- ============================================================

CREATE POLICY devices_select ON public.devices
  FOR SELECT TO authenticated
  USING (
    hospital_id = public.current_user_hospital_id()
    AND public.current_user_role() IN ('admin', 'staff')
  );

CREATE POLICY devices_insert ON public.devices
  FOR INSERT TO authenticated
  WITH CHECK (
    hospital_id = public.current_user_hospital_id()
    AND public.current_user_role() = 'admin'
  );

CREATE POLICY devices_update ON public.devices
  FOR UPDATE TO authenticated
  USING (
    hospital_id = public.current_user_hospital_id()
    AND public.current_user_role() = 'admin'
  );

CREATE POLICY devices_delete ON public.devices
  FOR DELETE TO authenticated
  USING (
    hospital_id = public.current_user_hospital_id()
    AND public.current_user_role() = 'admin'
  );

-- ============================================================
-- RLS POLICIES: parent_access
-- ============================================================

CREATE POLICY parent_access_select_admin ON public.parent_access
  FOR SELECT TO authenticated
  USING (
    hospital_id = public.current_user_hospital_id()
    AND public.current_user_role() = 'admin'
  );

CREATE POLICY parent_access_select_parent ON public.parent_access
  FOR SELECT TO authenticated
  USING (
    parent_id = auth.uid()
    AND public.current_user_role() = 'parent'
  );

CREATE POLICY parent_access_insert ON public.parent_access
  FOR INSERT TO authenticated
  WITH CHECK (
    hospital_id = public.current_user_hospital_id()
    AND public.current_user_role() = 'admin'
  );

CREATE POLICY parent_access_update ON public.parent_access
  FOR UPDATE TO authenticated
  USING (
    hospital_id = public.current_user_hospital_id()
    AND public.current_user_role() = 'admin'
  );

CREATE POLICY parent_access_delete ON public.parent_access
  FOR DELETE TO authenticated
  USING (
    hospital_id = public.current_user_hospital_id()
    AND public.current_user_role() = 'admin'
  );

-- ============================================================
-- RLS POLICIES: transfer_requests
-- ============================================================

CREATE POLICY transfer_requests_select ON public.transfer_requests
  FOR SELECT TO authenticated
  USING (
    public.current_user_role() = 'admin'
    AND (
      from_hospital_id = public.current_user_hospital_id()
      OR to_hospital_id = public.current_user_hospital_id()
    )
  );

CREATE POLICY transfer_requests_insert ON public.transfer_requests
  FOR INSERT TO authenticated
  WITH CHECK (
    public.current_user_role() = 'admin'
    AND from_hospital_id = public.current_user_hospital_id()
  );

CREATE POLICY transfer_requests_update ON public.transfer_requests
  FOR UPDATE TO authenticated
  USING (
    public.current_user_role() = 'admin'
    AND (
      from_hospital_id = public.current_user_hospital_id()
      OR to_hospital_id = public.current_user_hospital_id()
    )
  );

CREATE POLICY transfer_requests_delete ON public.transfer_requests
  FOR DELETE TO authenticated
  USING (
    public.current_user_role() = 'admin'
    AND from_hospital_id = public.current_user_hospital_id()
  );

-- ============================================================
-- RLS POLICIES: audit_events
-- ============================================================

CREATE POLICY audit_events_select ON public.audit_events
  FOR SELECT TO authenticated
  USING (
    hospital_id = public.current_user_hospital_id()
    AND public.current_user_role() = 'admin'
  );

CREATE POLICY audit_events_insert ON public.audit_events
  FOR INSERT TO authenticated
  WITH CHECK (
    hospital_id = public.current_user_hospital_id()
  );
