-- Rollback Migration: Drop updated_at triggers
-- Description: Removes triggers and trigger function for updated_at timestamp management

-- Drop triggers
DROP TRIGGER IF EXISTS update_vendor_products_updated_at ON vendor_products;
DROP TRIGGER IF EXISTS update_master_products_updated_at ON master_products;

-- Drop trigger function
DROP FUNCTION IF EXISTS update_updated_at_column();
