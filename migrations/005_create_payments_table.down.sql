-- Rollback: Drop payments table

DROP TRIGGER IF EXISTS update_payments_updated_at ON payments;
DROP INDEX IF EXISTS idx_payments_created_at;
DROP INDEX IF EXISTS idx_payments_gateway_payment_id;
DROP INDEX IF EXISTS idx_payments_idempotency;
DROP INDEX IF EXISTS idx_payments_status;
DROP INDEX IF EXISTS idx_payments_vendor;
DROP INDEX IF EXISTS idx_payments_order;
DROP TABLE IF EXISTS payments;
