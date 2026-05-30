-- Migration Rollback: Drop store_configurations table
-- Description: Removes the store_configurations table and all associated indexes

-- Drop indexes
DROP INDEX IF EXISTS idx_store_configurations_status;
DROP INDEX IF EXISTS idx_store_configurations_custom_domain;
DROP INDEX IF EXISTS idx_store_configurations_subdomain;
DROP INDEX IF EXISTS idx_store_configurations_vendor_id;

-- Drop table
DROP TABLE IF EXISTS store_configurations;
