-- Migration: Create vendors table
-- Description: Creates the vendors table to store vendor information linked to user accounts
-- Requirements: 12.1

-- Create vendors table
CREATE TABLE IF NOT EXISTS vendors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_vendors_user_id ON vendors(user_id);

-- Add comments to table
COMMENT ON TABLE vendors IS 'Vendor accounts linked to user accounts with VENDOR role';
COMMENT ON COLUMN vendors.id IS 'Unique identifier for the vendor';
COMMENT ON COLUMN vendors.user_id IS 'Reference to the user account (must have VENDOR role)';
COMMENT ON COLUMN vendors.created_at IS 'Timestamp when the vendor was created';
COMMENT ON COLUMN vendors.updated_at IS 'Timestamp when the vendor was last updated';
