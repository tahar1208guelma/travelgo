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
