-- Migration: Create master_products table
-- Description: Creates the master products catalog table with all required fields and constraints
-- Requirements: 11.1, 11.2, 11.3, 7.1, 7.4

-- Create master_products table
CREATE TABLE IF NOT EXISTS master_products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  base_price INTEGER NOT NULL CHECK (base_price >= 0),
  product_type VARCHAR(20) NOT NULL CHECK (product_type IN ('PHYSICAL', 'DIGITAL', 'DROPSHIP')),
  stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  created_by UUID NOT NULL
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_master_products_type ON master_products(product_type);
CREATE INDEX IF NOT EXISTS idx_master_products_created_at ON master_products(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_master_products_created_by ON master_products(created_by);

-- Add comment to table
COMMENT ON TABLE master_products IS 'Master product catalog managed by platform administrators';
COMMENT ON COLUMN master_products.id IS 'Unique identifier for the master product';
COMMENT ON COLUMN master_products.name IS 'Product name';
COMMENT ON COLUMN master_products.description IS 'Product description';
COMMENT ON COLUMN master_products.base_price IS 'Base price in cents (must be non-negative)';
COMMENT ON COLUMN master_products.product_type IS 'Product type: PHYSICAL, DIGITAL, or DROPSHIP';
COMMENT ON COLUMN master_products.stock_quantity IS 'Available stock quantity (must be non-negative)';
COMMENT ON COLUMN master_products.created_at IS 'Timestamp when the product was created';
COMMENT ON COLUMN master_products.updated_at IS 'Timestamp when the product was last updated';
COMMENT ON COLUMN master_products.created_by IS 'User ID of the platform admin who created the product';
