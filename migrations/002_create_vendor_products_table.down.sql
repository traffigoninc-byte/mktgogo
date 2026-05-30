-- Rollback Migration: Drop vendor_products table
-- Description: Removes the vendor_products table and its indexes

-- Drop indexes
DROP INDEX IF EXISTS idx_vendor_products_sync_enabled;
DROP INDEX IF EXISTS idx_vendor_products_master;
DROP INDEX IF EXISTS idx_vendor_products_vendor;

-- Drop table
DROP TABLE IF EXISTS vendor_products CASCADE;
