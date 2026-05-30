-- Migration Rollback: Drop tenants table
-- Description: Removes the tenants table and all associated indexes

-- Drop indexes
DROP INDEX IF EXISTS idx_tenants_name;

-- Drop table
DROP TABLE IF EXISTS tenants;
