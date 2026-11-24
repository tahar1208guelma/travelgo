-- =============================================================================
-- Migration: 20261124000003_create_bookings_and_affiliate_clicks.sql
-- Description: Idempotent schema for Bookings, Affiliate Tracking, and RLS
-- Platform: TravelGo Production Database (PostgreSQL / Supabase)
-- =============================================================================

-- 1. Bookings Table
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_reference TEXT UNIQUE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    hotel_id UUID REFERENCES public.hotels(id) ON DELETE SET NULL,
    booking_type booking_type NOT NULL,
    provider TEXT NOT NULL,
    item_id TEXT NOT NULL,
    item_name TEXT NOT NULL,
    status booking_status NOT NULL DEFAULT 'pending',
    payment_status payment_status NOT NULL DEFAULT 'pending',
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ,
    guest_count INTEGER NOT NULL DEFAULT 1 CHECK (guest_count > 0),
    contact_details JSONB NOT NULL,
    passengers JSONB NOT NULL DEFAULT '[]'::jsonb,
    booking_metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- Financial Details
    base_price_usd NUMERIC(10,2) NOT NULL CHECK (base_price_usd >= 0),
    taxes_usd NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (taxes_usd >= 0),
    service_fee_usd NUMERIC(10,2) NOT NULL DEFAULT 1.00 CHECK (service_fee_usd >= 0), -- $1.00 platform fee
    total_amount_usd NUMERIC(10,2) NOT NULL CHECK (total_amount_usd >= 0),
    commission_rate NUMERIC(5,4) NOT NULL DEFAULT 0.0075, -- 0.75% default setting
    commission_amount_usd NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (commission_amount_usd >= 0),
    currency VARCHAR(5) NOT NULL DEFAULT 'USD',
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    
    CONSTRAINT chk_total_amount_math CHECK (
        total_amount_usd = (base_price_usd + taxes_usd + service_fee_usd)
    )
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_bookings_reference ON public.bookings(booking_reference);
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON public.bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_hotel_id ON public.bookings(hotel_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_payment_status ON public.bookings(payment_status);
CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON public.bookings(created_at);

DROP TRIGGER IF EXISTS set_bookings_updated_at ON public.bookings;
CREATE TRIGGER set_bookings_updated_at
    BEFORE UPDATE ON public.bookings
    FOR EACH ROW EXECUTE FUNCTION public.trigger_set_updated_at();

-- 2. Affiliate Clicks Tracking Table
CREATE TABLE IF NOT EXISTS public.affiliate_clicks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    provider TEXT NOT NULL,
    product_type TEXT NOT NULL, -- 'hotel' | 'flight'
    product_id TEXT NOT NULL,
    tracking_id TEXT NOT NULL,
    target_url TEXT NOT NULL,
    service_fee_usd NUMERIC(10,2) NOT NULL DEFAULT 0.00, -- $0.00 transparent platform markup
    ip_hash TEXT,
    user_agent TEXT,
    clicked_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_affiliate_clicks_user ON public.affiliate_clicks(user_id);
CREATE INDEX IF NOT EXISTS idx_affiliate_clicks_tracking ON public.affiliate_clicks(tracking_id);
CREATE INDEX IF NOT EXISTS idx_affiliate_clicks_provider ON public.affiliate_clicks(provider);
CREATE INDEX IF NOT EXISTS idx_affiliate_clicks_clicked_at ON public.affiliate_clicks(clicked_at);

-- 3. Row Level Security Policies

-- Bookings RLS
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "bookings_select_own_or_partner_or_admin" ON public.bookings;
CREATE POLICY "bookings_select_own_or_partner_or_admin" ON public.bookings
    FOR SELECT
    USING (
        auth.uid() = user_id OR
        (hotel_id IS NOT NULL AND EXISTS (
            SELECT 1 FROM public.hotels
            WHERE hotels.id = bookings.hotel_id AND hotels.owner_id = auth.uid()
        )) OR
        public.is_admin()
    );

DROP POLICY IF EXISTS "bookings_insert_own_or_admin" ON public.bookings;
CREATE POLICY "bookings_insert_own_or_admin" ON public.bookings
    FOR INSERT
    WITH CHECK (
        (auth.uid() = user_id AND service_fee_usd = 1.00) OR
        public.is_admin()
    );

DROP POLICY IF EXISTS "bookings_update_own_cancel_or_admin" ON public.bookings;
CREATE POLICY "bookings_update_own_cancel_or_admin" ON public.bookings
    FOR UPDATE
    USING (
        auth.uid() = user_id OR
        public.is_admin() OR
        (hotel_id IS NOT NULL AND EXISTS (
            SELECT 1 FROM public.hotels
            WHERE hotels.id = bookings.hotel_id AND hotels.owner_id = auth.uid()
        ))
    )
    WITH CHECK (
        -- Regular user can only request cancellation, not change price or set confirmed
        (auth.uid() = user_id AND status = 'cancelled') OR
        public.is_admin() OR
        (hotel_id IS NOT NULL AND EXISTS (
            SELECT 1 FROM public.hotels
            WHERE hotels.id = bookings.hotel_id AND hotels.owner_id = auth.uid()
        ))
    );

DROP POLICY IF EXISTS "bookings_delete_admin_only" ON public.bookings;
CREATE POLICY "bookings_delete_admin_only" ON public.bookings
    FOR DELETE
    USING (
        public.is_admin()
    );

-- Affiliate Clicks RLS
ALTER TABLE public.affiliate_clicks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "affiliate_clicks_insert_any" ON public.affiliate_clicks;
CREATE POLICY "affiliate_clicks_insert_any" ON public.affiliate_clicks
    FOR INSERT
    WITH CHECK (true);

DROP POLICY IF EXISTS "affiliate_clicks_select_admin_only" ON public.affiliate_clicks;
CREATE POLICY "affiliate_clicks_select_admin_only" ON public.affiliate_clicks
    FOR SELECT
    USING (
        public.is_admin()
    );
