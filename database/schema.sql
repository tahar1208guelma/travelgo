-- TravelGo PostgreSQL Migration 001: Initial Schema
-- Production Relational Schema for Multiplatform Travel Platform

-- 1. Roles & Users
CREATE TABLE IF NOT EXISTS roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(50),
    country VARCHAR(100) DEFAULT 'Algeria',
    date_of_birth DATE,
    is_email_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    preferred_currency VARCHAR(3) DEFAULT 'USD',
    preferred_language VARCHAR(5) DEFAULT 'ar',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_roles (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role_id INT REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

-- 2. Secure Passenger Profiles
CREATE TABLE IF NOT EXISTS passengers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    passport_number VARCHAR(100),
    nationality VARCHAR(100),
    passport_expiry DATE,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10),
    frequent_flyer_number VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Providers Registry
CREATE TABLE IF NOT EXISTS providers (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL, -- 'flight', 'hotel', 'payment'
    is_active BOOLEAN DEFAULT TRUE,
    is_demo BOOLEAN DEFAULT FALSE,
    credentials_ref VARCHAR(100), -- reference to env key, never store raw secrets
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Currencies & Dynamic Exchange Rates
CREATE TABLE IF NOT EXISTS currencies (
    code VARCHAR(3) PRIMARY KEY, -- DZD, EUR, USD, GBP
    name VARCHAR(50) NOT NULL,
    symbol VARCHAR(10) NOT NULL,
    exchange_rate_to_usd NUMERIC(14, 6) NOT NULL DEFAULT 1.0,
    is_active BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Admin Settings & System Configuration
CREATE TABLE IF NOT EXISTS settings (
    key VARCHAR(100) PRIMARY KEY,
    value TEXT NOT NULL,
    description TEXT,
    updated_by UUID REFERENCES users(id) ON DELETE SET NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Flight Searches & Cached Offers
CREATE TABLE IF NOT EXISTS flight_searches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    origin_code VARCHAR(10) NOT NULL,
    destination_code VARCHAR(10) NOT NULL,
    departure_date DATE NOT NULL,
    return_date DATE,
    adults INT DEFAULT 1,
    children INT DEFAULT 0,
    infants INT DEFAULT 0,
    cabin_class VARCHAR(30) DEFAULT 'Economy',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS flight_offers (
    id VARCHAR(100) PRIMARY KEY,
    search_id UUID REFERENCES flight_searches(id) ON DELETE CASCADE,
    provider_id VARCHAR(50) REFERENCES providers(id),
    validating_airline VARCHAR(100) NOT NULL,
    validating_airline_code VARCHAR(10) NOT NULL,
    base_price NUMERIC(12, 2) NOT NULL,
    taxes NUMERIC(12, 2) NOT NULL,
    commission_rate NUMERIC(6, 4) NOT NULL,
    commission_amount NUMERIC(12, 2) NOT NULL,
    total_price NUMERIC(12, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    stops_count INT DEFAULT 0,
    is_refundable BOOLEAN DEFAULT FALSE,
    baggage_summary TEXT,
    outbound_itinerary_json JSONB NOT NULL,
    return_itinerary_json JSONB,
    price_lock_expiry TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. Hotels, Searches & Rooms
CREATE TABLE IF NOT EXISTS hotel_searches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    destination VARCHAR(150) NOT NULL,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    adults INT DEFAULT 1,
    children INT DEFAULT 0,
    rooms_count INT DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS hotels (
    id VARCHAR(100) PRIMARY KEY,
    provider_id VARCHAR(50) REFERENCES providers(id),
    name VARCHAR(200) NOT NULL,
    destination VARCHAR(150) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    star_rating NUMERIC(2, 1) DEFAULT 4.0,
    guest_rating NUMERIC(3, 1) DEFAULT 8.5,
    images JSONB,
    amenities JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS rooms (
    id VARCHAR(100) PRIMARY KEY,
    hotel_id VARCHAR(100) REFERENCES hotels(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    room_type VARCHAR(100) NOT NULL,
    capacity INT DEFAULT 2,
    base_price_per_night NUMERIC(12, 2) NOT NULL,
    taxes_per_night NUMERIC(12, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    breakfast_included BOOLEAN DEFAULT FALSE,
    cancellation_policy TEXT,
    available_units INT DEFAULT 5,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. Core Booking Engine
CREATE TABLE IF NOT EXISTS bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_reference VARCHAR(50) UNIQUE NOT NULL, -- TRV-2026-XXXXXX
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    booking_type VARCHAR(30) NOT NULL, -- 'flight', 'hotel', 'combined'
    provider_id VARCHAR(50) REFERENCES providers(id),
    provider_reference VARCHAR(100), -- External PNR or Hotel confirmation ref
    status VARCHAR(30) NOT NULL DEFAULT 'pending', 
    -- 'pending', 'payment_pending', 'paid', 'confirmed', 'cancelled', 'failed', 'refunded'
    base_price NUMERIC(12, 2) NOT NULL,
    taxes NUMERIC(12, 2) NOT NULL,
    commission_rate NUMERIC(6, 4) NOT NULL,
    commission_amount NUMERIC(12, 2) NOT NULL,
    total_price NUMERIC(12, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    cancellation_policy TEXT,
    is_refundable BOOLEAN DEFAULT FALSE,
    cancellation_fee NUMERIC(12, 2) DEFAULT 0.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS flight_bookings (
    booking_id UUID PRIMARY KEY REFERENCES bookings(id) ON DELETE CASCADE,
    airline_pnr VARCHAR(50),
    validating_airline VARCHAR(100) NOT NULL,
    ticket_numbers JSONB, -- passenger_id -> e-ticket number
    is_ticket_issued BOOLEAN DEFAULT FALSE,
    segments JSONB NOT NULL,
    passengers JSONB NOT NULL
);

CREATE TABLE IF NOT EXISTS hotel_bookings (
    booking_id UUID PRIMARY KEY REFERENCES bookings(id) ON DELETE CASCADE,
    hotel_id VARCHAR(100) REFERENCES hotels(id),
    room_id VARCHAR(100) REFERENCES rooms(id),
    hotel_name VARCHAR(200) NOT NULL,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    nights INT NOT NULL,
    rooms_count INT NOT NULL,
    guests JSONB NOT NULL
);

-- 9. Payments & Server-Side Verification
CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
    provider_id VARCHAR(50) REFERENCES providers(id), -- 'stripe', 'cib_algeria'
    payment_intent_id VARCHAR(150) UNIQUE NOT NULL,
    idempotency_key VARCHAR(150) UNIQUE NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'initiated',
    -- 'initiated', 'requires_action_3ds', 'succeeded', 'failed', 'refunded'
    payment_method_type VARCHAR(50) DEFAULT 'card', -- 'card', 'edahabia', 'cib'
    payment_method_last4 VARCHAR(4),
    payment_method_brand VARCHAR(50),
    server_verified_at TIMESTAMP WITH TIME ZONE,
    raw_webhook_event JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS refunds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
    payment_id UUID REFERENCES payments(id) ON DELETE SET NULL,
    amount NUMERIC(12, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    reason TEXT,
    status VARCHAR(30) NOT NULL DEFAULT 'completed',
    processed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS commissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
    base_price NUMERIC(12, 2) NOT NULL,
    commission_rate NUMERIC(6, 4) NOT NULL,
    commission_amount NUMERIC(12, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 10. Official Invoices & Vouchers
CREATE TABLE IF NOT EXISTS invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_number VARCHAR(50) UNIQUE NOT NULL, -- INV-2026-XXXXX
    booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
    total_amount NUMERIC(12, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    pdf_url TEXT,
    qr_code_payload TEXT,
    issued_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS vouchers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    voucher_number VARCHAR(50) UNIQUE NOT NULL, -- VCH-2026-XXXXX
    booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
    voucher_type VARCHAR(30) NOT NULL, -- 'flight_eticket', 'flight_itinerary', 'hotel_voucher'
    pdf_url TEXT,
    issued_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 11. Notifications
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL, -- 'booking_confirmed', 'payment_success', 'cancellation', 'refund'
    is_read BOOLEAN DEFAULT FALSE,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 12. Security Audit Logs
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id VARCHAR(100),
    ip_address VARCHAR(45),
    user_agent TEXT,
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
-- TravelGo PostgreSQL Migration 002: Indexes and Constraints

-- Users & Auth
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active);

-- Passengers
CREATE INDEX IF NOT EXISTS idx_passengers_user_id ON passengers(user_id);
CREATE INDEX IF NOT EXISTS idx_passengers_passport ON passengers(passport_number);

-- Flight Searches & Offers
CREATE INDEX IF NOT EXISTS idx_flight_searches_route ON flight_searches(origin_code, destination_code, departure_date);
CREATE INDEX IF NOT EXISTS idx_flight_offers_search_id ON flight_offers(search_id);
CREATE INDEX IF NOT EXISTS idx_flight_offers_airline ON flight_offers(validating_airline_code);
CREATE INDEX IF NOT EXISTS idx_flight_offers_price ON flight_offers(total_price);

-- Hotel Searches & Properties
CREATE INDEX IF NOT EXISTS idx_hotel_searches_dest ON hotel_searches(destination, check_in, check_out);
CREATE INDEX IF NOT EXISTS idx_hotels_dest ON hotels(destination);
CREATE INDEX IF NOT EXISTS idx_hotels_city ON hotels(city);
CREATE INDEX IF NOT EXISTS idx_rooms_hotel_id ON rooms(hotel_id);

-- Bookings Engine
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_ref ON bookings(booking_reference);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON bookings(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_flight_bookings_pnr ON flight_bookings(airline_pnr);

-- Payments & Auditing
CREATE INDEX IF NOT EXISTS idx_payments_booking_id ON payments(booking_id);
CREATE INDEX IF NOT EXISTS idx_payments_intent ON payments(payment_intent_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON notifications(user_id, is_read);
-- TravelGo PostgreSQL Migration 003: Seed Data

-- 1. Insert System Roles
INSERT INTO roles (name, description) VALUES
('admin', 'Full access to admin dashboard, financial settings, and provider management'),
('agent', 'Customer support and agency booking management'),
('customer', 'End-user traveler booking flights and hotels')
ON CONFLICT (name) DO NOTHING;

-- 2. Insert Default Currencies
INSERT INTO currencies (code, name, symbol, exchange_rate_to_usd, is_active) VALUES
('USD', 'US Dollar', '$', 1.000000, TRUE),
('EUR', 'Euro', '€', 0.920000, TRUE),
('DZD', 'Algerian Dinar', 'DA', 134.500000, TRUE),
('GBP', 'British Pound', '£', 0.790000, TRUE)
ON CONFLICT (code) DO UPDATE SET
exchange_rate_to_usd = EXCLUDED.exchange_rate_to_usd,
is_active = EXCLUDED.is_active;

-- 3. Insert Travel Providers
INSERT INTO providers (id, name, type, is_active, is_demo, credentials_ref) VALUES
('amadeus', 'Amadeus Global Travel Network', 'flight', FALSE, FALSE, 'AMADEUS_CLIENT_ID'),
('duffel', 'Duffel Flights API', 'flight', FALSE, FALSE, 'DUFFEL_ACCESS_TOKEN'),
('mock_flight', 'TravelGo Mock Flight Engine (DEMO ONLY)', 'flight', TRUE, TRUE, NULL),
('booking_com', 'Booking.com Affiliate API', 'hotel', FALSE, FALSE, 'BOOKING_COM_API_KEY'),
('mock_hotel', 'TravelGo Mock Hotel Engine (DEMO ONLY)', 'hotel', TRUE, TRUE, NULL),
('stripe', 'Stripe Global Payment Gateway', 'payment', TRUE, FALSE, 'STRIPE_SECRET_KEY'),
('cib_edahabia', 'Algeria SATIM / CIB & Edahabia Gateway', 'payment', TRUE, FALSE, 'CIB_MERCHANT_KEY')
ON CONFLICT (id) DO NOTHING;

-- 4. Insert Admin Configuration Settings
-- Default commission is 0.75% (0.0075) as required, fully dynamic in DB
INSERT INTO settings (key, value, description) VALUES
('commission_rate', '0.0075', 'TravelGo platform service fee percentage (e.g. 0.0075 = 0.75%)'),
('platform_name', 'TravelGo', 'Official public branding name'),
('support_email', 'support@travelgo.com', 'Platform operational customer support email'),
('currency_primary', 'USD', 'Base currency for global settlements'),
('allow_unverified_bookings', 'false', 'Require email verification before completing order'),
('flight_price_tolerance_usd', '5.0', 'Maximum price difference before asking user re-approval')
ON CONFLICT (key) DO NOTHING;

-- 5. Insert Default Administrator User (Password: Admin@TravelGo2026! hashed with bcrypt)
INSERT INTO users (id, email, password_hash, first_name, last_name, phone, country, is_email_verified, is_active) VALUES
('00000000-0000-0000-0000-000000000001', 'admin@travelgo.com', '$2b$12$K1r6fQ/T7p74XhW3Ue12wuef8aQZ3zK2e5T/zK3qV6U4pQ9yM1uCe', 'Admin', 'TravelGo', '+213555000111', 'Algeria', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- Assign Admin Role
INSERT INTO user_roles (user_id, role_id)
SELECT '00000000-0000-0000-0000-000000000001', id FROM roles WHERE name = 'admin'
ON CONFLICT DO NOTHING;
-- TravelGo PostgreSQL Migration 004: Merchant Financial System & Wallet Architecture
-- Platform Owner Multi-Currency Wallets, Immutable Ledger, Lifecycle Commissions & Bank Payouts

-- 1. Merchant Multi-Currency Wallets
CREATE TABLE IF NOT EXISTS wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    currency VARCHAR(3) NOT NULL, -- EUR, USD, DZD, GBP
    available_balance NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    pending_balance NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    total_earned NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    total_withdrawn NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    total_refunded NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_wallet_owner_currency UNIQUE (owner_id, currency)
);

-- 2. Bank Accounts Storage
CREATE TABLE IF NOT EXISTS bank_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    account_holder_name VARCHAR(150) NOT NULL,
    bank_name VARCHAR(150) NOT NULL,
    iban VARCHAR(100) NOT NULL,
    swift_bic VARCHAR(50) NOT NULL,
    country VARCHAR(100) NOT NULL,
    is_primary BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Withdrawals Registry
CREATE TABLE IF NOT EXISTS withdrawals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE RESTRICT,
    bank_account_id UUID REFERENCES bank_accounts(id) ON DELETE SET NULL,
    amount NUMERIC(14, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    -- 'pending', 'approved', 'processing', 'completed', 'rejected', 'failed'
    rejection_reason TEXT,
    bank_transfer_reference VARCHAR(150),
    requested_by UUID REFERENCES users(id),
    reviewed_by UUID REFERENCES users(id),
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP WITH TIME ZONE
);

-- 4. Immutable Financial Ledger (Append-Only)
-- Never edit old records. Corrections must be new 'adjustment' transactions.
CREATE TABLE IF NOT EXISTS wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE RESTRICT,
    type VARCHAR(30) NOT NULL,
    -- 'commission', 'refund', 'withdrawal', 'adjustment'
    reference_id VARCHAR(100) NOT NULL, -- booking_id or withdrawal_id
    amount NUMERIC(14, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    balance_before NUMERIC(14, 2) NOT NULL,
    balance_after NUMERIC(14, 2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'completed',
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Drop & Recreate Commissions Table to support strict 9-step lifecycle
DROP TABLE IF EXISTS commissions CASCADE;
CREATE TABLE commissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    base_amount NUMERIC(14, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    commission_rate NUMERIC(6, 4) NOT NULL DEFAULT 0.0075,
    commission_amount NUMERIC(14, 2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    -- 'pending', 'available', 'cancelled', 'refunded', 'withdrawn'
    available_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Financial Reconciliation Table
CREATE TABLE IF NOT EXISTS financial_reconciliation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    currency VARCHAR(3) NOT NULL,
    provider_payments_total NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    platform_bookings_total NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    gateway_captured_total NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    commissions_total NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    refunds_total NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    withdrawals_total NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    expected_net NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    actual_net NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    difference NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(30) NOT NULL DEFAULT 'balanced', -- 'balanced', 'discrepancy'
    reconciled_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for lightning queries
CREATE INDEX IF NOT EXISTS idx_wallets_owner ON wallets(owner_id);
CREATE INDEX IF NOT EXISTS idx_wallet_tx_wallet ON wallet_transactions(wallet_id);
CREATE INDEX IF NOT EXISTS idx_wallet_tx_ref ON wallet_transactions(reference_id);
CREATE INDEX IF NOT EXISTS idx_withdrawals_wallet ON withdrawals(wallet_id);
CREATE INDEX IF NOT EXISTS idx_withdrawals_status ON withdrawals(status);
CREATE INDEX IF NOT EXISTS idx_commissions_booking ON commissions(booking_id);
CREATE INDEX IF NOT EXISTS idx_commissions_status ON commissions(status);

-- 7. Minimum Withdrawal Settings per Currency
INSERT INTO settings (key, value, description) VALUES
('minimum_withdrawal_amount_eur', '50.00', 'Minimum allowed withdrawal in EUR'),
('minimum_withdrawal_amount_usd', '50.00', 'Minimum allowed withdrawal in USD'),
('minimum_withdrawal_amount_dzd', '6500.00', 'Minimum allowed withdrawal in DZD'),
('minimum_withdrawal_amount_gbp', '40.00', 'Minimum allowed withdrawal in GBP'),
('payout_provider_active', 'manual_transfer', 'Active payout provider (manual_transfer or stripe_connect)')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;

-- 8. Seed Platform Owner Wallets (Default Admin User)
INSERT INTO wallets (owner_id, currency, available_balance, pending_balance, total_earned, total_withdrawn) VALUES
('00000000-0000-0000-0000-000000000001', 'EUR', 125.50, 32.40, 1580.75, 1422.85),
('00000000-0000-0000-0000-000000000001', 'USD', 80.00, 15.20, 950.00, 854.80),
('00000000-0000-0000-0000-000000000001', 'DZD', 24500.00, 6800.00, 185000.00, 153700.00),
('00000000-0000-0000-0000-000000000001', 'GBP', 65.00, 0.00, 420.00, 355.00)
ON CONFLICT (owner_id, currency) DO NOTHING;

-- Seed Default Primary Bank Account
INSERT INTO bank_accounts (owner_id, account_holder_name, bank_name, iban, swift_bic, country, is_primary) VALUES
('00000000-0000-0000-0000-000000000001', 'TravelGo Global Ltd / Platform Owner', 'Société Générale Algérie', 'DZ5002100012345678901234', 'SGEADZAL', 'Algeria', TRUE)
ON CONFLICT DO NOTHING;
