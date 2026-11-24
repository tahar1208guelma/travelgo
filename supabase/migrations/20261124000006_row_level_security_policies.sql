-- =============================================================================
-- Migration: 20261124000006_row_level_security_policies.sql
-- Description: Comprehensive Row-Level Security (RLS) Verification and Audit View
-- Platform: TravelGo Production Database (PostgreSQL / Supabase)
-- =============================================================================

-- Ensure RLS is active on every TravelGo public table
ALTER TABLE IF EXISTS public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.hotels ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.room_pricing_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.hotel_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.affiliate_clicks ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.financial_ledger ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.platform_commission_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.api_rate_limits ENABLE ROW LEVEL SECURITY;

-- Security Compliance Inspection View (Admin Only)
CREATE OR REPLACE VIEW public.security_rls_compliance_report AS
SELECT 
    c.relname AS table_name,
    c.relrowsecurity AS rls_enabled,
    c.relforcerowsecurity AS rls_forced,
    COUNT(p.polname) AS total_policies
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_policy p ON p.polrelid = c.oid
WHERE n.nspname = 'public' 
  AND c.relkind = 'r'
  AND c.relname IN (
    'profiles',
    'hotels',
    'rooms',
    'room_pricing_rules',
    'hotel_documents',
    'bookings',
    'affiliate_clicks',
    'financial_ledger',
    'platform_commission_config',
    'audit_logs',
    'api_rate_limits'
  )
GROUP BY c.relname, c.relrowsecurity, c.relforcerowsecurity
ORDER BY c.relname;

-- Grant permissions strictly according to zero-trust principles
REVOKE ALL ON public.financial_ledger FROM anon, authenticated;
GRANT SELECT ON public.financial_ledger TO authenticated;

REVOKE ALL ON public.audit_logs FROM anon, authenticated;
REVOKE ALL ON public.api_rate_limits FROM anon, authenticated;

GRANT SELECT ON public.hotels TO anon, authenticated;
GRANT SELECT ON public.rooms TO anon, authenticated;
GRANT SELECT ON public.room_pricing_rules TO anon, authenticated;
GRANT SELECT ON public.platform_commission_config TO anon, authenticated;
GRANT INSERT ON public.affiliate_clicks TO anon, authenticated;

GRANT SELECT, INSERT, UPDATE ON public.profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.bookings TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.hotels TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.rooms TO authenticated;
