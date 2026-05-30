-- Rollback: Drop vendor_commission_rates table

DROP TRIGGER IF EXISTS update_vendor_commission_rates_updated_at ON vendor_commission_rates;
DROP INDEX IF EXISTS idx_vendor_commission_rates_vendor;
DROP TABLE IF EXISTS vendor_commission_rates;
