-- Migration Rollback: Remove foreign key constraint from users to tenants
-- Description: Removes the foreign key constraint for tenant_id in users table

-- Drop foreign key constraint
ALTER TABLE users
DROP CONSTRAINT IF EXISTS fk_users_tenant_id;
