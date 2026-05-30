-- Migration: Create updated_at timestamp triggers
-- Description: Creates trigger function and triggers to automatically update updated_at timestamps
-- Requirements: 11.1, 11.2, 11.3

-- Create trigger function to update updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add comment to function
COMMENT ON FUNCTION update_updated_at_column() IS 'Trigger function that automatically updates the updated_at timestamp on row updates';

-- Create trigger for master_products table
DROP TRIGGER IF EXISTS update_master_products_updated_at ON master_products;
CREATE TRIGGER update_master_products_updated_at
  BEFORE UPDATE ON master_products
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TRIGGER update_master_products_updated_at ON master_products IS 'Automatically updates updated_at timestamp when master product is modified';

-- Create trigger for vendor_products table
DROP TRIGGER IF EXISTS update_vendor_products_updated_at ON vendor_products;
CREATE TRIGGER update_vendor_products_updated_at
  BEFORE UPDATE ON vendor_products
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TRIGGER update_vendor_products_updated_at ON vendor_products IS 'Automatically updates updated_at timestamp when vendor product is modified';
