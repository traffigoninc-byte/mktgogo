-- Migration: Create store_configurations table
-- Description: Creates the store_configurations table to store vendor store settings and branding
-- Requirements: 12.2, 12.4, 12.5, 12.6, 12.7

-- Create store_configurations table
CREATE TABLE IF NOT EXISTS store_configurations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL UNIQUE REFERENCES vendors(id) ON DELETE CASCADE,
  template_id UUID NOT NULL REFERENCES store_templates(id) ON DELETE RESTRICT,
  subdomain VARCHAR(63) NOT NULL UNIQUE,
  custom_domain VARCHAR(255) UNIQUE,
  custom_domain_verified BOOLEAN NOT NULL DEFAULT false,
  logo_url TEXT,
  primary_color VARCHAR(7) NOT NULL,
  secondary_color VARCHAR(7) NOT NULL,
  social_links JSONB NOT NULL DEFAULT '{}',
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'suspended')),
  status_changed_at TIMESTAMP,
  status_changed_by UUID REFERENCES users(id),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_store_configurations_vendor_id ON store_configurations(vendor_id);
CREATE INDEX IF NOT EXISTS idx_store_configurations_subdomain ON store_configurations(subdomain);
CREATE INDEX IF NOT EXISTS idx_store_configurations_custom_domain ON store_configurations(custom_domain) WHERE custom_domain IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_store_configurations_status ON store_configurations(status);

-- Add comments to table
COMMENT ON TABLE store_configurations IS 'Store configuration and branding settings for vendor stores';
COMMENT ON COLUMN store_configurations.id IS 'Unique identifier for the store configuration';
COMMENT ON COLUMN store_configurations.vendor_id IS 'Reference to the vendor (one store per vendor)';
COMMENT ON COLUMN store_configurations.template_id IS 'Reference to the selected store template';
COMMENT ON COLUMN store_configurations.subdomain IS 'Unique subdomain for the store (e.g., vendor-name.platform.com)';
COMMENT ON COLUMN store_configurations.custom_domain IS 'Optional custom domain for the store';
COMMENT ON COLUMN store_configurations.custom_domain_verified IS 'Whether the custom domain DNS has been verified';
COMMENT ON COLUMN store_configurations.logo_url IS 'URL to the vendor logo';
COMMENT ON COLUMN store_configurations.primary_color IS 'Primary brand color (hex code)';
COMMENT ON COLUMN store_configurations.secondary_color IS 'Secondary brand color (hex code)';
COMMENT ON COLUMN store_configurations.social_links IS 'JSON object containing social media links';
COMMENT ON COLUMN store_configurations.status IS 'Store status: pending, active, or suspended';
COMMENT ON COLUMN store_configurations.status_changed_at IS 'Timestamp when status was last changed';
COMMENT ON COLUMN store_configurations.status_changed_by IS 'User who changed the status (admin)';
COMMENT ON COLUMN store_configurations.created_at IS 'Timestamp when the store configuration was created';
COMMENT ON COLUMN store_configurations.updated_at IS 'Timestamp when the store configuration was last updated';
