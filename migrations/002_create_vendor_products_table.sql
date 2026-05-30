-- Migration: Create vendor_products table
-- Description: Creates the vendor products table with foreign key references to master_products
-- Requirements: 11.1, 11.2, 11.3, 7.1, 7.4

-- Create vendor_products table
CREATE TABLE IF NOT EXISTS vendor_products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL,
  master_product_id UUID NOT NULL,
  markup_price INTEGER NOT NULL CHECK (markup_price >= 0),
  description_override TEXT,
  stock_sync_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- Foreign key constraint to master_products with RESTRICT on delete
  CONSTRAINT fk_master_product FOREIGN KEY (master_product_id) 
    REFERENCES master_products(id) ON DELETE RESTRICT,
  
  -- Unique constraint to prevent duplicate clones per vendor
  CONSTRAINT unique_vendor_master UNIQUE (vendor_id, master_product_id)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_vendor_products_vendor ON vendor_products(vendor_id);
CREATE INDEX IF NOT EXISTS idx_vendor_products_master ON vendor_products(master_product_id);
CREATE INDEX IF NOT EXISTS idx_vendor_products_sync_enabled ON vendor_products(stock_sync_enabled) 
  WHERE stock_sync_enabled = TRUE;

-- Add comments to table
COMMENT ON TABLE vendor_products IS 'Vendor-specific product instances that reference master products';
COMMENT ON COLUMN vendor_products.id IS 'Unique identifier for the vendor product';
COMMENT ON COLUMN vendor_products.vendor_id IS 'User ID of the vendor who owns this product';
COMMENT ON COLUMN vendor_products.master_product_id IS 'Foreign key reference to the master product';
COMMENT ON COLUMN vendor_products.markup_price IS 'Vendor-specific price in cents (must be >= base_price)';
COMMENT ON COLUMN vendor_products.description_override IS 'Optional custom description that overrides master description';
COMMENT ON COLUMN vendor_products.stock_sync_enabled IS 'Flag indicating if stock should sync with master product';
COMMENT ON COLUMN vendor_products.stock_quantity IS 'Vendor-managed stock quantity (used when sync is disabled)';
COMMENT ON COLUMN vendor_products.created_at IS 'Timestamp when the vendor product was created';
COMMENT ON COLUMN vendor_products.updated_at IS 'Timestamp when the vendor product was last updated';
COMMENT ON CONSTRAINT fk_master_product ON vendor_products IS 'Ensures referential integrity with master_products table';
COMMENT ON CONSTRAINT unique_vendor_master ON vendor_products IS 'Prevents vendors from cloning the same product twice';
