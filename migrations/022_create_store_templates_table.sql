-- Migration: Create store_templates table
-- Description: Creates the store_templates table to store 3D animated store template designs
-- Requirements: 12.3

-- Create store_templates table
CREATE TABLE IF NOT EXISTS store_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  preview_url TEXT NOT NULL,
  is_available BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_store_templates_is_available ON store_templates(is_available);

-- Add comments to table
COMMENT ON TABLE store_templates IS 'Store template catalog with 3D animated designs for vendor stores';
COMMENT ON COLUMN store_templates.id IS 'Unique identifier for the template';
COMMENT ON COLUMN store_templates.name IS 'Template name';
COMMENT ON COLUMN store_templates.description IS 'Template description';
COMMENT ON COLUMN store_templates.preview_url IS 'URL to template preview image';
COMMENT ON COLUMN store_templates.is_available IS 'Whether the template is available for selection';
COMMENT ON COLUMN store_templates.created_at IS 'Timestamp when the template was created';
COMMENT ON COLUMN store_templates.updated_at IS 'Timestamp when the template was last updated';
