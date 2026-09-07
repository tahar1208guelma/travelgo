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
