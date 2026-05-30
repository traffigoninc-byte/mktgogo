-- Migration: Create refunds table
-- Description: Stores refund records with commission reversal details

CREATE TABLE IF NOT EXISTS refunds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL,
  payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
  amount DECIMAL(19, 2) NOT NULL CHECK (amount > 0),
  currency VARCHAR(3) NOT NULL,
  commission_refund DECIMAL(19, 2) NOT NULL,
  vendor_debit DECIMAL(19, 2) NOT NULL,
  gateway_refund_id VARCHAR(255),
  reason TEXT,
  initiated_by UUID NOT NULL,
  status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'completed', 'failed')),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_refunds_order ON refunds(order_id);
CREATE INDEX idx_refunds_payment ON refunds(payment_id);
CREATE INDEX idx_refunds_status ON refunds(status);
CREATE INDEX idx_refunds_created ON refunds(created_at);
CREATE INDEX idx_refunds_gateway_refund_id ON refunds(gateway_refund_id);
