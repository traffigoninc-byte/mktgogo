-- Migration: Create vendor_commission_rates table
-- Description: Stores custom commission rates for specific vendors

CREATE TABLE IF NOT EXISTS vendor_commission_rates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL UNIQUE,
  commission_rate DECIMAL(5, 4) NOT NULL CHECK (commission_rate >= 0 AND commission_rate <= 1),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_vendor_commission_rates_vendor ON vendor_commission_rates(vendor_id);

-- Trigger for updated_at
CREATE TRIGGER update_vendor_commission_rates_updated_at
  BEFORE UPDATE ON vendor_commission_rates
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
