-- Rollback: Drop refunds table

DROP INDEX IF EXISTS idx_refunds_gateway_refund_id;
DROP INDEX IF EXISTS idx_refunds_created;
DROP INDEX IF EXISTS idx_refunds_status;
DROP INDEX IF EXISTS idx_refunds_payment;
DROP INDEX IF EXISTS idx_refunds_order;
DROP TABLE IF EXISTS refunds;
