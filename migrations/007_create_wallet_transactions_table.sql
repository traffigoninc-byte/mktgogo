-- Migration: Create wallet_transactions table
-- Description: Records all wallet credit/debit transactions

CREATE TABLE IF NOT EXISTS wallet_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
  type VARCHAR(10) NOT NULL CHECK (type IN ('credit', 'debit')),
  category VARCHAR(20) NOT NULL CHECK (category IN ('payment', 'payout', 'refund', 'refund_reversal')),
  amount DECIMAL(19, 2) NOT NULL CHECK (amount > 0),
  balance_after DECIMAL(19, 2) NOT NULL,
  reference VARCHAR(255) NOT NULL,
  description TEXT,
  idempotency_key VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_wallet_transactions_wallet ON wallet_transactions(wallet_id);
CREATE INDEX idx_wallet_transactions_reference ON wallet_transactions(reference);
CREATE INDEX idx_wallet_transactions_created ON wallet_transactions(created_at);
CREATE INDEX idx_wallet_transactions_idempotency ON wallet_transactions(idempotency_key);
CREATE INDEX idx_wallet_transactions_type ON wallet_transactions(type);
CREATE INDEX idx_wallet_transactions_category ON wallet_transactions(category);
