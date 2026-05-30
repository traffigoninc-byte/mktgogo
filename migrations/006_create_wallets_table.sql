-- Migration: Create wallets table
-- Description: Stores vendor wallet balances per currency

CREATE TABLE IF NOT EXISTS wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL,
  currency VARCHAR(3) NOT NULL,
  balance DECIMAL(19, 2) NOT NULL DEFAULT 0,
  reserved_balance DECIMAL(19, 2) NOT NULL DEFAULT 0 CHECK (reserved_balance >= 0),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  UNIQUE (vendor_id, currency)
);

-- Indexes for performance
CREATE INDEX idx_wallets_vendor ON wallets(vendor_id);
CREATE INDEX idx_wallets_currency ON wallets(currency);

-- Trigger for updated_at
CREATE TRIGGER update_wallets_updated_at
  BEFORE UPDATE ON wallets
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
