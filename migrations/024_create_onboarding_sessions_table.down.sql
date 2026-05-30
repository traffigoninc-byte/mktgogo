-- Migration Rollback: Drop onboarding_sessions table
-- Description: Removes the onboarding_sessions table and all associated indexes

-- Drop indexes
DROP INDEX IF EXISTS idx_onboarding_sessions_expires_at;
DROP INDEX IF EXISTS idx_onboarding_sessions_vendor_id;

-- Drop table
DROP TABLE IF EXISTS onboarding_sessions;
