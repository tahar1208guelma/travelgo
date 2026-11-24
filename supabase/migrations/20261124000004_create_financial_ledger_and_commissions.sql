-- =============================================================================
-- Migration: 20261124000004_create_financial_ledger_and_commissions.sql
-- Description: Financial Ledger, Platform Commission Config, and Automated Accounting
-- Platform: TravelGo Production Database (PostgreSQL / Supabase)
-- =============================================================================

-- 1. Platform Commission Configuration Table
CREATE TABLE IF NOT EXISTS public.platform_commission_config (
    id TEXT PRIMARY KEY DEFAULT 'global_commission',
    standard_direct_fee_usd NUMERIC(10,2) NOT NULL DEFAULT 1.00,
    standard_affiliate_fee_usd NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    default_percentage_rate NUMERIC(5,4) NOT NULL DEFAULT 0.0075, -- 0.75% default platform commission
    hotel_partner_commission_rate NUMERIC(5,4) NOT NULL DEFAULT 0.1200, -- 12% partner commission
    tax_rate_percentage NUMERIC(5,4) NOT NULL DEFAULT 0.0500, -- 5% standard tax
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_by UUID REFERENCES public.profiles(id)
);

-- Seed initial default configuration
INSERT INTO public.platform_commission_config (
    id,
    standard_direct_fee_usd,
    standard_affiliate_fee_usd,
    default_percentage_rate,
    hotel_partner_commission_rate,
    tax_rate_percentage
) VALUES (
    'global_commission',
    1.00,
    0.00,
    0.0075,
    0.1200,
    0.0500
) ON CONFLICT (id) DO NOTHING;

-- 2. Financial Ledger Table
CREATE TABLE IF NOT EXISTS public.financial_ledger (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_reference TEXT UNIQUE NOT NULL,
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE RESTRICT,
    transaction_type ledger_transaction_type NOT NULL,
    currency VARCHAR(5) NOT NULL DEFAULT 'USD',
    gross_booking_value NUMERIC(10,2) NOT NULL DEFAULT 0.00, -- GBV = Base Price + Taxes
    platform_fee NUMERIC(10,2) NOT NULL DEFAULT 1.00, -- TravelGo platform service fee ($1.00 USD)
    commission_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00, -- Percentage commission (e.g. 0.75% or 12%)
    provider_payout NUMERIC(10,2) NOT NULL DEFAULT 0.00, -- Payout to hotel partner / airline provider
    debit_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    credit_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    status ledger_status NOT NULL DEFAULT 'pending',
    payment_gateway TEXT NOT NULL, -- 'stripe', 'paypal', 'cib', 'wallet', 'bank_transfer'
    payment_gateway_reference TEXT,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes for audit & financial reconciliations
CREATE INDEX IF NOT EXISTS idx_ledger_booking_id ON public.financial_ledger(booking_id);
CREATE INDEX IF NOT EXISTS idx_ledger_type ON public.financial_ledger(transaction_type);
CREATE INDEX IF NOT EXISTS idx_ledger_status ON public.financial_ledger(status);
CREATE INDEX IF NOT EXISTS idx_ledger_created_at ON public.financial_ledger(created_at);
CREATE INDEX IF NOT EXISTS idx_ledger_reference ON public.financial_ledger(transaction_reference);

DROP TRIGGER IF EXISTS set_financial_ledger_updated_at ON public.financial_ledger;
CREATE TRIGGER set_financial_ledger_updated_at
    BEFORE UPDATE ON public.financial_ledger
    FOR EACH ROW EXECUTE FUNCTION public.trigger_set_updated_at();

-- 3. Trigger Function: Process Booking Financials
CREATE OR REPLACE FUNCTION public.process_booking_financial_event()
RETURNS TRIGGER AS $$
DECLARE
    v_ref TEXT;
    v_payout NUMERIC(10,2);
    v_commission NUMERIC(10,2);
BEGIN
    -- Handle Confirmation (Captured Payment)
    IF (NEW.status = 'confirmed' AND (OLD.status IS DISTINCT FROM 'confirmed')) THEN
        v_ref := 'TXN-' || substring(NEW.booking_reference from 1 for 10) || '-' || to_char(now(), 'YYYYMMDDHH24MISS');
        
        -- Compute partner commission and provider payout
        v_commission := ROUND(NEW.base_price_usd * NEW.commission_rate, 2);
        v_payout := (NEW.base_price_usd + NEW.taxes_usd) - v_commission;

        INSERT INTO public.financial_ledger (
            transaction_reference,
            booking_id,
            transaction_type,
            currency,
            gross_booking_value,
            platform_fee,
            commission_amount,
            provider_payout,
            debit_amount,
            credit_amount,
            status,
            payment_gateway,
            payment_gateway_reference,
            metadata
        ) VALUES (
            v_ref,
            NEW.id,
            'direct_booking_charge',
            NEW.currency,
            NEW.total_amount_usd,
            NEW.service_fee_usd, -- $1.00 USD standard fee
            v_commission,
            v_payout,
            0.00,
            NEW.total_amount_usd,
            'cleared',
            'stripe',
            NEW.booking_metadata->>'paymentIntentId',
            jsonb_build_object(
                'bookingReference', NEW.booking_reference,
                'customerUserId', NEW.user_id,
                'basePrice', NEW.base_price_usd,
                'taxes', NEW.taxes_usd,
                'serviceFee', NEW.service_fee_usd
            )
        );
    END IF;

    -- Handle Cancellation / Refund
    IF (NEW.status IN ('cancelled', 'refunded') AND (OLD.status NOT IN ('cancelled', 'refunded'))) THEN
        v_ref := 'REF-' || substring(NEW.booking_reference from 1 for 10) || '-' || to_char(now(), 'YYYYMMDDHH24MISS');

        INSERT INTO public.financial_ledger (
            transaction_reference,
            booking_id,
            transaction_type,
            currency,
            gross_booking_value,
            platform_fee,
            commission_amount,
            provider_payout,
            debit_amount,
            credit_amount,
            status,
            payment_gateway,
            payment_gateway_reference,
            metadata
        ) VALUES (
            v_ref,
            NEW.id,
            'cancellation_refund',
            NEW.currency,
            NEW.total_amount_usd,
            0.00,
            0.00,
            0.00,
            NEW.base_price_usd + NEW.taxes_usd, -- refund base fare + taxes (policy preserves platform service fee)
            0.00,
            'cleared',
            'stripe',
            NEW.booking_metadata->>'refundId',
            jsonb_build_object(
                'cancellationReason', NEW.booking_metadata->>'cancellationReason',
                'originalBookingReference', NEW.booking_reference
            )
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_booking_status_financials ON public.bookings;
CREATE TRIGGER on_booking_status_financials
    AFTER UPDATE OF status ON public.bookings
    FOR EACH ROW EXECUTE FUNCTION public.process_booking_financial_event();

-- 4. Row Level Security Policies

-- Financial Ledger RLS
ALTER TABLE public.financial_ledger ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "ledger_select_partner_or_admin" ON public.financial_ledger;
CREATE POLICY "ledger_select_partner_or_admin" ON public.financial_ledger
    FOR SELECT
    USING (
        public.is_admin() OR
        EXISTS (
            SELECT 1 FROM public.bookings b
            JOIN public.hotels h ON h.id = b.hotel_id
            WHERE b.id = financial_ledger.booking_id AND h.owner_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "ledger_write_admin_only" ON public.financial_ledger;
CREATE POLICY "ledger_write_admin_only" ON public.financial_ledger
    FOR ALL
    USING (
        public.is_admin()
    )
    WITH CHECK (
        public.is_admin()
    );

-- Platform Commission Config RLS
ALTER TABLE public.platform_commission_config ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "commission_config_select_all" ON public.platform_commission_config;
CREATE POLICY "commission_config_select_all" ON public.platform_commission_config
    FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "commission_config_update_admin_only" ON public.platform_commission_config;
CREATE POLICY "commission_config_update_admin_only" ON public.platform_commission_config
    FOR ALL
    USING (
        public.is_admin()
    )
    WITH CHECK (
        public.is_admin()
    );
