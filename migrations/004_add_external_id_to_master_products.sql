-- Migration: Add external_id column to master_products table
-- Description: Adds external_id column for tracking products imported from external systems
-- Requirements: 2.6 (Duplicate prevention in imports)

-- Add external_id column (nullable for existing products)
ALTER TABLE master_products
ADD COLUMN IF NOT EXISTS external_id VARCHAR(255);

-- Create unique index on external_id to prevent duplicates
CREATE UNIQUE INDEX IF NOT EXISTS idx_master_products_external_id 
ON master_products(external_id) 
WHERE external_id IS NOT NULL;

-- Add comment
COMMENT ON COLUMN master_products.external_id IS 'External system identifier for imported products (unique)';
