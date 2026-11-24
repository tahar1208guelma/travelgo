-- =============================================================================
-- Migration: 20261124000005_create_audit_logs_and_security.sql
-- Description: Audit Logging, Atomic Rate Limiting, and Security Policies
-- Platform: TravelGo Production Database (PostgreSQL / Supabase)
-- =============================================================================

-- 1. Audit Logs Table
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL, -- e.g. 'AUTH_LOGIN', 'BOOKING_CREATE', 'BOOKING_CANCEL', 'HOTEL_APPROVE'
    entity_type TEXT NOT NULL, -- 'booking', 'hotel', 'commission_config', 'profile', 'payment'
    entity_id TEXT,
    ip_address TEXT,
    user_agent TEXT,
    old_values JSONB,
    new_values JSONB,
    status TEXT NOT NULL DEFAULT 'success',
    failure_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes for security compliance & log analysis
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON public.audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON public.audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity ON public.audit_logs(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON public.audit_logs(created_at);

-- 2. API Rate Limiting Table
CREATE TABLE IF NOT EXISTS public.api_rate_limits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rate_key TEXT NOT NULL, -- Client IP or User ID
    endpoint TEXT NOT NULL, -- e.g. '/api/search/flights', '/api/bookings'
    request_count INTEGER NOT NULL DEFAULT 1,
    window_start TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_rate_limits_key_endpoint ON public.api_rate_limits(rate_key, endpoint);
CREATE INDEX IF NOT EXISTS idx_rate_limits_expires_at ON public.api_rate_limits(expires_at);

-- 3. Stored Procedure: Atomic Rate Limiting Check
CREATE OR REPLACE FUNCTION public.check_and_increment_rate_limit(
    p_key TEXT,
    p_endpoint TEXT,
    p_limit INTEGER,
    p_window_seconds INTEGER
)
RETURNS BOOLEAN AS $$
DECLARE
    v_record RECORD;
    v_now TIMESTAMPTZ := now();
BEGIN
    -- Purge expired entries for this key & endpoint
    DELETE FROM public.api_rate_limits
    WHERE rate_key = p_key AND endpoint = p_endpoint AND expires_at < v_now;

    -- Fetch or insert
    SELECT id, request_count INTO v_record
    FROM public.api_rate_limits
    WHERE rate_key = p_key AND endpoint = p_endpoint
    FOR UPDATE;

    IF NOT FOUND THEN
        INSERT INTO public.api_rate_limits (rate_key, endpoint, request_count, window_start, expires_at)
        VALUES (p_key, p_endpoint, 1, v_now, v_now + (p_window_seconds || ' seconds')::interval);
        RETURN TRUE;
    END IF;

    IF v_record.request_count >= p_limit THEN
        RETURN FALSE; -- Rate limit exceeded
    END IF;

    UPDATE public.api_rate_limits
    SET request_count = request_count + 1
    WHERE id = v_record.id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Stored Procedure: Record Audit Log
CREATE OR REPLACE FUNCTION public.log_audit_event(
    p_user_id UUID,
    p_action TEXT,
    p_entity_type TEXT,
    p_entity_id TEXT,
    p_ip_address TEXT,
    p_user_agent TEXT,
    p_old_values JSONB,
    p_new_values JSONB,
    p_status TEXT,
    p_failure_reason TEXT
)
RETURNS UUID AS $$
DECLARE
    v_id UUID;
BEGIN
    INSERT INTO public.audit_logs (
        user_id,
        action,
        entity_type,
        entity_id,
        ip_address,
        user_agent,
        old_values,
        new_values,
        status,
        failure_reason
    ) VALUES (
        p_user_id,
        p_action,
        p_entity_type,
        p_entity_id,
        p_ip_address,
        p_user_agent,
        p_old_values,
        p_new_values,
        p_status,
        p_failure_reason
    ) RETURNING id INTO v_id;

    RETURN v_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Row Level Security Policies

-- Audit Logs RLS
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "audit_logs_select_admin_only" ON public.audit_logs;
CREATE POLICY "audit_logs_select_admin_only" ON public.audit_logs
    FOR SELECT
    USING (
        public.is_admin()
    );

DROP POLICY IF EXISTS "audit_logs_insert_admin_or_definer" ON public.audit_logs;
CREATE POLICY "audit_logs_insert_admin_or_definer" ON public.audit_logs
    FOR INSERT
    WITH CHECK (true);

-- API Rate Limits RLS
ALTER TABLE public.api_rate_limits ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "rate_limits_admin_only" ON public.api_rate_limits;
CREATE POLICY "rate_limits_admin_only" ON public.api_rate_limits
    FOR ALL
    USING (
        public.is_admin()
    );
