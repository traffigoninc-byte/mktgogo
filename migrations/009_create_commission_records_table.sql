-- Migration: Create commission_records table
-- Description: Stores commission calculations for each payment

CREATE TABLE IF NOT EXISTS commission_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
  order_id UUID NOT NULL,
  vendor_id UUID NOT NULL,
  amount DECIMAL(19, 2) NOT NULL,
  commission_rate DECIMAL(5, 4) NOT NULL,
  commission_amount DECIMAL(19, 2) NOT NULL,
  currency VARCHAR(3) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_commission_records_payment ON commission_records(payment_id);
CREATE INDEX idx_commission_records_vendor ON commission_records(vendor_id);
CREATE INDEX idx_commission_records_order ON commission_records(order_id);
CREATE INDEX idx_commission_records_created ON commission_records(created_at);
