-- =========================================================
-- ORCA - Marine Ecosystem Reasoning with Collaborative Agents
-- Database Schema
-- PostgreSQL / Supabase
-- =========================================================

-- =========================================================
-- 1. PROFILES
-- Additional information for authenticated ORCA users
-- =========================================================

CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT,
    phone_number TEXT,
    preferred_language TEXT DEFAULT 'English',
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- =========================================================
-- 2. DATA SOURCES
-- INCOIS, ISRO, IMD, CMEMS, etc.
-- =========================================================

CREATE TABLE IF NOT EXISTS public.data_sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    organization TEXT,
    source_type TEXT,
    api_url TEXT,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_updated TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- =========================================================
-- 3. OCEAN REGIONS
-- Geographic marine regions
-- =========================================================

CREATE TABLE IF NOT EXISTS public.ocean_regions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- =========================================================
-- 4. USER LOCATIONS
-- GPS locations recorded for users
-- =========================================================

CREATE TABLE IF NOT EXISTS public.user_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    latitude NUMERIC(9,6) NOT NULL,
    longitude NUMERIC(9,6) NOT NULL,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- =========================================================
-- 5. SAVED LOCATIONS
-- Locations saved by users
-- =========================================================

CREATE TABLE IF NOT EXISTS public.saved_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    latitude NUMERIC(9,6) NOT NULL,
    longitude NUMERIC(9,6) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- =========================================================
-- 6. OCEAN OBSERVATIONS
-- SST, chlorophyll, salinity, waves, currents, etc.
-- =========================================================

CREATE TABLE IF NOT EXISTS public.ocean_observations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    region_id UUID REFERENCES public.ocean_regions(id) ON DELETE SET NULL,
    source_id UUID REFERENCES public.data_sources(id) ON DELETE SET NULL,

    latitude NUMERIC(9,6) NOT NULL,
    longitude NUMERIC(9,6) NOT NULL,

    sea_surface_temperature NUMERIC(6,2),
    chlorophyll NUMERIC(10,4),
    salinity NUMERIC(8,3),

    wave_height NUMERIC(6,2),
    wave_direction NUMERIC(6,2),

    current_speed NUMERIC(8,3),
    current_direction NUMERIC(6,2),

    observation_time TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- =========================================================
-- 7. WEATHER DATA
-- Weather and marine weather information
-- =========================================================

CREATE TABLE IF NOT EXISTS public.weather_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    region_id UUID REFERENCES public.ocean_regions(id) ON DELETE SET NULL,
    source_id UUID REFERENCES public.data_sources(id) ON DELETE SET NULL,

    latitude NUMERIC(9,6) NOT NULL,
    longitude NUMERIC(9,6) NOT NULL,

    temperature NUMERIC(6,2),
    wind_speed NUMERIC(8,2),
    wind_direction NUMERIC(6,2),
    humidity NUMERIC(6,2),
    pressure NUMERIC(8,2),
    rainfall NUMERIC(8,2),
    visibility NUMERIC(8,2),
    wave_height NUMERIC(6,2),

    forecast_time TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- =========================================================
-- 8. TIDE DATA
-- High tide / low tide information
-- =========================================================

CREATE TABLE IF NOT EXISTS public.tide_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    region_id UUID REFERENCES public.ocean_regions(id) ON DELETE SET NULL,
    source_id UUID REFERENCES public.data_sources(id) ON DELETE SET NULL,

    latitude NUMERIC(9,6) NOT NULL,
    longitude NUMERIC(9,6) NOT NULL,

    tide_type TEXT NOT NULL,
    tide_height NUMERIC(8,3),
    tide_time TIMESTAMPTZ NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT tide_type_check
        CHECK (tide_type IN ('HIGH', 'LOW'))
);


-- =========================================================
-- 9. POTENTIAL FISHING ZONES
-- PFZ information
-- =========================================================

CREATE TABLE IF NOT EXISTS public.pfz_zones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    region_id UUID REFERENCES public.ocean_regions(id) ON DELETE SET NULL,
    source_id UUID REFERENCES public.data_sources(id) ON DELETE SET NULL,

    name TEXT NOT NULL,

    latitude NUMERIC(9,6) NOT NULL,
    longitude NUMERIC(9,6) NOT NULL,

    area_description TEXT,
    confidence_score NUMERIC(5,2),

    species TEXT,

    valid_from TIMESTAMPTZ NOT NULL,
    valid_until TIMESTAMPTZ NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pfz_confidence_check
        CHECK (
            confidence_score IS NULL
            OR (confidence_score >= 0 AND confidence_score <= 100)
        )
);


-- =========================================================
-- 10. MARINE ALERTS
-- Cyclone, tsunami, high waves, strong winds, etc.
-- =========================================================

CREATE TABLE IF NOT EXISTS public.marine_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    region_id UUID REFERENCES public.ocean_regions(id) ON DELETE SET NULL,
    source_id UUID REFERENCES public.data_sources(id) ON DELETE SET NULL,

    alert_type TEXT NOT NULL,
    severity TEXT NOT NULL,

    title TEXT NOT NULL,
    description TEXT,

    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6),

    issued_at TIMESTAMPTZ NOT NULL,
    expires_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT alert_severity_check
        CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL'))
);


-- =========================================================
-- 11. SAFETY REPORTS
-- Community reports from fishermen/users
-- =========================================================

CREATE TABLE IF NOT EXISTS public.safety_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,

    latitude NUMERIC(9,6) NOT NULL,
    longitude NUMERIC(9,6) NOT NULL,

    report_type TEXT NOT NULL,
    description TEXT,
    severity TEXT,

    reported_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    status TEXT NOT NULL DEFAULT 'OPEN'
);


-- =========================================================
-- 12. SOS EVENTS
-- Emergency assistance requests
-- =========================================================

CREATE TABLE IF NOT EXISTS public.sos_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,

    latitude NUMERIC(9,6) NOT NULL,
    longitude NUMERIC(9,6) NOT NULL,

    message TEXT,
    severity TEXT NOT NULL DEFAULT 'CRITICAL',

    status TEXT NOT NULL DEFAULT 'ACTIVE',

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);


-- =========================================================
-- 13. CHAT SESSIONS
-- Ask ORCA conversations
-- =========================================================

CREATE TABLE IF NOT EXISTS public.chat_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,

    title TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- =========================================================
-- 14. CHAT MESSAGES
-- Individual Ask ORCA messages
-- =========================================================

CREATE TABLE IF NOT EXISTS public.chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    session_id UUID NOT NULL REFERENCES public.chat_sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,

    role TEXT NOT NULL,
    message TEXT NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chat_role_check
        CHECK (role IN ('USER', 'ORCA'))
);


-- =========================================================
-- 15. AI AGENT RESULTS
-- Results generated by ORCA collaborative agents
-- =========================================================

CREATE TABLE IF NOT EXISTS public.agent_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    session_id UUID REFERENCES public.chat_sessions(id) ON DELETE SET NULL,

    agent_name TEXT NOT NULL,
    result_type TEXT,

    result_data JSONB,

    confidence_score NUMERIC(5,2),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT agent_confidence_check
        CHECK (
            confidence_score IS NULL
            OR (confidence_score >= 0 AND confidence_score <= 100)
        )
);


-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_user_locations_user_id
    ON public.user_locations(user_id);

CREATE INDEX IF NOT EXISTS idx_ocean_observations_region_id
    ON public.ocean_observations(region_id);

CREATE INDEX IF NOT EXISTS idx_ocean_observations_time
    ON public.ocean_observations(observation_time);

CREATE INDEX IF NOT EXISTS idx_weather_region_id
    ON public.weather_data(region_id);

CREATE INDEX IF NOT EXISTS idx_weather_forecast_time
    ON public.weather_data(forecast_time);

CREATE INDEX IF NOT EXISTS idx_tide_region_id
    ON public.tide_data(region_id);

CREATE INDEX IF NOT EXISTS idx_pfz_region_id
    ON public.pfz_zones(region_id);

CREATE INDEX IF NOT EXISTS idx_alert_region_id
    ON public.marine_alerts(region_id);

CREATE INDEX IF NOT EXISTS idx_alert_expires_at
    ON public.marine_alerts(expires_at);

CREATE INDEX IF NOT EXISTS idx_safety_reports_user_id
    ON public.safety_reports(user_id);

CREATE INDEX IF NOT EXISTS idx_sos_events_user_id
    ON public.sos_events(user_id);

CREATE INDEX IF NOT EXISTS idx_chat_sessions_user_id
    ON public.chat_sessions(user_id);

CREATE INDEX IF NOT EXISTS idx_chat_messages_session_id
    ON public.chat_messages(session_id);

CREATE INDEX IF NOT EXISTS idx_agent_results_session_id
    ON public.agent_results(session_id);


-- =========================================================
-- ROW LEVEL SECURITY
-- =========================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.safety_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sos_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.agent_results ENABLE ROW LEVEL SECURITY;


-- =========================================================
-- PROFILE POLICIES
-- =========================================================

CREATE POLICY "Users can view their own profile"
ON public.profiles
FOR SELECT
TO authenticated
USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
ON public.profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id);


-- =========================================================
-- USER LOCATIONS POLICIES
-- =========================================================

CREATE POLICY "Users can view their own locations"
ON public.user_locations
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own locations"
ON public.user_locations
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);


-- =========================================================
-- SAVED LOCATIONS POLICIES
-- =========================================================

CREATE POLICY "Users can manage their saved locations"
ON public.saved_locations
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);


-- =========================================================
-- SAFETY REPORT POLICIES
-- =========================================================

CREATE POLICY "Users can create safety reports"
ON public.safety_reports
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view safety reports"
ON public.safety_reports
FOR SELECT
TO authenticated
USING (true);


-- =========================================================
-- SOS POLICIES
-- =========================================================

CREATE POLICY "Users can create SOS events"
ON public.sos_events
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their SOS events"
ON public.sos_events
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);


-- =========================================================
-- CHAT SESSION POLICIES
-- =========================================================

CREATE POLICY "Users can manage their chat sessions"
ON public.chat_sessions
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);


-- =========================================================
-- CHAT MESSAGE POLICIES
-- =========================================================

CREATE POLICY "Users can view their chat messages"
ON public.chat_messages
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can create their chat messages"
ON public.chat_messages
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);


-- =========================================================
-- AGENT RESULT POLICIES
-- =========================================================

CREATE POLICY "Users can view their agent results"
ON public.agent_results
FOR SELECT
TO authenticated
USING (
    session_id IN (
        SELECT id
        FROM public.chat_sessions
        WHERE user_id = auth.uid()
    )
);