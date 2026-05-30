-- Migration: Create payout_requests table
-- Description: Stores vendor payout requests and their status

CREATE TABLE IF NOT EXISTS payout_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL,
  amount DECIMAL(19, 2) NOT NULL CHECK (amount > 0),
  currency VARCHAR(3) NOT NULL,
  gateway VARCHAR(50) NOT NULL,
  gateway_payout_id VARCHAR(255),
  status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'approved', 'processing', 'completed', 'failed', 'cancelled')),
  bank_account JSONB NOT NULL,
  approved_by UUID,
  approved_at TIMESTAMP,
  processed_at TIMESTAMP,
  failure_reason TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_payout_requests_vendor ON payout_requests(vendor_id);
CREATE INDEX idx_payout_requests_status ON payout_requests(status);
CREATE INDEX idx_payout_requests_created ON payout_requests(created_at);
CREATE INDEX idx_payout_requests_gateway_payout_id ON payout_requests(gateway_payout_id);

-- Trigger for updated_at
CREATE TRIGGER update_payout_requests_updated_at
  BEFORE UPDATE ON payout_requests
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
