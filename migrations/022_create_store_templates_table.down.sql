-- Migration Rollback: Drop store_templates table
-- Description: Removes the store_templates table and all associated indexes

-- Drop indexes
DROP INDEX IF EXISTS idx_store_templates_is_available;

-- Drop table
DROP TABLE IF EXISTS store_templates;
