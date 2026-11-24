-- =============================================================================
-- Migration: 20261124000002_create_hotels_rooms_and_partner_portal.sql
-- Description: Idempotent schema for Hotels, Rooms, Seasonal Pricing, & Documents
-- Platform: TravelGo Production Database (PostgreSQL / Supabase)
-- =============================================================================

-- 1. Hotels Table
CREATE TABLE IF NOT EXISTS public.hotels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    name TEXT NOT NULL,
    description TEXT,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    country TEXT NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    star_rating NUMERIC(2,1) DEFAULT 0.0 CHECK (star_rating >= 0 AND star_rating <= 5),
    status hotel_status NOT NULL DEFAULT 'pending_approval',
    commission_rate NUMERIC(5,4) NOT NULL DEFAULT 0.1200, -- 12% standard direct partner rate
    amenities JSONB NOT NULL DEFAULT '[]'::jsonb,
    image_urls JSONB NOT NULL DEFAULT '[]'::jsonb,
    contact_email TEXT,
    contact_phone TEXT,
    verification_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes for search & filtering
CREATE INDEX IF NOT EXISTS idx_hotels_city_country ON public.hotels(city, country);
CREATE INDEX IF NOT EXISTS idx_hotels_status ON public.hotels(status);
CREATE INDEX IF NOT EXISTS idx_hotels_owner_id ON public.hotels(owner_id);
CREATE INDEX IF NOT EXISTS idx_hotels_star_rating ON public.hotels(star_rating);

-- Updated_at trigger
DROP TRIGGER IF EXISTS set_hotels_updated_at ON public.hotels;
CREATE TRIGGER set_hotels_updated_at
    BEFORE UPDATE ON public.hotels
    FOR EACH ROW EXECUTE FUNCTION public.trigger_set_updated_at();

-- 2. Rooms Table
CREATE TABLE IF NOT EXISTS public.rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hotel_id UUID NOT NULL REFERENCES public.hotels(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    room_type TEXT NOT NULL,
    base_price_per_night NUMERIC(10,2) NOT NULL CHECK (base_price_per_night >= 0),
    currency VARCHAR(5) NOT NULL DEFAULT 'USD',
    max_occupancy INTEGER NOT NULL DEFAULT 2 CHECK (max_occupancy > 0),
    bed_type TEXT NOT NULL DEFAULT 'Queen',
    amenities JSONB NOT NULL DEFAULT '[]'::jsonb,
    image_urls JSONB NOT NULL DEFAULT '[]'::jsonb,
    total_inventory INTEGER NOT NULL DEFAULT 1 CHECK (total_inventory >= 0),
    available_inventory INTEGER NOT NULL DEFAULT 1 CHECK (available_inventory >= 0),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_rooms_hotel_id ON public.rooms(hotel_id);
CREATE INDEX IF NOT EXISTS idx_rooms_is_active ON public.rooms(is_active);

DROP TRIGGER IF EXISTS set_rooms_updated_at ON public.rooms;
CREATE TRIGGER set_rooms_updated_at
    BEFORE UPDATE ON public.rooms
    FOR EACH ROW EXECUTE FUNCTION public.trigger_set_updated_at();

-- 3. Room Seasonal Pricing Overrides
CREATE TABLE IF NOT EXISTS public.room_pricing_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    nightly_price NUMERIC(10,2) NOT NULL CHECK (nightly_price >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_pricing_date_range CHECK (end_date >= start_date)
);

CREATE INDEX IF NOT EXISTS idx_pricing_rules_room_date ON public.room_pricing_rules(room_id, start_date, end_date);

-- 4. Hotel Verification Documents
CREATE TABLE IF NOT EXISTS public.hotel_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hotel_id UUID NOT NULL REFERENCES public.hotels(id) ON DELETE CASCADE,
    document_type TEXT NOT NULL, -- 'commercial_register', 'tax_certificate', 'id_proof', 'ownership_deed'
    document_url TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'verified', 'rejected'
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    verified_at TIMESTAMPTZ,
    verified_by UUID REFERENCES public.profiles(id)
);

CREATE INDEX IF NOT EXISTS idx_hotel_documents_hotel_id ON public.hotel_documents(hotel_id);

-- 5. Row Level Security Policies

-- Hotels RLS
ALTER TABLE public.hotels ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "hotels_select_public_approved" ON public.hotels;
CREATE POLICY "hotels_select_public_approved" ON public.hotels
    FOR SELECT
    USING (
        status = 'approved' OR
        owner_id = auth.uid() OR
        public.is_admin()
    );

DROP POLICY IF EXISTS "hotels_insert_partner_or_admin" ON public.hotels;
CREATE POLICY "hotels_insert_partner_or_admin" ON public.hotels
    FOR INSERT
    WITH CHECK (
        (owner_id = auth.uid() AND (public.is_partner() OR public.is_admin())) OR
        public.is_admin()
    );

DROP POLICY IF EXISTS "hotels_update_owner_or_admin" ON public.hotels;
CREATE POLICY "hotels_update_owner_or_admin" ON public.hotels
    FOR UPDATE
    USING (
        owner_id = auth.uid() OR public.is_admin()
    )
    WITH CHECK (
        -- Owners cannot self-approve their hotel (only admin can set status = 'approved')
        (owner_id = auth.uid() AND status IN ('draft', 'pending_approval')) OR
        public.is_admin()
    );

DROP POLICY IF EXISTS "hotels_delete_admin_only" ON public.hotels;
CREATE POLICY "hotels_delete_admin_only" ON public.hotels
    FOR DELETE
    USING (
        public.is_admin()
    );

-- Rooms RLS
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "rooms_select_active_or_owner" ON public.rooms;
CREATE POLICY "rooms_select_active_or_owner" ON public.rooms
    FOR SELECT
    USING (
        (is_active = true AND EXISTS (
            SELECT 1 FROM public.hotels
            WHERE hotels.id = rooms.hotel_id AND hotels.status = 'approved'
        )) OR
        EXISTS (
            SELECT 1 FROM public.hotels
            WHERE hotels.id = rooms.hotel_id AND (hotels.owner_id = auth.uid() OR public.is_admin())
        )
    );

DROP POLICY IF EXISTS "rooms_insert_owner_or_admin" ON public.rooms;
CREATE POLICY "rooms_insert_owner_or_admin" ON public.rooms
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.hotels
            WHERE hotels.id = hotel_id AND (hotels.owner_id = auth.uid() OR public.is_admin())
        )
    );

DROP POLICY IF EXISTS "rooms_update_owner_or_admin" ON public.rooms;
CREATE POLICY "rooms_update_owner_or_admin" ON public.rooms
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.hotels
            WHERE hotels.id = rooms.hotel_id AND (hotels.owner_id = auth.uid() OR public.is_admin())
        )
    );

DROP POLICY IF EXISTS "rooms_delete_owner_or_admin" ON public.rooms;
CREATE POLICY "rooms_delete_owner_or_admin" ON public.rooms
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.hotels
            WHERE hotels.id = rooms.hotel_id AND (hotels.owner_id = auth.uid() OR public.is_admin())
        )
    );

-- Room Pricing Rules RLS
ALTER TABLE public.room_pricing_rules ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "pricing_rules_select_all" ON public.room_pricing_rules;
CREATE POLICY "pricing_rules_select_all" ON public.room_pricing_rules
    FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "pricing_rules_modify_owner_or_admin" ON public.room_pricing_rules;
CREATE POLICY "pricing_rules_modify_owner_or_admin" ON public.room_pricing_rules
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.rooms r
            JOIN public.hotels h ON h.id = r.hotel_id
            WHERE r.id = room_pricing_rules.room_id AND (h.owner_id = auth.uid() OR public.is_admin())
        )
    );

-- Hotel Documents RLS
ALTER TABLE public.hotel_documents ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "documents_owner_or_admin" ON public.hotel_documents
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.hotels h
            WHERE h.id = hotel_documents.hotel_id AND (h.owner_id = auth.uid() OR public.is_admin())
        )
    );
