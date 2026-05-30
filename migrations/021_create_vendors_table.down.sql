-- Migration Rollback: Drop vendors table
-- Description: Removes the vendors table and all associated indexes

-- Drop indexes
DROP INDEX IF EXISTS idx_vendors_user_id;

-- Drop table
DROP TABLE IF EXISTS vendors;
