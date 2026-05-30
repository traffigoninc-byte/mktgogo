-- Migration: Create platform_settings table
-- Description: Stores platform-wide configuration settings

CREATE TABLE IF NOT EXISTS platform_settings (
  key VARCHAR(100) PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Trigger for updated_at
CREATE TRIGGER update_platform_settings_updated_at
  BEFORE UPDATE ON platform_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Insert default commission rate (15%)
INSERT INTO platform_settings (key, value) 
VALUES ('default_commission_rate', '0.15')
ON CONFLICT (key) DO NOTHING;

-- Insert minimum payout thresholds per currency
INSERT INTO platform_settings (key, value) 
VALUES 
  ('min_payout_threshold_usd', '10.00'),
  ('min_payout_threshold_eur', '10.00'),
  ('min_payout_threshold_ngn', '5000.00'),
  ('min_payout_threshold_ghs', '50.00'),
  ('min_payout_threshold_kes', '1000.00'),
  ('auto_approval_threshold_usd', '1000.00'),
  ('auto_approval_enabled', 'true')
ON CONFLICT (key) DO NOTHING;
