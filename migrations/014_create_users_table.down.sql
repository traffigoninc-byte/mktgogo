-- Migration Rollback: Drop users table
-- Description: Removes the users table and all associated indexes

-- Drop indexes
DROP INDEX IF EXISTS idx_users_role;
DROP INDEX IF EXISTS idx_users_tenant_id;
DROP INDEX IF EXISTS idx_users_email;

-- Drop table
DROP TABLE IF EXISTS users;
