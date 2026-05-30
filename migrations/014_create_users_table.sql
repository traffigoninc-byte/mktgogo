-- Migration: Create users table
-- Description: Creates the users table with role-based access control and tenant relationship
-- Requirements: 1.1, 5.1, 6.1

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL CHECK (role IN ('CUSTOMER', 'VENDOR', 'PLATFORM_ADMIN')),
  tenant_id UUID,
  is_email_verified BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- Constraint: VENDOR users MUST have a tenant_id
  CONSTRAINT vendor_must_have_tenant CHECK (
    (role = 'VENDOR' AND tenant_id IS NOT NULL) OR 
    (role != 'VENDOR')
  )
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_tenant_id ON users(tenant_id);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- Add comments to table
COMMENT ON TABLE users IS 'User accounts with role-based access control and multi-tenant support';
COMMENT ON COLUMN users.id IS 'Unique identifier for the user';
COMMENT ON COLUMN users.email IS 'User email address (unique)';
COMMENT ON COLUMN users.password_hash IS 'Hashed password using Argon2id or bcrypt';
COMMENT ON COLUMN users.role IS 'User role: CUSTOMER, VENDOR, or PLATFORM_ADMIN';
COMMENT ON COLUMN users.tenant_id IS 'Tenant identifier for VENDOR users (required for vendors)';
COMMENT ON COLUMN users.is_email_verified IS 'Flag indicating if email has been verified';
COMMENT ON COLUMN users.created_at IS 'Timestamp when the user was created';
COMMENT ON COLUMN users.updated_at IS 'Timestamp when the user was last updated';
COMMENT ON CONSTRAINT vendor_must_have_tenant ON users IS 'Ensures VENDOR users are associated with a tenant';
