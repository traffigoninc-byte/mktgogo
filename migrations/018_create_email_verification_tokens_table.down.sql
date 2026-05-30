-- Migration Rollback: Drop email_verification_tokens table
-- Description: Removes the email_verification_tokens table and all associated indexes

-- Drop indexes
DROP INDEX IF EXISTS idx_email_verification_tokens_token_hash;
DROP INDEX IF EXISTS idx_email_verification_tokens_user_id;

-- Drop table
DROP TABLE IF EXISTS email_verification_tokens;
