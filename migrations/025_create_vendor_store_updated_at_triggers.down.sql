-- Migration Rollback: Drop updated_at triggers for vendor store tables
-- Description: Removes the triggers for vendor store tables

-- Drop triggers
DROP TRIGGER IF EXISTS update_store_configurations_updated_at ON store_configurations;
DROP TRIGGER IF EXISTS update_store_templates_updated_at ON store_templates;
DROP TRIGGER IF EXISTS update_vendors_updated_at ON vendors;

-- Note: We don't drop the update_updated_at_column() function as it may be used by other tables
