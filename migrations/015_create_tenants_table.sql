-- Migration: Create tenants table
-- Description: Creates the tenants table for multi-tenant vendor isolation
-- Requirements: 6.1

-- Create tenants table
CREATE TABLE IF NOT EXISTS tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_tenants_name ON tenants(name);

-- Add comments to table
COMMENT ON TABLE tenants IS 'Tenant organizations for multi-tenant vendor isolation';
COMMENT ON COLUMN tenants.id IS 'Unique identifier for the tenant';
COMMENT ON COLUMN tenants.name IS 'Tenant name';
COMMENT ON COLUMN tenants.created_at IS 'Timestamp when the tenant was created';
COMMENT ON COLUMN tenants.updated_at IS 'Timestamp when the tenant was last updated';
