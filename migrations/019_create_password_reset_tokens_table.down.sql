-- Migration Rollback: Drop password_reset_tokens table
-- Description: Removes the password_reset_tokens table and all associated indexes

-- Drop indexes
DROP INDEX IF EXISTS idx_password_reset_tokens_token_hash;
DROP INDEX IF EXISTS idx_password_reset_tokens_user_id;

-- Drop table
DROP TABLE IF EXISTS password_reset_tokens;
