-- Migration: Add foreign key constraint from users to tenants
-- Description: Adds the foreign key constraint for tenant_id in users table
-- Requirements: 6.1

-- Add foreign key constraint
ALTER TABLE users
ADD CONSTRAINT fk_users_tenant_id 
FOREIGN KEY (tenant_id) 
REFERENCES tenants(id) 
ON DELETE RESTRICT;

-- Add comment to constraint
COMMENT ON CONSTRAINT fk_users_tenant_id ON users IS 'Foreign key to tenants table for multi-tenant isolation';
