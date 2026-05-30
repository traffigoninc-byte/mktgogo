-- Rollback: Drop payout_requests table

DROP TRIGGER IF EXISTS update_payout_requests_updated_at ON payout_requests;
DROP INDEX IF EXISTS idx_payout_requests_gateway_payout_id;
DROP INDEX IF EXISTS idx_payout_requests_created;
DROP INDEX IF EXISTS idx_payout_requests_status;
DROP INDEX IF EXISTS idx_payout_requests_vendor;
DROP TABLE IF EXISTS payout_requests;
