-- Migration Rollback: Drop audit_logs table
-- Description: Removes the audit_logs table and all associated indexes

-- Drop indexes
DROP INDEX IF EXISTS idx_audit_logs_ip_address;
DROP INDEX IF EXISTS idx_audit_logs_timestamp;
DROP INDEX IF EXISTS idx_audit_logs_event_type;
DROP INDEX IF EXISTS idx_audit_logs_user_id;

-- Drop table
DROP TABLE IF EXISTS audit_logs;
