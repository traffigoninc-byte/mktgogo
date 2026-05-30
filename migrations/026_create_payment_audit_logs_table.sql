-- Create payment_audit_logs table for financial transaction audit trail
-- Validates: Requirement 9.4

CREATE TABLE IF NOT EXISTS payment_audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type VARCHAR(50) NOT NULL,
  user_id UUID,
  vendor_id UUID,
  order_id UUID,
  payment_id UUID,
  payout_id UUID,
  refund_id UUID,
  amount DECIMAL(19, 2),
  currency VARCHAR(3),
  gateway VARCHAR(50),
  status VARCHAR(20),
  ip_address VARCHAR(45),
  details JSONB,
  timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create indexes for efficient querying
CREATE INDEX idx_payment_audit_logs_event_type ON payment_audit_logs(event_type);
CREATE INDEX idx_payment_audit_logs_user_id ON payment_audit_logs(user_id);
CREATE INDEX idx_payment_audit_logs_vendor_id ON payment_audit_logs(vendor_id);
CREATE INDEX idx_payment_audit_logs_order_id ON payment_audit_logs(order_id);
CREATE INDEX idx_payment_audit_logs_payment_id ON payment_audit_logs(payment_id);
CREATE INDEX idx_payment_audit_logs_payout_id ON payment_audit_logs(payout_id);
CREATE INDEX idx_payment_audit_logs_refund_id ON payment_audit_logs(refund_id);
CREATE INDEX idx_payment_audit_logs_timestamp ON payment_audit_logs(timestamp);
CREATE INDEX idx_payment_audit_logs_gateway ON payment_audit_logs(gateway);

-- Add comment
COMMENT ON TABLE payment_audit_logs IS 'Audit trail for all financial transactions (payments, payouts, refunds, wallet operations)';
