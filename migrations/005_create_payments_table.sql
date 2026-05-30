-- Migration: Create payments table
-- Description: Stores payment records with gateway integration

CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL,
  vendor_id UUID NOT NULL,
  amount DECIMAL(19, 2) NOT NULL CHECK (amount > 0),
  currency VARCHAR(3) NOT NULL,
  gateway VARCHAR(50) NOT NULL,
  gateway_payment_id VARCHAR(255),
  status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'completed', 'failed')),
  commission_amount DECIMAL(19, 2) NOT NULL DEFAULT 0,
  vendor_amount DECIMAL(19, 2) NOT NULL DEFAULT 0,
  commission_rate DECIMAL(5, 4) NOT NULL,
  idempotency_key VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_vendor ON payments(vendor_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_idempotency ON payments(idempotency_key);
CREATE INDEX idx_payments_gateway_payment_id ON payments(gateway_payment_id);
CREATE INDEX idx_payments_created_at ON payments(created_at);

-- Trigger for updated_at
CREATE TRIGGER update_payments_updated_at
  BEFORE UPDATE ON payments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
