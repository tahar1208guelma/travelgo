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
