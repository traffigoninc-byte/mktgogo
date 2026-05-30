-- Migration: Create updated_at triggers for vendor store tables
-- Description: Creates triggers to automatically update the updated_at timestamp on vendor store tables
-- Requirements: 12.1, 12.2, 12.3

-- Create or replace the trigger function (if not already exists)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for vendors table
DROP TRIGGER IF EXISTS update_vendors_updated_at ON vendors;
CREATE TRIGGER update_vendors_updated_at
  BEFORE UPDATE ON vendors
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create trigger for store_templates table
DROP TRIGGER IF EXISTS update_store_templates_updated_at ON store_templates;
CREATE TRIGGER update_store_templates_updated_at
  BEFORE UPDATE ON store_templates
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create trigger for store_configurations table
DROP TRIGGER IF EXISTS update_store_configurations_updated_at ON store_configurations;
CREATE TRIGGER update_store_configurations_updated_at
  BEFORE UPDATE ON store_configurations
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Add comments
COMMENT ON FUNCTION update_updated_at_column() IS 'Automatically updates the updated_at column to the current timestamp';
