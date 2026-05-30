-- Rollback: Drop commission_records table

DROP INDEX IF EXISTS idx_commission_records_created;
DROP INDEX IF EXISTS idx_commission_records_order;
DROP INDEX IF EXISTS idx_commission_records_vendor;
DROP INDEX IF EXISTS idx_commission_records_payment;
DROP TABLE IF EXISTS commission_records;
