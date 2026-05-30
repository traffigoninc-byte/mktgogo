-- Rollback Migration: Drop master_products table
-- Description: Removes the master_products table and its indexes

-- Drop indexes
DROP INDEX IF EXISTS idx_master_products_created_by;
DROP INDEX IF EXISTS idx_master_products_created_at;
DROP INDEX IF EXISTS idx_master_products_type;

-- Drop table
DROP TABLE IF EXISTS master_products CASCADE;
