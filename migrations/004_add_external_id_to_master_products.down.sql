-- Rollback: Remove external_id column from master_products table

-- Drop the unique index
DROP INDEX IF EXISTS idx_master_products_external_id;

-- Drop the external_id column
ALTER TABLE master_products
DROP COLUMN IF EXISTS external_id;
