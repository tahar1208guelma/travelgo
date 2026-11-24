-- =============================================================================
-- Migration: 20261124000001_create_user_roles_and_profiles.sql
-- Description: Idempotent migration for user roles, profiles, and auth triggers
-- Platform: TravelGo Production Database (PostgreSQL / Supabase)
-- =============================================================================

-- Ensure auth schema and mock users table exist for standalone local environments
CREATE SCHEMA IF NOT EXISTS auth;
CREATE TABLE IF NOT EXISTS auth.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE,
    raw_user_meta_data JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 1. Idempotent Custom Types & Enums
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE user_role AS ENUM ('user', 'partner', 'admin');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'booking_status') THEN
        CREATE TYPE booking_status AS ENUM ('initiated', 'pending', 'confirmed', 'cancelled', 'failed', 'refunded');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_status') THEN
        CREATE TYPE payment_status AS ENUM ('unpaid', 'pending', 'paid', 'refunded', 'partially_refunded', 'failed');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'booking_type') THEN
        CREATE TYPE booking_type AS ENUM ('flight', 'hotel');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'hotel_status') THEN
        CREATE TYPE hotel_status AS ENUM ('draft', 'pending_approval', 'approved', 'rejected', 'suspended');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ledger_transaction_type') THEN
        CREATE TYPE ledger_transaction_type AS ENUM (
            'direct_booking_charge',
            'platform_service_fee',
            'partner_commission',
            'provider_payout',
            'cancellation_refund',
            'partial_refund',
            'chargeback',
            'affiliate_referral'
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ledger_status') THEN
        CREATE TYPE ledger_status AS ENUM ('pending', 'cleared', 'reversed', 'failed');
    END IF;
END $$;

-- 2. User Profiles Table
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    role user_role NOT NULL DEFAULT 'user',
    is_guest BOOLEAN NOT NULL DEFAULT false,
    preferred_language VARCHAR(5) NOT NULL DEFAULT 'en',
    preferred_currency VARCHAR(5) NOT NULL DEFAULT 'USD',
    phone_number TEXT,
    avatar_url TEXT,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);

-- 3. Security Helper Functions
CREATE OR REPLACE FUNCTION public.get_auth_role()
RETURNS user_role AS $$
    SELECT COALESCE(
        (SELECT role FROM public.profiles WHERE id = auth.uid()),
        'user'::user_role
    );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'admin'::user_role
    );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_partner()
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND (role = 'partner'::user_role OR role = 'admin'::user_role)
    );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- 4. Automatic Profile Creation Trigger on Auth Signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    assigned_role user_role := 'user'::user_role;
BEGIN
    -- Strict Security Rule: Public registration can NEVER self-grant 'admin'
    -- Partners can register if marked in meta_data, but admin requires existing admin elevation
    IF (NEW.raw_user_meta_data->>'role') = 'partner' THEN
        assigned_role := 'partner'::user_role;
    END IF;

    INSERT INTO public.profiles (
        id,
        name,
        email,
        role,
        is_guest,
        preferred_language,
        preferred_currency,
        phone_number
    ) VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.email, ''),
        assigned_role,
        COALESCE((NEW.raw_user_meta_data->>'is_guest')::boolean, false),
        COALESCE(NEW.raw_user_meta_data->>'preferred_language', 'en'),
        COALESCE(NEW.raw_user_meta_data->>'preferred_currency', 'USD'),
        NEW.raw_user_meta_data->>'phone_number'
    )
    ON CONFLICT (id) DO UPDATE SET
        name = EXCLUDED.name,
        email = EXCLUDED.email,
        updated_at = now();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 5. Updated_at Auto-refresh Trigger
CREATE OR REPLACE FUNCTION public.trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_profiles_updated_at ON public.profiles;
CREATE TRIGGER set_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.trigger_set_updated_at();

-- 6. Row Level Security (RLS) on Profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "profiles_select_own_or_admin" ON public.profiles;
CREATE POLICY "profiles_select_own_or_admin" ON public.profiles
    FOR SELECT
    USING (
        auth.uid() = id OR public.is_admin()
    );

DROP POLICY IF EXISTS "profiles_insert_own_or_admin" ON public.profiles;
CREATE POLICY "profiles_insert_own_or_admin" ON public.profiles
    FOR INSERT
    WITH CHECK (
        auth.uid() = id OR public.is_admin()
    );

DROP POLICY IF EXISTS "profiles_update_own_or_admin" ON public.profiles;
CREATE POLICY "profiles_update_own_or_admin" ON public.profiles
    FOR UPDATE
    USING (
        auth.uid() = id OR public.is_admin()
    )
    WITH CHECK (
        -- Regular users cannot promote themselves to 'admin'
        (role = (SELECT role FROM public.profiles WHERE id = auth.uid()) OR public.is_admin())
    );

DROP POLICY IF EXISTS "profiles_delete_admin_only" ON public.profiles;
CREATE POLICY "profiles_delete_admin_only" ON public.profiles
    FOR DELETE
    USING (
        public.is_admin()
    );
