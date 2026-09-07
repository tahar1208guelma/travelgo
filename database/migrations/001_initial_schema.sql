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
